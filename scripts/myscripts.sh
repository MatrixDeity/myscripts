#!/usr/bin/env bash

MYSCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

alias fetchpr="${MYSCRIPTS_DIR}/fetchpr.sh"
alias gitlog="git log --pretty=oneline"
alias gitrmb="git checkout develop && git branch | egrep -v 'develop|master' | xargs -r git branch -D"
alias gitsub="git submodule update --init --recursive"
alias rmpyc="find . -name '*.pyc' -delete"
alias tmp="cd $(mktemp -d)"
alias trydo="${MYSCRIPTS_DIR}/trydo.sh"
alias upbash="vim ${HOME}/.bashrc && source ${HOME}/.bashrc"
alias vsync="${MYSCRIPTS_DIR}/vsync.sh"
alias vvisit="${MYSCRIPTS_DIR}/vvisit.sh"

function gitdrop { git clean -fd && git reset --hard HEAD~${1:-0} && git submodule update --init --recursive --force; }
function lg { ls -la "${2:-.}" | grep --color=no "${1}"; }
function mkcd { mkdir -p ${1} && cd ${1}; }
