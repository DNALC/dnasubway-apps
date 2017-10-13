#!/usr/bin/env bash

cd /data/pl-denoise

#DEBUG=1
if [[ $DEBUG == 1 ]]; then
    set -x
fi

FILES=(${files})

for f in $(seq 0 $((${#FILES[@]} - 1))); do 
    echo -ne "${f}\t${FILES[$f]}"
done

ls -lh ./*

METADATA=${metadata}
THREADS=4
TRIMLEFT=${trimLeft:-0}
TRUNCLEN=${truncLen}

SOURCEFORMATFLAG=

OUTPUT=./output

INPUT=${FILES[0]}

qiime dada2 denoise-single \
    --verbose \
    --p-n-threads ${THREADS} \
    --i-demultiplexed-seqs $INPUT \
    --p-trim-left $TRIMLEFT \
    --p-trunc-len $TRUNCLEN \
    --o-representative-sequences ${OUTPUT}/rep-seqs.qza \
    --o-table ${OUTPUT}/table.qza

echo fors
for f in $(seq 0 $((${#FILES[@]} - 1))); do 
    echo -ne "rm -v ${FILES[$f]}"
done
for f in ${FILES[*]}; do
    echo "input files 2: ${f}"
done

qiime feature-table summarize \
    --verbose \
    --i-table ${OUTPUT}/table.qza \
    --m-sample-metadata-file ${METADATA} \
    --o-visualization ${OUTPUT}/table.qzv

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

set +x
