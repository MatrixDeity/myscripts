#!/usr/bin/env bash
set -e

DEFAULT_N_ITERATIONS=1
DEFAULT_OUTPUT_FILE=trydo_$(date +%Y%m%d%H%M%S).log

function show_help {
    cat <<EOF
trydo - script to run passed command multiple times.

Usage:
    trydo [-n <num>] [-o <path>] <command>
    trydo (-l|-h)

Options:
    -n <num>     Number of iteration. Default: ${DEFAULT_N_ITERATIONS}.
    -o <path>    Path to file where logs will be saved. Default: ./trydo_<%Y%m%d%H%M%S>.log.
    -l           Show all running trydo processes.
    -h           Show this help.
EOF
}

function list_processes {
    local script_name=$(basename ${BASH_SOURCE[0]})
    ps -eo pid,stime,cmd                                      \
        | grep -F "${script_name}"                            \
        | grep -vE "${script_name} -l|grep -F ${script_name}"
}

function trydo_impl {
    local instruction=${1}
    local n_iterations=${2}

    echo -e "*** trydo is running '${instruction}' ***\n\n"

    local n_successes=0
    for (( itr=1; itr <= n_iterations; ++itr )); do
        echo "--- Step ${itr} ---"
        if eval "${instruction}"; then
            n_successes=$(( n_successes + 1 ))
            echo -e "--- SUCCESS ---\n\n"
        else
            echo -e "--- FAILED ---\n\n"
        fi
    done

    echo "Successes: ${n_successes} / ${n_iterations}"
    echo "*** trydo is stopping ***"
}

function main {
    local n_iterations=${DEFAULT_N_ITERATIONS}
    local output_file=${DEFAULT_OUTPUT_FILE}

    while getopts ":n:o:lh" OPT; do
        case "${OPT}" in
            l)
                list_processes
                exit 0
                ;;
            n)
                n_iterations=${OPTARG}
                ;;
            o)
                output_file=${OPTARG}
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

    if [[ -z "${@}" ]]; then
        show_help
        exit 1
    fi

    trydo_impl "${*}" "${n_iterations}" 2>&1 1>${output_file} & disown
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
fi
