#!/usr/bin/env bash

cd /data/pl-import

if [[ $DEBUG == 1 ]]; then
    set -x
fi

SOURCEFORMATFLAG=

echo "Format: ${format}"
if [[ -n $format ]] && [[ $format == "emp" ]]; then
    echo "*** EMP ***"
fi

if [[ ${format} == "emp" ]]; then
    # EMP single-end/paired-end multiplexed fastq
    if [[ ${paired} == 1 ]] || [[ ${paired} == "true" ]]; then
        SEQTYPE="EMPPairedEndSequences"
        EMPDEMUXCMD="emp-paired"
        REVCOMPFLAG="--p-rev-comp-mapping-barcodes"
    else
        SEQTYPE="EMPSingleEndSequences"
        EMPDEMUXCMD="emp-single"
        REVCOMPFLAG=
    fi
else
    # Casava 1.8 single-end/paired-end demultiplexed fastq
    SOURCEFORMATFLAG="--source-format CasavaOneEightSingleLanePerSampleDirFmt"
    if [[ ${paired} == 1 ]] || [[ ${paired} == "true" ]]; then
        SEQTYPE="SampleData[PairedEndSequencesWithQuality]"
    else
        SEQTYPE="SampleData[SequencesWithQuality]"
    fi
fi

qiime tools import \
    --type $SEQTYPE $SOURCEFORMATFLAG \
    --input-path $INPUT \
    --output-path output/imported.qza

# if EMP file format, we need to demultiplex
if [[ ${format} == "emp" ]]; then
    mv output/imported.qza ./imported-multiplexed.qza
    qiime demux $EMPDEMUXCMD $REVCOMPFLAG \
        --i-seqs ./imported-multiplexed.qza \
        --m-barcodes-file ${bfile} \
        --m-barcodes-category BarcodeSequence \
        --o-per-sample-sequences output/imported.qza

    rm ./imported-multiplexed.qza
fi

qiime demux summarize \
    --i-data output/imported.qza \
    --p-n $RANDSAMPLES \
    --o-visualization output/imported.qzv

set +x
