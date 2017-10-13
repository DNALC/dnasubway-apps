#!/usr/bin/env bash

rm -rfv ./output/

# copy input files
#cp emp-data/single-end/rooted-tree.qza .
#cp emp-data/single-end/table.qza .
#cp emp-data/single-end/sample_metadata.tsv .

export metadata=sample_metadata.tsv
export jobName="test-qiime2-corematrix"
export table=table.qza
export tree=rooted-tree.qza
export repseqs=rep-seqs.qza
export classifier=gg-13-8-99-515-806-nb-classifier.qza

export sdepth=1080

DEBUG=1 TYPE=docker ./wrap-pl-corematrix.sh && ls -l

#&& sleep 1 && rm -rf fastx_out && rm -f _* .agave.archive
