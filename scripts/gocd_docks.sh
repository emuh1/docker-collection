#!/bin/bash -e

. "${BASH_SOURCE%/*}/default_config.inc.sh"

CONTAINER_TYPES="server agent"
CONTAINER_CNT_agent=4
CONTAINER_HOSTNAME_server='gocd'
CONTAINER_HOSTNAME_agent='gocd-agent'
CONTAINER_REGISTRY_server='gocd/gocd-server'
CONTAINER_REGISTRY_agent='gocd/gocd-agent'

docker_create_server()
{
    local _HOSTNAME="$1"
    shift

    local _GOCD_SERVER_DB_DIR="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/var/lib/go-server"
    local _GOCD_SERVER_LOG_DIR="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/var/log/go-server"
    local _GOCD_SERVER_CFG_DIR="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/etc/go"
    local _GOCD_SERVER_VAR_DIR="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/var/go"
    local _GOCD_SERVER_ADDONS_DIR="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/go-addons"
    mkdir -p "${_GOCD_SERVER_DB_DIR}" "${_GOCD_SERVER_CFG_DIR}" "${_GOCD_SERVER_LOG_DIR}" "${_GOCD_SERVER_VAR_DIR}" "${_GOCD_SERVER_ADDONS_DIR}"

    docker create --name "${_HOSTNAME}" --hostname "${_HOSTNAME}" \
        -p 38153:8153 \
        -p 38154:8154 \
        --link "ldap.${DEFAULT_DOMAIN}:ldap.${DEFAULT_DOMAIN}" \
        --link "svn-server.${DEFAULT_DOMAIN}:svn-server.${DEFAULT_DOMAIN}" \
        --volume "${_GOCD_SERVER_DB_DIR}:/var/lib/go-server" \
        --volume "${_GOCD_SERVER_CFG_DIR}:/etc/go" \
        --volume "${_GOCD_SERVER_LOG_DIR}:/var/log/go-server" \
        --volume "${_GOCD_SERVER_VAR_DIR}:/var/go" \
        --volume "${_GOCD_SERVER_ADDONS_DIR}:/go-addons" \
        "${CONTAINER_REGISTRY_server}"
    echo "docker create '${_HOSTNAME}'"
}

docker_create_agent()
{
    local _HOSTNAME="$1"
    shift

    local _GOCD_AGENT_DB_DIR="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/var/lib/go-agent"
    mkdir -p "${_GOCD_AGENT_DB_DIR}"

    local _GOCD_SERVER_HOSTNAME="${CONTAINER_HOSTNAME_server}.${DEFAULT_DOMAIN}"
    docker create --name "${_HOSTNAME}" --hostname "${_HOSTNAME}" \
        --link "${_GOCD_SERVER_HOSTNAME}:${_GOCD_SERVER_HOSTNAME}" \
        --link "svn-server.${DEFAULT_DOMAIN}:svn-server.${DEFAULT_DOMAIN}" \
        --env GO_SERVER_URL="https://${_GOCD_SERVER_HOSTNAME}:8154/go" \
        "${CONTAINER_HOSTNAME_agent}"
    echo "docker create '${_HOSTNAME}'"
}

execute "$@"
