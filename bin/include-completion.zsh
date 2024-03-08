#
# Add auto completion for brew in zsh
#
if ( type autoload && type compinit ) >/dev/null 2>&1
then
    if type brew &>/dev/null
    then
      FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    fi

    # Override all completion with local changes
    if [ ! -d ${HOME:?}/.zsh_completion.d ]
    then
        mkdir ${HOME:?}/.zsh_completion.d
    fi
    FPATH="${HOME:?}/.zsh_completion.d:${FPATH}"

    # Load all completions
    autoload -Uz compinit
    compinit
fi
