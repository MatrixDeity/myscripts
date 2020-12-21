#!/usr/bin/env bash
set -e

VHOST_CONF=${HOME}/.config/myscripts/vhost.conf

function fatal {
    local message=${@}
    if [[ -n "${message}" ]]; then
        echo -e "\e[31mFATAL\e[0m: ${message}" >&2
    fi
    exit 1
}

function show_help {
    cat <<EOF
vvisit - script to connect to remote host.

Usage:
    vvisit [-t <host>] [<command>]
    vvisit -h

Options:
    -t <host>    Custom host to connect. Default: host from ${VHOST_CONF}.
    -h           Show this help.

Configs:
    ${VHOST_CONF}
EOF
}

function main {
    local vhost=$(cat ${VHOST_CONF})

    while getopts ":t:h" OPT; do
        case "${OPT}" in
            t)
                vhost=${OPTARG}
                ;;
            h)
                show_help
                exit 0
                ;;
            *)
                show_help
                exit 1
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    if [[ -z "${vhost}" ]]; then
        fatal "Pass '-t <host>' or write hostname to '${VHOST_CONF}' config"
    fi

    ssh -A "${vhost}" "${@}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
fi
