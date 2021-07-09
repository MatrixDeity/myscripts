#!/usr/bin/env bash
set -e

ENV_LIST_CONF=${HOME}/.config/myscripts/doxer_env_list.conf
USERNAME_CONF=${HOME}/.config/myscripts/doxer_username.conf

function fatal {
    local message=${@}
    if [[ -n "${message}" ]]; then
        echo -e "\e[31mFATAL\e[0m: ${message}" >&2
    fi
    exit 1
}

function status {
    local message=${@}
    echo -e "\e[33mSTATUS\e[0m: ${message}"
}

function show_help {
    cat <<EOF
doxer - wrapper of popular docker commands for services deploy.

Usage:
    doxer (login|ps)
    doxer (pull|start|stop) <service>
    doxer -h

Commands:
    login        Login to DockerHub as user from ${USERNAME_CONF}.
    ps           List all docker containers.
    pull         Pull image of passed service.
    start        Run service.
    stop         Stop service.

Options:
    -h           Show this help.

Configs:
    ${ENV_LIST_CONF}
    ${USERNAME_CONF}
EOF
}

function check_service_passed {
    local service=${1}
    if [[ -z "${service}" ]]; then
        fatal "Pass service name after command"
    fi
}

function login {
    local username=${1}
    docker login -u ${username}
}

function ps {
    docker ps -a
}

function pull {
    local service=${1}
    local username=${2}
    docker pull ${username}/${service}:latest
}

function start {
    local service=${1}
    local username=${2}
    docker run --detach --rm --name ${service} --env-file ${ENV_LIST_CONF} ${username}/${service}:latest
}

function stop {
    local service=${1}
    docker stop ${service}
}

function main {
    local command=${1}
    local service=${2}

    local username=$(cat ${USERNAME_CONF})
    local env_list=$(cat ${ENV_LIST_CONF})

    case ${command} in
        login)
            login ${username}
            status "Login to DockerHub succeeded"
            ;;
        ps)
            ps
            ;;
        pull)
            check_service_passed ${service}
            pull ${service} ${username}
            status "Pulling of '${service}' service completed"
            ;;
        start)
            check_service_passed ${service}
            start ${service} ${username}
            status "Service '${service}' is running"
            ;;
        stop)
            check_service_passed ${service}
            stop ${service}
            status "Service '${service}' stopped"
            ;;
        -h)
            show_help
            exit 0
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
fi
