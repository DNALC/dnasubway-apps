#!/usr/bin/env bash

export table=test-data/table-trim2955.qza
export metadata=test-data/mappingfile_MT_corrected.tsv
export taxonomy=test-data/taxonomy.qza
export taxalevel=2
export category=Treatment  # or state or CollectionMethod ...
export formula=Treatment+state+CollectionMethod+Replicate
#or 
#formula=Treatment+state+CollectionMethod+location

DEBUG=1 ./wrap-pl-gneiss.sh && ls -l ./goutput/

tar tzvf goutput.tgz
rm -rfv ./goutput/
rm -fv ./goutput.tgz


