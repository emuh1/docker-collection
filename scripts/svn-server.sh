#!/bin/bash -e

. "${BASH_SOURCE%/*}/default_config.inc.sh"

CONTAINER_TYPES="server"
CONTAINER_HOSTNAME_server='svn-server'

docker_create()
{
    local _HOSTNAME="$1"
    shift
    
    local _SVN_DATA="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/data"
    mkdir -p "${_SVN_DATA}"

    docker create --name "${_HOSTNAME}" --hostname "${_HOSTNAME}" \
        -p 33690:3690 \
        --volume "${_SVN_DATA}:/var/opt/svn" \
        neoalienson/svn-server-sandbox
    echo "docker create '${_HOSTNAME}'"
}
docker_init()
{
    local _HOSTNAME="$1"
    shift

    docker start ${_HOSTNAME}
    docker exec -it ${_HOSTNAME} \
        svnadmin create sandbox
    docker exec -it ${_HOSTNAME} \
        svn mkdir \
        file:///var/opt/svn/sandbox/tags \
        file:///var/opt/svn/sandbox/branches \
        file:///var/opt/svn/sandbox/trunk \
        -m 'inital structure'

}

execute "$@"
