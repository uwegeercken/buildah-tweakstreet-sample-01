#!/bin/bash
#
# Script to create a OCI compliant image from the buildah_tweakstreet base image. The script copies all files required by the controlflow or dataflow into the relevant folders.
#
# Following folders are available in the image:
# - the Tweakstreet ETL tool root folder: /opt/tweakstreet
# - JDBC drivers are copied to: /home/tweakstreet/.tweakstreet/drivers
# - dataflows, control flows, modules, etc are copied to: /home/tweakstreet/flows
# - data files required by the flows are copied to: /home/tweakstreet/data
#
# Specify the main flow to run relativ to the path defined by the variable: tweakstreet_flows. Parameters can be defined multiple times.
#
#
# last update: uwe.geercken@web.de - 2022-01-07

usage() {
	echo "script to build an image from the tweakstreet-base image"
	echo "arguments:"
	echo "  mandatory. -f <main flow to run>"
	echo "  optional.  -g <global module to use>. no default value"
	echo "  optional.  -p \"<parameter name> <parameter value>\". no default value"
	echo "  optional.  -r <image registry to pull base image from>. default=localhost"
	echo
	echo "example: ./buildah_tweakstreet_flow.sh -m mainflow.dfl -g module.tsm -p \"param1 test\""

}

if [[ "$#" -eq 0 ]] || [[ "$1" = "-h" ]]; then
	usage
	exit 1
fi

while getopts :g:f:r:p: option
do
    case "${option}"
        in
        g)
					global_module="-g ${OPTARG}"
					;;
        f)
					main_flow=${OPTARG}
					;;
				r)
					registry=${OPTARG}
					;;
				p)
					parameters="$parameters -p ${OPTARG}"
					;;
				:)
      		echo "error: option -${OPTARG} requires an argument."
      		exit 1
      		;;
    		*)
					echo "error: unknown option -${OPTARG}"
      		exit 1
      		;;
    esac
done

if [[ -z "${main_flow}" ]]; then
		echo "error: filename of the main flow to run must be specified"
		exit 1
fi

# tweakstreet engine script
engine_script="engine.sh"
engine_script_arguments="$parameters ${global_module} ${main_flow}"

# tweakstreet folders in the base image
tweakstreet_home="/home/tweakstreet"
tweakstreet_flows="${tweakstreet_home}/flows"
tweakstreet_data="${tweakstreet_home}/data"

# folder for JDBC drivers
tweakstreet_drivers="${tweakstreet_home}/.tweakstreet/drivers"

# registry to pull the base image from - default localhost
image_registry="${registry:-localhost}"

# base image to use
base_image_name="tweakstreet-base"
base_image_version="0.3"
base_image_tag="${image_registry}/${base_image_name}:${base_image_version}"

# new image to construct
image_name="tweakstreet-test01"
image_version="0.1"
image_author="uwe.geercken@web.de"

# name of working container
working_container="${image_name}-working-container"

# local folders, from where the source files are copied into the new image
flows_folder="flows"
data_folder="data"
drivers_folder="drivers"

# start of build

# create the working container
container=$(buildah --name "${working_container}" from ${base_image_tag})

# copy required source files
buildah copy $container "${flows_folder}/" "${tweakstreet_flows}"
buildah copy $container "${data_folder}/" "${tweakstreet_data}"
buildah copy $container "${drivers_folder}/" "${tweakstreet_drivers}"

# configuration
buildah config --author "${image_author}" $container

# cmd to run when container starts
buildah config --cmd "${engine_script} ${engine_script_arguments}" $container

# commit container, create image
buildah commit $container "${image_name}:${image_version}"

# remove working container
buildah rm $container
