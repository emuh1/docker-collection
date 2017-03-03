#!/bin/bash -e

. "${BASH_SOURCE%/*}/default_config.inc.sh"

CONTAINER_TYPES="gogs"
CONTAINER_HOSTNAME_gogs='gogs'

docker_create_gogs()
{
    local _HOSTNAME="$1"
    shift
    
    local _GOGS_DATA="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/data"
    mkdir -p "${_GOGS_DATA}"

    docker create --name "${_HOSTNAME}" --hostname "${_HOSTNAME}" \
        -p 30022:22 \
        -p 33000:3000 \
        --volume "${_GOGS_DATA}:/data" \
        "gogs/gogs"
    echo "docker create '${_HOSTNAME}'"
}

execute "$@"
