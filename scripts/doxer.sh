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
    doxer (clean|login|ps)
    doxer (pull|start|stop) <service>
    doxer -h

Commands:
    clean        Remove artifacts of docker.
    login        Login to DockerHub as user from ${USERNAME_CONF}.
    logs         Print logs of service to stdout.
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

function ensure_dockerd {
    if docker info &>/dev/null; then
        return
    fi
    status "Docker daemon is not running. Try to run..."
    sudo service docker start
    status "Docker daemon is running now"
}

function login {
    local username=${1}
    docker login --username ${username}
}

function ps {
    docker ps --all
}

function pull {
    local service=${1}
    local username=${2}
    docker pull ${username}/${service}:latest
}

function start {
    local service=${1}
    local username=${2}
    docker run --detach --name ${service} --env-file ${ENV_LIST_CONF} --restart unless-stopped ${username}/${service}:latest
}

function stop {
    local service=${1}
    docker stop ${service}
}

function clean {
    docker system prune
}

function rm_old_container {
    local service=${1}
    local stopped_container=$(docker ps --quiet --all --filter "status=exited" --filter "name=${service}")
    if [[ -n "${stopped_container}" ]]; then
        status "Remove old container before running new one..."
        docker rm --force ${service}
    fi
}

function logs {
    local service=${1}
    docker logs ${service}
}

function main {
    local command=${1}
    local service=${2}

    local username=$(cat ${USERNAME_CONF})
    local env_list=$(cat ${ENV_LIST_CONF})

    ensure_dockerd

    case ${command} in
        clean)
            clean
            ;;
        login)
            login ${username}
            status "Login to DockerHub succeeded"
            ;;
        logs)
            check_service_passed ${service}
            logs ${service}
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
            rm_old_container ${service}
            start ${service} ${username}
            status "Service '${service}' is running now"
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
