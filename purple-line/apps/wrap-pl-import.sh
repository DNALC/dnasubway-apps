#!/usr/bin/env bash

DEBUG=1
if [[ $DEBUG == 1 ]]; then
    set -x
fi

APPNAME="pl-import"
DOCKER_IMG="qiime2/core:2017.4"

TYPE=${TYPE:-docker}

# Manually, enumerate over each parameter
DOCK_ENV="_$$.env"
SING_ENV="$DOCK_ENV.singularity"
rm -rf "$DOCK_ENV*"

echo "files=\"${files}\"" >> ${DOCK_ENV}
echo "bfile=${bfile}" >> ${DOCK_ENV}
echo "jobName=${jobName}" >> ${DOCK_ENV}
echo "format=${format}" >> ${DOCK_ENV}
echo "paired=${paired}" >> ${DOCK_ENV}
echo "randomSamples=${randomSamples}" >> ${DOCK_ENV}

RANDSAMPLES=${randomSamples:-8}

mkdir input-data/
export INPUT=./input-data/

echo "INPUT=input-data/" >> ${DOCK_ENV}

mv *.fastq.gz input-data/

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

if [[ "$TYPE" == "docker" ]];
then
    set -x
    CONTAINERID=$(docker run -d --env-file ${DOCK_ENV} -v $PWD:/data $DOCKER_IMG sleep 1800)
    # what if we can't create a container?!

	docker exec $CONTAINERID \
           qiime tools import \
                --type $SEQTYPE $SOURCEFORMATFLAG \
                --input-path $INPUT \
                --output-path ./imported.qza
    sleep 1

    # if EMP file format, we need to demultiplex
    if [[ ${format} == "emp" ]]; then
        mv ./imported.qza ./imported-multiplexed.qza
	    docker exec $CONTAINERID \
            qiime demux $EMPDEMUXCMD $REVCOMPFLAG \
                --i-seqs ./imported-multiplexed.qza \
                --m-barcodes-file ${bfile} \
                --m-barcodes-category BarcodeSequence \
                --o-per-sample-sequences ./imported.qza

        rm ./imported-multiplexed.qza
        sleep 1
    fi

    docker exec $CONTAINERID \
        qiime demux summarize \
            --i-data ./imported.qza \
            --o-visualization ./imported.qzv
    sleep 1

    docker exec $CONTAINERID \
        qiime dada2 plot-qualities \
            --i-demultiplexed-seqs ./imported.qza \
            --p-n $RANDSAMPLES \
            --o-visualization ./imported-qual-plots.qzv
    sleep 1

    # clean up
    docker stop $CONTAINERID
    docker rm $CONTAINERID

    rm -rf $INPUT

    set +x
fi


# rm ${DOCK_ENV}*
