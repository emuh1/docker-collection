#!/bin/bash -e

. "${BASH_SOURCE%/*}/default_config.inc.sh"

CONTAINER_TYPES="docker_registry"
CONTAINER_HOSTNAME_docker_registry='docker-registry'
CONTAINER_REGISTRY_docker_registry='registry:2'

docker_create()
{
    local _HOSTNAME="$1"
    shift
    
    local _REGISTRY_DATA="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/registry"
    mkdir -p "${_REGISTRY_DATA}"

    docker create --name "${_HOSTNAME}" --hostname "${_HOSTNAME}" \
        -p 35000:5000 \
        --volume "${_REGISTRY_DATA}:/var/lib/registry" \
        "${CONTAINER_REGISTRY_docker_registry}"
    echo "docker create '${_HOSTNAME}'"
}

execute "$@"
