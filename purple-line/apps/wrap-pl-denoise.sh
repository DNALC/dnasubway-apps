#!/usr/bin/env bash

#DEBUG=1
if [[ $DEBUG == 1 ]]; then
    set -x
fi

APPNAME="pl-denoise"
DOCKER_IMG="qiime2/core:2017.4"

TYPE=${TYPE:-docker}

# Manually, enumerate over each parameter
DOCK_ENV="_$$.env"
SING_ENV="$DOCK_ENV.singularity"
rm -rf "$DOCK_ENV*"

echo "files=(${files})" >> ${DOCK_ENV}
echo "metadata=${metadata}" >> ${DOCK_ENV}
echo "jobName=${jobName}" >> ${DOCK_ENV}
echo "paired=${paired}" >> ${DOCK_ENV}
echo "truncLen=${truncLen}" >> ${DOCK_ENV}
echo "trimLeft=${trimLeft}" >> ${DOCK_ENV}

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
mkdir -p ${OUTPUT}

#if [[ ${paired} == 1 ]] || [[ ${paired} == "true" ]]; then
#    # do x
#else
#    # do y
#fi


if [[ "$TYPE" == "docker" ]];
then
    set -x
    CONTAINERID=$(docker run -d --env-file ${DOCK_ENV} -v $PWD:/data $DOCKER_IMG sleep 18000) # 5 hours
    # what if we can't create a container?!

    # need to do this for every input file, then merge (if needed)
    INPUT=${FILES[0]}

    docker exec $CONTAINERID \
        qiime dada2 denoise-single \
            --verbose \
            --p-n-threads ${THREADS} \
            --i-demultiplexed-seqs $INPUT \
            --p-trim-left $TRIMLEFT \
            --p-trunc-len $TRUNCLEN \
            --o-representative-sequences ${OUTPUT}/rep-seqs.qza \
            --o-table ${OUTPUT}/table.qza

    # TODO - rm the actual input files
    for f in $(seq 0 $((${#FILES[@]} - 1))); do 
        echo -ne "rm -v ${FILES[$f]}"
        #rm -v ${f}\t${FILES[$f]}
    done
    for f in ${FILES[*]}; do
        echo "input files 2: ${f}"
    done

    docker exec $CONTAINERID \
        qiime feature-table summarize \
            --verbose \
            --i-table ${OUTPUT}/table.qza \
            --m-sample-metadata-file ${METADATA} \
            --o-visualization ${OUTPUT}/table.qzv

    docker exec $CONTAINERID \
        qiime feature-table tabulate-seqs \
            --verbose \
            --i-data ${OUTPUT}/rep-seqs.qza \
            --o-visualization ${OUTPUT}/rep-seqs.qzv

    #----------------------------------------------
    # Generate a tree for phylogenetic diversity analyses
    #

    ## 1. perform a multiple sequence alignment of the sequences in our 
    ## FeatureData[Sequence] to create a FeatureData[AlignedSequence] QIIME 2 artifact.
    docker exec $CONTAINERID \
        qiime alignment mafft \
            --verbose \
            --i-sequences ${OUTPUT}/rep-seqs.qza \
            --o-alignment ${OUTPUT}/aligned-rep-seqs.qza

    ## 2. we mask (or filter) the alignment to remove positions that are highly variable.
    ## These positions are generally considered to add noise to a resulting phylogenetic tree.
    docker exec $CONTAINERID \
        qiime alignment mask \
            --verbose \
            --i-alignment ${OUTPUT}/aligned-rep-seqs.qza \
            --o-masked-alignment ${OUTPUT}/masked-aligned-rep-seqs.qza

    ## 3. Next, we'll apply FastTree to generate a phylogenetic tree from the masked alignment.
    docker exec $CONTAINERID \
        qiime phylogeny fasttree \
            --verbose \
            --i-alignment ${OUTPUT}/masked-aligned-rep-seqs.qza \
            --o-tree ${OUTPUT}/unrooted-tree.qza

    ## 4. we apply midpoint rooting to place the root of the tree at the midpoint 
    ## of the longest tip-to-tip distance in the unrooted tree
    docker exec $CONTAINERID \
        qiime phylogeny midpoint-root \
            --verbose \
            --i-tree ${OUTPUT}/unrooted-tree.qza \
            --o-rooted-tree ${OUTPUT}/rooted-tree.qza

    sleep 1

    # clean up
    docker stop $CONTAINERID
    docker rm $CONTAINERID

    set +x
fi


# rm ${DOCK_ENV}*
