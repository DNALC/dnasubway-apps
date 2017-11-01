#!/usr/bin/env bash

# Convenience functions
echoerr() { echo -e "$@\n" 1>&2; }
if [[ "${DEBUG}" == "1" ]]; then
    set -x
fi

date1=$(date +"%s")
OUTPUT=./output

qiime diversity core-metrics \
    --verbose \
    --i-phylogeny ${tree} \
    --i-table ${table} \
    --p-sampling-depth ${sdepth} \
    --output-dir ${OUTPUT}/

qiime diversity alpha-group-significance \
    --verbose \
    --i-alpha-diversity $OUTPUT/faith_pd_vector.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
    --verbose \
    --i-alpha-diversity ${OUTPUT}/evenness_vector.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/evenness-group-significance.qzv

qiime diversity alpha-correlation \
    --verbose \
    --i-alpha-diversity ${OUTPUT}/faith_pd_vector.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/faith-pd-correlation.qzv

qiime diversity alpha-correlation \
    --verbose \
    --i-alpha-diversity ${OUTPUT}/evenness_vector.qza \
    --m-metadata-file  ${metadata}\
    --o-visualization ${OUTPUT}/evenness-correlation.qzva

qiime diversity bioenv \
    --verbose \
    --i-distance-matrix ${OUTPUT}/unweighted_unifrac_distance_matrix.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/unweighted-unifrac-bioenv.qzv

qiime diversity bioenv \
    --verbose \
    --i-distance-matrix ${OUTPUT}/bray_curtis_distance_matrix.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/bray-curtis-bioenv.qzv

qiime emperor plot \
    --verbose \
    --i-pcoa ${OUTPUT}/bray_curtis_pcoa_results.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/bray-curtis-emperor.qzv

qiime emperor plot \
    --verbose \
    --i-pcoa ${OUTPUT}/unweighted_unifrac_pcoa_results.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/unweighted_unifrac-emperor.qzv

# Taxonomic analysis
qiime feature-classifier classify-sklearn \
    --verbose \
    --i-classifier ${classifier} \
    --i-reads ${repseqs} \
    --o-classification ${OUTPUT}/taxonomy.qza

qiime taxa barplot \
    --verbose \
    --i-table ${table} \
    --i-taxonomy ${OUTPUT}/taxonomy.qza \
    --m-metadata-file ${metadata} \
    --o-visualization ${OUTPUT}/taxa-bar-plots.qzv

qiime metadata tabulate \
    --verbose \
    --m-input-file ${OUTPUT}/taxonomy.qza \
    --o-visualization ${OUTPUT}/taxonomy.qzv


date2=$(date +"%s")
diff=$(($date2-$date1))

echoerr "\n$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed.\n"

tar czvf output.tgz ${OUTPUT}/*.qzv


rm -v ${classifier}

# mv ouput/* output/

if [[ "${DEBUG}" == "1" ]]; then
    set +x
fi
