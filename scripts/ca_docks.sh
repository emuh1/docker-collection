#!/bin/bash -e


. "${BASH_SOURCE%/*}/default_config.inc.sh"

CONTAINER_TYPES="caroot casubor nginx"
CONTAINER_HOSTNAME_caroot='CAROOT'
CONTAINER_HOSTNAME_casubor='CASUBOR'
CONTAINER_HOSTNAME_nginx='NGINX'

docker_create_caroot()
{
    local _HOSTNAME="$1"
    shift

    docker create --name "${_HOSTNAME}" jordi/caroot
    echo "docker create ${_HOSTNAME}"
}

docker_create_casubor()
{
    local _HOSTNAME="$1"
    shift

    docker create --name "${_HOSTNAME}" jordi/casubor
    echo "docker create ${_HOSTNAME}"
}

docker_create_nginx()
{
    local _HOSTNAME="$1"
    shift

    docker create --name "${_HOSTNAME}" -p 443:443 jordi/nginx
    echo "docker create ${_HOSTNAME}"
}

execute "$@"
