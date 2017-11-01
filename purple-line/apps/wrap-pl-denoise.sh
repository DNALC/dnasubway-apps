#!/usr/bin/env bash

echo "files=${files}" >> envs
echo "metadata=${metadata}" >> envs
echo "jobName=${jobName}" >> envs
echo "paired=${paired}" >> envs
echo "truncLen=${truncLen}" >> envs
echo "trimLeft=${trimLeft}" >> envs
echo "DEBUG=1" >> envs

docker run --rm --env-file envs --entrypoint /opt/bin/run-pl-denoise.sh -v $PWD:/data dnasubway-pl

