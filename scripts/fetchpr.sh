#!/usr/bin/env bash
set -e

REMOTE=upstream

function fatal {
    local message=${1}
    if [[ -n "${message}" ]]; then
        echo -e "\e[31mFATAL\e[0m: ${message}" >&2
    fi
    exit 1
}

function show_help {
    cat <<EOF
fetchpr - script to fetch pull request from remote Github repository.

Usage:
    fetchpr <pr_number>
    fetchpr -h

Options:
    -h    Show this help.
EOF
}

function get_default_branch {
    echo "$(git symbolic-ref refs/remotes/${REMOTE}/HEAD | sed "s@^refs/remotes/${REMOTE}/@@")"
}

function prepare_branches {
    local local_branch=${1}
    local remote_branch=${2}

    if ! git status &>/dev/null; then
        fatal "That's not git repository"
    fi

    if ! git remote | grep -E "^${REMOTE}$" &>/dev/null; then
        fatal "You don't have '${REMOTE}' remote. Add it and try again then"
    fi

    if ! git diff HEAD --exit-code --quiet; then
        if [[ "$(git branch --show-current)" == "${local_branch}" ]]; then
            git reset --hard HEAD
        else
            fatal "You have some uncommitted changes. Commit or stash them and try again"
        fi
    fi

    if [[ -z $(git ls-remote ${REMOTE} ${remote_branch}) ]]; then
        fatal "Branch '${remote_branch}' doesn't exist in '${REMOTE}'"
    fi
}

function fetch_pull_request {
    local local_branch=${1}
    local remote_branch=${2}
    local default_branch=$(get_default_branch)

    git checkout ${default_branch}
    git branch -D ${local_branch} 2>/dev/null || true
    git pull ${REMOTE} ${default_branch}
    git fetch ${REMOTE} ${remote_branch}:${local_branch}
    git checkout ${local_branch}
    git merge -m "Automerge" ${default_branch}
    git submodule update --init --recursive
    git reset --soft ${default_branch}
    git status
}

function main {
    if [[ -z "${@}" ]]; then
        show_help
        exit 1
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

    local pr=${1}
    local local_branch=pull/${pr}
    local remote_branch=refs/pull/${pr}/head

    prepare_branches "${local_branch}" "${remote_branch}"
    fetch_pull_request "${local_branch}" "${remote_branch}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
fi
