#!/usr/bin/env bash
set -e

function show_help {
    cat <<EOF
mktree - script to creating filesystem subtree in current directory.

Usage:
    mktree (-f <filename>... | -d <dirname>...)
    mktree -h

Options:
    -f <filename>...    List of files' names.
    -d <dirname>...     List of directories' names.
    -h                  Show this help.
EOF
}

function process_path {
    local path=${1}
    local mode=${2}

    if [[ "${mode}" == "file" ]]; then
        mkdir -p $(dirname ${path})
        touch ${path}
    else
        if [[ "${mode}" == "dir" ]]; then
            mkdir -p ${path}
        else
            return 1
        fi
    fi
}

function main {
    local args=${@}
    local mode=none

    if [[ -z "${args}" ]]; then
        show_help
        exit 1
    fi

    for arg in ${args}; do
        case "${arg}" in
            -f)
                mode=file
                ;;
            -d)
                mode=dir
                ;;
            -h)
                show_help
                exit 0
                ;;
            *)
                if ! process_path "${arg}" "${mode}"; then
                    show_help
                    exit 1
                fi
                ;;
        esac
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
fi
