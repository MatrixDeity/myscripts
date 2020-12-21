#!/usr/bin/env bash
set -e

EXCLUDES_CONF=${HOME}/.config/myscripts/vsync_excludes.conf
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
vsync - script to synchronize remote files with local ones.

Usage:
    vsync [-o <target>] [-t <host>] [-r] [<source>]
    vsync -h

Options:
    -o <target>    Custom target directory for forwarded files. Default: same as <source>.
    -t <host>      Custom host to connect. Default: host from ${VHOST_CONF}.
    -r             Reverse mode: synchronize local files with remote ones.
    -h             Show this help.

Configs:
    ${VHOST_CONF}
    ${EXCLUDES_CONF}
EOF
}

function make_rsync_params {
    local params="--delete --links"
    local excludes="$(cat ${EXCLUDES_CONF})"
    for exclude in ${excludes//\*/\\\*}; do
        params="${params} --exclude=${exclude//\\\*/\*}"
    done
    echo "${params}"
}

function main {
    local vhost=$(cat ${VHOST_CONF})

    while getopts ":o:t:rh" OPT; do
        case $OPT in
            o)
                local custom_target=${OPTARG}
                ;;
            t)
                vhost=${OPTARG}
                ;;
            r)
                local reverse_mode=1
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
    shift $(($OPTIND - 1))

    if [[ -z "${vhost}" ]]; then
        fatal "Pass '-t <host>' or write hostname to '${VHOST_CONF}' config"
    fi

    local source=$(readlink -f ${1:-.})
    local target=${custom_target:-$(dirname ${source})}

    if [[ -z "${reverse_mode}" ]]; then
        local uris="${source} ${USER}@[${vhost}]:${target}"
    else
        local uris="${USER}@[${vhost}]:${source} ${target}"
    fi

    local params=$(make_rsync_params)

    rsync -arv --rsync-path="mkdir -p ${target} && rsync" ${params} ${uris}
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
fi
