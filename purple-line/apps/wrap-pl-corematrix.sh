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

echo "tree=\"${tree}\"" >> ${DOCK_ENV}
echo "table=${table}" >> ${DOCK_ENV}
echo "jobName=${jobName}" >> ${DOCK_ENV}
echo "sampling-depth=${sdepth}" >> ${DOCK_ENV}
echo "metadata=${metadata}" >> ${DOCK_ENV}

OUTPUT=./output
#mkdir -p ${OUTPUT}

if [[ "$TYPE" == "docker" ]];
then
    set -x
    CONTAINERID=$(docker run -d --env-file ${DOCK_ENV} -v $PWD:/data $DOCKER_IMG sleep 3600)
    # what if we can't create a container?!

    docker exec $CONTAINERID \
        qiime diversity core-metrics \
            --i-phylogeny ${tree} \
            --i-table ${table} \
            --p-sampling-depth ${sdepth} \
            --output-dir ${OUTPUT}
	sleep 1

    docker exec $CONTAINERID \
        qiime diversity alpha-group-significance \
            --i-alpha-diversity $OUTPUT/faith_pd_vector.qza \
            --m-metadata-file ${metadata} \
            --o-visualization ${OUTPUT}/faith-pd-group-significance.qzv

    docker exec $CONTAINERID \
        qiime diversity alpha-group-significance \
            --i-alpha-diversity ${OUTPUT}/evenness_vector.qza \
            --m-metadata-file ${metadata} \
            --o-visualization ${OUTPUT}/evenness-group-significance.qzv
    sleep 1

    docker exec $CONTAINERID \
        qiime diversity alpha-correlation \
            --i-alpha-diversity ${OUTPUT}/faith_pd_vector.qza \
            --m-metadata-file ${metadata} \
            --o-visualization ${OUTPUT}/faith-pd-correlation.qzv

    docker exec $CONTAINERID \
        qiime diversity alpha-correlation \
            --i-alpha-diversity ${OUTPUT}/evenness_vector.qza \
            --m-metadata-file  ${metadata}\
            --o-visualization ${OUTPUT}/evenness-correlation.qzva

    sleep 1

    docker exec $CONTAINERID \
        qiime diversity bioenv \
            --i-distance-matrix ${OUTPUT}/unweighted_unifrac_distance_matrix.qza \
            --m-metadata-file ${metadata} \
            --o-visualization ${OUTPUT}/unweighted-unifrac-bioenv.qzv

    docker exec $CONTAINERID \
        qiime diversity bioenv \
        --i-distance-matrix ${OUTPUT}/bray_curtis_distance_matrix.qza \
        --m-metadata-file ${metadata} \
        --o-visualization ${OUTPUT}/bray-curtis-bioenv.qzv

    sleep 1
    # emperor tool to explore PCofA plots
    docker exec $CONTAINERID \
        qiime emperor plot \
            --i-pcoa ${OUTPUT}/bray_curtis_pcoa_results.qza \
            --m-metadata-file ${metadata} \
            --o-visualization ${OUTPUT}/bray-curtis-emperor.qzv

    # perhaps we do this for each *pcoa* artifact..
    docker exec $CONTAINERID \
        qiime emperor plot \
            --i-pcoa ${OUTPUT}/unweighted_unifrac_pcoa_results.qza \
            --m-metadata-file ${metadata} \
            --o-visualization ${OUTPUT}/unweighted_unifrac-emperor.qzv

    sleep 1

    # Taxonomic analysis
    docker exec $CONTAINERID \
        qiime feature-classifier classify-sklearn \
            --i-classifier ${classifier} \
            --i-reads ${repseqs} \
            --o-classification ${OUTPUT}/taxonomy.qza

    docker exec $CONTAINERID \
        qiime taxa tabulate \
            --i-data ${OUTPUT}/taxonomy.qza \
            --o-visualization ${OUTPUT}/taxonomy.qzv

    docker exec $CONTAINERID \
        qiime taxa barplot \
            --i-table ${table} \
            --i-taxonomy ${OUTPUT}/taxonomy.qza \
            --m-metadata-file ${metadata} \
            --o-visualization ${OUTPUT}/taxa-bar-plots.qzv

    sleep 1

    # clean up
    docker stop $CONTAINERID
    docker rm $CONTAINERID

    tar czvf output.tgz ${OUTPUT}/*.qzv

    rm -v ${classifier}
    rm -rfv ${OUTPUT}/

    set +x
fi


# rm ${DOCK_ENV}*
