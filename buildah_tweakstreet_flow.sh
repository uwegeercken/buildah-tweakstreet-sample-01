#!/bin/bash

tweakstreet_home="/home/tweakstreet"

image_registry="silent1:8083"
image_registry_group="silent1:8082"
image_registry_user="admin"

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

# local folder containing flows, modules, etc.
flows_folder="flows"

# container folder for flows, modules, etc.
tweakstreet_flows="${tweakstreet_home}/flows"

# local folder containing JDBC drivers
drivers_folder="drivers"

# container folder for JDBC drivers
tweakstreet_drivers="${tweakstreet_home}/.tweakstreet/drivers"

# start of build
container=$(buildah --name "${working_container}" from ${base_image_tag})

# copy required files
buildah copy $container "${flows_folder}/" "${tweakstreet_flows}"
buildah copy $container "${drivers_folder}/" "${tweakstreet_drivers}"

# configuration
buildah config --author "${image_author}" $container
buildah config --workingdir "${application_folder_root}" $container

buildah commit $container "${image_name}:${image_version}"
buildah rm $container

