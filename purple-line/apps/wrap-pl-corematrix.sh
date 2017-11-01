#!/usr/bin/env bash

echo "metadata=${metadata}" >> envs
echo "jobName=${jobName}" >> envs
echo "table=${table}" >> envs
echo "tree=${tree}" >> envs
echo "repseqs=${repseqs}" >> envs
echo "classifier=${classifier}" >> envs
echo "sdepth=${sdepth}" >> envs
echo "DEBUG=1" >> envs

docker run --rm --env-file envs --entrypoint run-pl-corematrix.sh -v $PWD:/data dnasubway-pl

