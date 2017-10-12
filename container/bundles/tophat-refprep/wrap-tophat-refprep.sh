#!/usr/bin/env bash

if [ "${DEBUG}" == "1" ];
then
    set -x
fi

APPNAME="tophat-refprep"
DOCKER_CONTAINER="cyverse/dnasub_apps"
SINGULARITY_CONTAINER="cyverse-dnasub_apps.img"

TYPE=${TYPE:-singularity}

# Manually, enumerate over each parameter
DOCK_ENV="_$$.env"
SING_ENV="$DOCK_ENV.singularity"

rm -rf "$DOCK_ENV*"

# inputs
echo "referenceFasta=${referenceFasta}" >> ${DOCK_ENV}
# parameters
echo "cleanupParameter=${cleanupParameter}" >> ${DOCK_ENV}
# Threads
echo "THREADS=8" >> ${DOCK_ENV}

#Container exec
DEFAULT_EP="/opt/bin/run-${APPNAME}.sh"
ENTRYPOINT=${ENTRYPOINT:-$DEFAULT_EP}
env | sort -k1 > "_$$.variables"

if [[ "$TYPE" == "docker" ]];
then
	docker run --entrypoint ${ENTRYPOINT} \
	 			--env-file ${DOCK_ENV} \
	 			-v $PWD:/home:rw ${DOCKER_CONTAINER}
fi

if [[ "$TYPE" == "singularity" ]];
then
	
	if [ -f ${SINGULARITY_CONTAINER}.bz2 ];
	then
		bunzip2 ${SINGULARITY_CONTAINER}.bz2

		# Create singularity env
		while read p; do
		  echo "export $p" >> ${SING_ENV}
		done <${DOCK_ENV}
		source ${SING_ENV}

		echo "${SINGULARITY_CONTAINER}" >> .agave.archive

		singularity exec ${SINGULARITY_CONTAINER} ${ENTRYPOINT}
	fi
	
fi

# rm ${DOCK_ENV}*

if [ "${DEBUG}" == "1" ];
then
    set +x
fi
