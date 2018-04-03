#!/usr/bin/env bash

mkdir input-data/
export INPUT=./input-data/

find . -name \*.fastq.gz -exec mv -v {} $INPUT \;
chmod -R a+rw $INPUT

echo "bfile=${bfile}" >> envs
echo "jobName=${jobName}" >> envs
echo "format=${format}" >> envs
echo "paired=${paired}" >> envs
echo "RANDSAMPLES=${randomSamples}" >> envs
echo "INPUT=${INPUT}" >> envs
echo "DEBUG=${DEBUG}" >> envs

docker run --rm --env-file envs --entrypoint /opt/bin/run-pl-import.sh -v $PWD:/data dnasubway-pl-201712

