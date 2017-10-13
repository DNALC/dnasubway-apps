#!/usr/bin/env bash

cd /data/pl-corematrix

DEBUG=1
if [[ $DEBUG == 1 ]]; then
    set -x
fi

OUTPUT=./ouput

qiime diversity core-metrics \
    --i-phylogeny ${tree} \
    --i-table ${table} \
    --p-sampling-depth ${sdepth} \
    --output-dir ${OUTPUT}/

qiime diversity alpha-group-significance \
    --i-alpha-diversity $OUTPUT/faith_pd_vector.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
    --i-alpha-diversity ${OUTPUT}/evenness_vector.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/evenness-group-significance.qzv

qiime diversity alpha-correlation \
    --i-alpha-diversity ${OUTPUT}/faith_pd_vector.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/faith-pd-correlation.qzv

qiime diversity alpha-correlation \
    --i-alpha-diversity ${OUTPUT}/evenness_vector.qza \
    --m-metadata-file  ${metadata}\
    --o-visualization ${OUTPUT}/evenness-correlation.qzva

qiime diversity bioenv \
    --i-distance-matrix ${OUTPUT}/unweighted_unifrac_distance_matrix.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/unweighted-unifrac-bioenv.qzv

qiime diversity bioenv \
--i-distance-matrix ${OUTPUT}/bray_curtis_distance_matrix.qza \
--m-metadata-file ${metadata} \
--o-visualization ${OUTPUT}/bray-curtis-bioenv.qzv

qiime emperor plot \
    --i-pcoa ${OUTPUT}/bray_curtis_pcoa_results.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/bray-curtis-emperor.qzv

qiime emperor plot \
    --i-pcoa ${OUTPUT}/unweighted_unifrac_pcoa_results.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/unweighted_unifrac-emperor.qzv

# Taxonomic analysis
qiime feature-classifier classify-sklearn \
    --i-classifier ${classifier} \
    --i-reads ${repseqs} \
    --o-classification ${OUTPUT}/taxonomy.qza

qiime taxa tabulate \
    --i-data ${OUTPUT}/taxonomy.qza \
    --o-visualization ${OUTPUT}/taxonomy.qzv

qiime taxa barplot \
    --i-table ${table} \
    --i-taxonomy ${OUTPUT}/taxonomy.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/taxa-bar-plots.qzv

tar czvf output.tgz ${OUTPUT}/*.qzv

rm -v ${classifier}

mv ouput/* output/

set +x
