#!/bin/bash
#
# Script to create a OCI compliant image from the buildah_tweakstreet base image. The script copies all files required by the controlflow or dataflow into the relevant folders and sets the working directory to the /home/tweakstreet/flows folder.
#
# Following folders are available:
# - the Tweakstreet ETL tool root folder: /opt/tweakstreet
# - JDBC drivers need to be copied to: /home/tweakstreet/.tweakstreet/drivers
# - dataflows, control flows, modules, etc: /home/tweakstreet/flows
# - data files required by the flows are copied to: /home/tweakstreet/ 
#
# The /opt/tweakstreet/bin folder where the shell script to run flows - engine.sh - is located, is available on the path.
# 
# example to run the image:
#   podman run --rm -it tweakstreet-test01:0.1 engine.sh dataflow-test.dfl
#   or
#   docker run --rm -it tweakstreet-test01:0.1 engine.sh dataflow-test.dfl
#
# last update: uwe.geercken@web.de - 2021-01-05
#

# tweakstreet home folder in the base image
tweakstreet_home="/home/tweakstreet"

# registry to pull the base image from
image_registry="silent1:8083"
image_registry_group="silent1:8082"

# base image
base_image_name="tweakstreet-base"
base_image_version="0.1"
base_image_tag="${image_registry_group}/${base_image_name}:${base_image_version}"

# new image
image_name="tweakstreet-test01"
image_version="0.1"
image_author="uwe.geercken@web.de"

# name of working container
working_container="${image_name}-working-container"

# local folders, from where the source files are copied
flows_folder="flows"
data_folder="data"
drivers_folder="drivers"

# container folders (drivers folder is for JDBC drivers)
tweakstreet_flows="${tweakstreet_home}/flows"
tweakstreet_data="${tweakstreet_home}/data"
tweakstreet_drivers="${tweakstreet_home}/.tweakstreet/drivers"

# start of build

# create the working container
container=$(buildah --name "${working_container}" from ${base_image_tag})

# copy required files
buildah copy $container "${flows_folder}/" "${tweakstreet_flows}"
buildah copy $container "${data_folder}/" "${tweakstreet_data}"
buildah copy $container "${drivers_folder}/" "${tweakstreet_drivers}"

# configuration
buildah config --author "${image_author}" $container
buildah config --workingdir "${tweakstreet_flows}" $container

# commit container, create image
buildah commit $container "${image_name}:${image_version}"

# remove working container
buildah rm $container

