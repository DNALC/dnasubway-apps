#!/usr/bin/env bash

if [ -d output ]
then
	rm -r output
fi

echo bfile=${bfile:-sample_metadata.tsv} >> envs
echo jobName=${jobName:-"test-qiime2-import"} >> envs
echo format=${format:-"casava"} >> envs
echo paired=${paired:-"false"} >> envs
echo RANDSAMPLES=${randomSamples:-8} >> envs
echo INPUT=${INPUT:-"input-data/"} >> envs
echo DEBUG=${DEBUG:-1} >> envs

docker run --name pl-import-cont --env-file envs --entrypoint run-pl-import.sh -v $PWD/output:/data/pl-import/output pl-apps

docker stop pl-import-cont
docker rm pl-import-cont

rm envs