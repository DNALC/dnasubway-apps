#!/usr/bin/env bash

# Convenience functions
echoerr() { echo -e "$@\n" 1>&2; }

if [[ "${DEBUG}" == "1" ]]; then
    set -x
fi

export -p

date1=$(date +"%s")
OUTPUT=./goutput

mkdir -p $OUTPUT

# 1 ------------------------------------------------------------

qiime gneiss add-pseudocount \
  --verbose \
  --i-table ${TABLE} \
  --p-pseudocount 1 \
  --o-composition-table $OUTPUT/composition.qza
  
#2 ------------------------------------------------------------ 

qiime gneiss correlation-clustering \
  --verbose \
  --i-table $OUTPUT/composition.qza \
  --o-clustering $OUTPUT/hierarchy.qza
  
#3 ------------------------------------------------------------

qiime gneiss ilr-transform \
  --verbose \
  --i-table $OUTPUT/composition.qza \
  --i-tree $OUTPUT/hierarchy.qza \
  --o-balances $OUTPUT/balances.qza

#4 ------------------------------------------------------------

qiime gneiss ols-regression \
  --verbose \
  --p-formula $FORMULA \
  --i-table $OUTPUT/balances.qza \
  --i-tree $OUTPUT/hierarchy.qza \
  --m-metadata-file $METADATA \
  --o-visualization $OUTPUT/regression_summary.qzv

#5 ------------------------------------------------------------

qiime gneiss dendrogram-heatmap \
  --verbose \
  --i-table $OUTPUT/composition.qza \
  --i-tree $OUTPUT/hierarchy.qza \
  --m-metadata-file $METADATA \
  --m-metadata-category $CATEGORY \
  --p-color-map seismic \
  --o-visualization $OUTPUT/heatmap-$CATEGORY.qzv

#5 ------------------------------------------------------------

qiime gneiss balance-taxonomy \
  --verbose \
  --i-balances $OUTPUT/balances.qza \
  --i-tree $OUTPUT/hierarchy.qza \
  --i-taxonomy $TAXA \
  --p-taxa-level $TAXALEVEL \
  --p-balance-name 'y0' \
  --m-metadata-file $METADATA \
  --m-metadata-category $CATEGORY \
  --o-visualization $OUTPUT/y0_taxa_summary.qzv
  
# ------------------------------------------------------------

date2=$(date +"%s")
diff=$(($date2-$date1))

echoerr "\n$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed.\n"

tar czvf goutput.tgz ${OUTPUT}/*.qzv


