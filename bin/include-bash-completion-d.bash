#!/bin/bash
#
# Ensure that a $HOME/.bash_completion and $HOME/.bash_completion.d/ exists and that
# $HOME/.bash_completion.d/*.bash is sourced in $HOME/.bash_completion
#
# Download and run with
# curl -sS https://raw.githubusercontent.com/sastorsl/scripts/main/bin/bash-completion-d.bash | bash
#

if [ -n "${BASH_VERSINFO}" ]
then

    if [ ! -f ${HOME:?}/.bash_completion ]
    then
        touch ${HOME:?}/.bash_completion
    fi

    if [ ! -d ${HOME:?}/.bash_completion.d ]
    then
        mkdir ${HOME:?}/.bash_completion.d
    fi

    if ! grep -q bash_completion.d ${HOME:?}/.bash_completion
    then
        echo 'NG=$(shopt -p nullglob) ; shopt -s nullglob ; for FILE in $HOME/.bash_completion.d/*.bash; do   source $FILE; done ; ${NG}' >> ${HOME:?}/.bash_completion
    fi

else
    # echo "This script is intended to be run with bash. Aborting..."
    :
fi
