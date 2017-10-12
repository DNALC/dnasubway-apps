#!/usr/bin/env bash

#DIR=$(dirname $0)
#cd $DIR

rm -rf ./input-data/

## single-end
cp /data/cornel/qiime2-data/paired-data/test/*R1*.gz .

## paired-end
#cp /data/cornel/qiime2-data/paired-data/test/*.gz .

#emp single-end
#cp -v emp-data/single-end/* .

#emp paired-end
#cp -v emp-data/paired-end/* .


#export files=$(ls -1 *R1* | tr '\n' ','|sed -e 's/,$//')
export bfile=sample_metadata.tsv
export jobName="test-qiime2-import"
export format="casava"      # casava-1.8 or emp
export paired="false"         # true or false
export randomSamples=       # integer

DEBUG=1 TYPE=docker ./wrap-pl-import.sh && ls -l

#&& sleep 1 && rm -rf fastx_out && rm -f _* .agave.archive
