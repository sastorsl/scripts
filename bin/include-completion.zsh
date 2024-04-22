#
# Add auto completion for brew in zsh
#
if ( type autoload && type compinit ) >/dev/null 2>&1
then

    if type terraform &>/dev/null
    then
      autoload -U +X bashcompinit && bashcompinit
      complete -o nospace -C /opt/homebrew/bin/terraform terraform
    fi

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
