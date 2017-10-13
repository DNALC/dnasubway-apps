#!/usr/bin/env bash

if [ -d output ]
then
	rm -r output
fi

echo files=${files:-imported.qza} >> envs
echo metadata=${metadata:-sample_metadata.tsv} >> envs
echo jobName=${jobName:-"test-qiime2-import-${RANDOM}"} >> envs
echo paired=${paired:-"false"} >> envs
echo truncLen=${truncLen:-100} >> envs
echo trimLeft=${trimLeft:-0} >> envs

docker run --name pl-denoise-cont --env-file envs --entrypoint run-pl-denoise.sh -v $PWD/output:/data/pl-denoise/output pl-apps

docker stop pl-denoise-cont
docker rm pl-denoise-cont

rm envs