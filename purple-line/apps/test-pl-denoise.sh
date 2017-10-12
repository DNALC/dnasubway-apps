#!/usr/bin/env bash

#DIR=$(dirname $0)
#cd $DIR

## single-end
cp /data/scratch/ghiban/job-4274450477120744985-242ac115-0001-007-emp-single-end-test/imported.qza .

## paired-end
#cp /data/cornel/qiime2-data/paired-data/test/*.gz .

cp /data/scratch/ghiban/job-4274450477120744985-242ac115-0001-007-emp-single-end-test/sample_metadata.tsv .

export files=imported.qza
export metadata=sample_metadata.tsv
export jobName="test-qiime2-import-${RANDOM}"
export paired="false"         # true or false
export truncLen=100
export trimLeft=0

DEBUG=0 TYPE=docker ./wrap-pl-denoise.sh

#&& sleep 1 && rm -rf fastx_out && rm -f _* .agave.archive
