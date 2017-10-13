#!/usr/bin/env bash

if [ -d output ]
then
	rm -r output
fi 

echo metadata=${metadata:-sample_metadata.tsv} >> envs
echo jobName=${jobName:-"test-qiime2-corematrix"} >> envs
echo table=${table:-table.qza} >> envs
echo tree=${tree:-"rooted-tree.qza"} >> envs
echo repseqs=${repseqs:-"rep-seqs.qza"} >> envs
echo classifier=${classifier:-"gg-13-8-99-515-806-nb-classifier.qza"} >> envs
echo sdepth=${sdepth:-1080} >> envs

docker run --name pl-corematrix-cont --env-file envs --entrypoint run-pl-corematrix.sh -v $PWD/output:/data/pl-corematrix/ouput pl-apps

docker stop pl-corematrix-cont 
docker rm pl-corematrix-cont 

rm envs