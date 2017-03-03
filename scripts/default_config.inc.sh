#!/bin/bash

#CONTAINER_TYPES
#CONTAINER_CNT_{type}
#CONTAINER_HOSTNAME_{type}
#DEFAULT_DOMAIN
#docker_{cmd}[_{type}]

DEFAULT_ORGANISATION='Emuhs Playbook'
DEFAULT_DOMAIN='emuhs-playbook.net'
PERSISTENT_DATA_BASEDIR="${HOME}/docker/containers/data"
mkdir -p "${PERSISTENT_DATA_BASEDIR}"

docker_bash()
{
    local _HOSTNAME="$1"
    shift
    
    echo "docker bash ${_HOSTNAME}"
    docker 'exec' -ti "${@}" "${_HOSTNAME}" 'bash'
}

docker_status()
{
    local _HOSTNAME="$1"
    shift

    echo "docker status ${_HOSTNAME}"
    printProp "${_HOSTNAME}" 'status'
    printProp "${_HOSTNAME}" 'ip'
}

echoDebug()
{
    [[ -n "${DEBUG}" ]] && echo "DEBUG: $*" || :
}

printProp()
{
    local _NAME="$1"
    local _ITEM="$2"

    if [[ -z "${_NAME}" ]]
    then
        echo "ERROR: No name given"
        exit 1
    fi

    printf '%-40s: ' "${_NAME}"
    case "${_ITEM}" in
        'ip')
            local _SEARCH_STRING='.NetworkSettings.IPAddress'
            ;;
        'status')
            local _SEARCH_STRING='.State.Status'
            ;;
        '')
            docker inspect "${_NAME}"
            ;;
        *)
            echo "ERROR: Unknown item given"
            exit 1           
            ;;
    esac

    docker inspect -f "{{${_SEARCH_STRING}}}" "${_NAME}"
}

callFuncNameByType()
{
    local _CMD="$1"
    local _TYPE="$2"
    local _HOSTNAME="$3"
    shift
    shift
    shift

    for _FUNC_NAME in "docker_${_CMD}_${_TYPE}" "docker_${_CMD}"
    do
        if declare -f ${_FUNC_NAME} > /dev/null
        then
            echoDebug "invoking '${_FUNC_NAME} ${_HOSTNAME} $*'"
            # The first argument needs to be the name, the rest is passed to docker as args
            "${_FUNC_NAME}" "${_HOSTNAME}" "$@"
            return 0
        fi
    done

    echo "docker ${_CMD} ${_HOSTNAME}"
    echoDebug "invoking 'docker ${_CMD} $* ${_HOSTNAME}'"
    docker "${_CMD}" "$@" "${_HOSTNAME}"
}

execute()
{
    if [[ $# -lt 1 ]] 
    then
        echo "ERROR: no command given"
        exit 1
    fi

    local _CMD="$1"
    shift

    if [[ -z ${CONTAINER_TYPES} ]]
    then
        echo "ERROR: no container type was specified"
    fi

    if [[ "${CONTAINER_TYPES/$1/}" != "${CONTAINER_TYPES}" ]]
    then
        local _ACTIVE_CONTAINER_TYPES="$1"
        shift
    else
        local _ACTIVE_CONTAINER_TYPES="${CONTAINER_TYPES}"
    fi
    
    for _CONTAINER_TYPE in ${_ACTIVE_CONTAINER_TYPES}
    do
        local _START_CNT=1
        local _CONTAINER_TYPE_CNT_NAME="CONTAINER_CNT_${_CONTAINER_TYPE}"
        if [[ -n "${!_CONTAINER_TYPE_CNT_NAME}" ]]
        then
            local _CNT="${!_CONTAINER_TYPE_CNT_NAME}"
            local _ONLY_ONE=false
        else
            local _CNT=1
            local _ONLY_ONE=true
        fi
        if [[ "${1#[1-9]}" != "$1" ]]
        then
            local _START_CNT="$1"
            local _CNT="$1"
            echoDebug "Index '$1' specified"
            shift
        fi
        for((_INDEX=${_START_CNT}; _INDEX<=_CNT; _INDEX++))
        do
            local _HOSTNAME_BASE_NAME="CONTAINER_HOSTNAME_${_CONTAINER_TYPE}"
            [[ ${_ONLY_ONE} == true ]] && local _HOSTNAME_INDEX_EXT="" || local _HOSTNAME_INDEX_EXT="${_INDEX}"
            local _HOSTNAME="${!_HOSTNAME_BASE_NAME}${_HOSTNAME_INDEX_EXT}.${DEFAULT_DOMAIN}"

            echoDebug "Processing command ${_CMD} ${_HOSTNAME} of type ${_CONTAINER_TYPE}"
            callFuncNameByType "${_CMD}" "${_CONTAINER_TYPE}" "${_HOSTNAME}" "$@"
        done
    done
}
