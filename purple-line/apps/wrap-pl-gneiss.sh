#!/usr/bin/env bash

#input data and parameters
echo "TABLE=${table}" > envs
echo "METADATA=${metadata}" >> envs
echo "TAXA=${taxonomy}" >> envs
echo "TAXALEVEL=${taxalevel}" >> envs
echo "CATEGORY=${category}" >> envs
echo "FORMULA=${formula}" >> envs
echo "DEBUG=1" >> envs

docker run --rm --env-file envs --entrypoint /opt/bin/run-pl-gneiss.sh -v $PWD:/data dnasubway-pl

