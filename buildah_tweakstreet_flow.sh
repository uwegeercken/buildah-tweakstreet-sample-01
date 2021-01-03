#!/bin/bash

tweakstreet_home="/home/tweakstreet"

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

# local folders
flows_folder="flows"
data_folder="data"
drivers_folder="drivers"

# container folders (drivers for JDBC drivers)
tweakstreet_flows="${tweakstreet_home}/flows"
tweakstreet_data="${tweakstreet_home}/data"
tweakstreet_drivers="${tweakstreet_home}/.tweakstreet/drivers"

# start of build
container=$(buildah --name "${working_container}" from ${base_image_tag})

# copy required files
buildah copy $container "${flows_folder}/" "${tweakstreet_flows}"
buildah copy $container "${data_folder}/" "${tweakstreet_data}"
buildah copy $container "${drivers_folder}/" "${tweakstreet_drivers}"

# configuration
buildah config --author "${image_author}" $container
buildah config --workingdir "${tweakstreet_flows}" $container

buildah commit $container "${image_name}:${image_version}"
buildah rm $container

