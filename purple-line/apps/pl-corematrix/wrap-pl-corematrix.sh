#!/usr/bin/env bash

echo metadata=${metadata:-sample_metadata.tsv} >> envs
echo jobName=${jobName:-"test-qiime2-corematrix"} >> envs
echo table=${table:-table.qza} >> envs
echo tree=${tree:-"rooted-tree.qza"} >> envs
echo repseqs=${repseqs:-"rep-seqs.qza"} >> envs
echo classifier=${classifier:-"gg-13-8-99-515-806-nb-classifier.qza"} >> envs
echo sdepth=${sdepth:-1080} >> envs
echo DEBUG=1 >> envs

docker run --rm --env-file envs --entrypoint run-pl-corematrix.sh -v $PWD:/data/pl-corematrix pl-apps

# rm envs