#!/usr/bin/env bash

# Convenience functions
echoerr() { echo -e "$@\n" 1>&2; }
if [[ "${DEBUG}" == "1" ]]; then
    set -x
fi

date1=$(date +"%s")

FILES=(${files})

for f in $(seq 0 $((${#FILES[@]} - 1))); do 
    echo -ne "${f}\t${FILES[$f]}"
done

ls -lh ./*

METADATA=${metadata}
THREADS=4
TRIMLEFT=${trimLeft:-0}
TRUNCLEN=${truncLen}

INPUT=${FILES[0]}
echo '#zip contents of ${INPUT}:'
unzip -l $INPUT

OUTPUT=./output
mkdir -p ${OUTPUT}


TABLE="${OUTPUT}/table-${jobName}"
echoerr "Table will be saved in ${TABLE}"

qiime dada2 denoise-single \
    --verbose \
    --p-n-threads ${THREADS} \
    --i-demultiplexed-seqs $INPUT \
    --p-trim-left $TRIMLEFT \
    --p-trunc-len $TRUNCLEN \
    --o-representative-sequences ${OUTPUT}/rep-seqs.qza \
    --o-table ${TABLE}.qza

echoerr "do we have any output in ${OUTPUT}?!"
echoerr $(ls -l $OUTPUT)

echo "#zip contents of ${TABLE}.qza:"
unzip -l ${TABLE}.qza


echoerr "# fors -------------------------"
for f in $(seq 0 $((${#FILES[@]} - 1))); do 
    echoerr -ne "rm -v ${FILES[$f]}\n"
done
for f in ${FILES[*]}; do
    echoerr "input files 2: ${f}"
done

echoerr "# about to use metadata -------------------------"
echoerr ${METADATA}
echoerr "# -----------------------------------------------"
echoerr $(cat ${METADATA})

qiime feature-table summarize \
    --verbose \
    --i-table ${TABLE}.qza \
    --m-sample-metadata-file ${METADATA} \
    --o-visualization ${TABLE}.qzv

qiime feature-table tabulate-seqs \
    --verbose \
    --i-data ${OUTPUT}/rep-seqs.qza \
    --o-visualization ${OUTPUT}/rep-seqs.qzv

    #----------------------------------------------
    # Generate a tree for phylogenetic diversity analyses
    #

    ## 1. perform a multiple sequence alignment of the sequences in our 
    ## FeatureData[Sequence] to create a FeatureData[AlignedSequence] QIIME 2 artifact.
#    docker exec $CONTAINERID \
qiime alignment mafft \
    --verbose \
    --i-sequences ${OUTPUT}/rep-seqs.qza \
    --o-alignment ${OUTPUT}/aligned-rep-seqs.qza

    ## 2. we mask (or filter) the alignment to remove positions that are highly variable.
    ## These positions are generally considered to add noise to a resulting phylogenetic tree.
#docker exec $CONTAINERID \
qiime alignment mask \
    --verbose \
    --i-alignment ${OUTPUT}/aligned-rep-seqs.qza \
    --o-masked-alignment ${OUTPUT}/masked-aligned-rep-seqs.qza

    ## 3. Next, we'll apply FastTree to generate a phylogenetic tree from the masked alignment.
   # docker exec $CONTAINERID \
qiime phylogeny fasttree \
    --verbose \
    --i-alignment ${OUTPUT}/masked-aligned-rep-seqs.qza \
    --o-tree ${OUTPUT}/unrooted-tree.qza

    ## 4. we apply midpoint rooting to place the root of the tree at the midpoint 
    ## of the longest tip-to-tip distance in the unrooted tree
#docker exec $CONTAINERID \
qiime phylogeny midpoint-root \
    --verbose \
    --i-tree ${OUTPUT}/unrooted-tree.qza \
    --o-rooted-tree ${OUTPUT}/rooted-tree.qza


date2=$(date +"%s")
diff=$(($date2-$date1))

echoerr "\n$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed.\n"

set +x
