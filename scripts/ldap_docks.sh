#!/bin/bash -e

. "${BASH_SOURCE%/*}/default_config.inc.sh"

CONTAINER_TYPES="server phpldapadmin"
CONTAINER_CNT_agent=4
CONTAINER_HOSTNAME_server='ldap'
CONTAINER_HOSTNAME_phpldapadmin='phpadminldap'

LDAP_ADMIN_PASSWORD='test'

docker_create_server()
{
    local _HOSTNAME="$1"
    shift
    
    local _LDAP_DB_DIR="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/slapd/database"
    local _LDAP_CFG_DIR="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/slapd/config"
    local _LDAP_CERT_DIR="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/certifates"
    mkdir -p "${_LDAP_DB_DIR}" "${_LDAP_CFG_DIR}" "${_LDAP_CERT_DIR}"

    docker create --name "${_HOSTNAME}" --hostname "${_HOSTNAME}" \
        -p 30389:389 \
        -p 30636:636 \
        --env LDAP_ORGANISATION="${DEFAULT_ORGANISATION}" \
        --env LDAP_DOMAIN="${DEFAULT_DOMAIN}" \
        --env LDAP_ADMIN_PASSWORD="${LDAP_ADMIN_PASSWORD}" \
        --volume "${_LDAP_DB_DIR}:/var/lib/ldap" \
        --volume "${_LDAP_CFG_DIR}:/etc/ldap/slapd.d" \
        --volume "${_LDAP_CERT_DIR}:/container/service/slapd/assets/certs" \
        --env LDAP_TLS_CRT_FILENAME="my-ldap.crt" \
        --env LDAP_TLS_KEY_FILENAME="my-ldap.key" \
        --env LDAP_TLS_CA_CRT_FILENAME="the-ca.crt" \
        "osixia/openldap:1.1.7"
    echo "docker create '${_HOSTNAME}'"
}

docker_create_phpldapadmin()
{
    local _HOSTNAME="$1"
    shift

    local _LDAP_ADMIN_CFG_DIR="${PERSISTENT_DATA_BASEDIR}/${_HOSTNAME}/config"
    mkdir -p "${_LDAP_ADMIN_CFG_DIR}"

    docker create --name "${_HOSTNAME}" --hostname "${_HOSTNAME}" \
        -p 30443:443 \
        --link "${LDAP_HOSTNAME}:ldap-host" \
        --env PHPLDAPADMIN_LDAP_HOSTS="ldap-host" \
        'osixia/phpldapadmin:0.6.12'
    echo "docker create '${_HOSTNAME}'"
#        --volume ${_LDAP_ADMIN_CFG_DIR}/my-config.php:/container/service/phpldapadmin/assets/config.php \
#        --env PHPLDAPADMIN_HTTPS=false \
}

execute "$@"
