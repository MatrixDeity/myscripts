#!/usr/bin/env bash
set -e

VHOST_CONF=${HOME}/.config/myscripts/vhost.conf

function fatal {
    local message=${1}
    if [[ -n "${message}" ]]; then
        echo -e "\e[31mFATAL\e[0m: ${message}" >&2
    fi
    exit 1
}

function show_help {
    cat <<EOF
vvisit - script to connect to remote host.

Usage:
    vvisit [<command>]
    vvisit -h

Options:
    -h    Show this help.

Configs:
    ${VHOST_CONF}
EOF
}

function main {
    local vhost=$(cat ${VHOST_CONF})

    if [[ -z "${vhost}" ]]; then
        fatal "Write hostname to '${VHOST_CONF}' config"
    fi

    while getopts ":h" OPT; do
        case "${OPT}" in
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

    ssh -A "${vhost}" "${@}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
fi
