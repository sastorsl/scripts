#
# git aliases
#
alias gitlogall="git log --graph --abbrev-commit --decorate --date=local --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ad)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all --name-status"
alias gitlog="git log --graph --abbrev-commit --decorate --date=local --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ad)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --name-status"
alias gitformatpatch='mkdir -p ~/git/patch ; XXX_PATCH=~/git/patch/patch-$(date +%Y%m%d%H%M%S)-$(basename $(git rev-parse --show-toplevel))-$(git rev-parse --abbrev-ref HEAD | tr / -).patch ; cd $(git rev-parse --show-toplevel 2>/dev/null) ; git format-patch master --stdout > $XXX_PATCH ; cd - ; echo Patchfile created: $XXX_PATCH'

#
# Alias all GIT repos
#
#
# Setup function to loop the git directory and create aliases.
#
function gitaliases () {
    local PREFIX=$HOME/git/
    local NR=1
    # unset previous git aliases
    local ALIASES=$(alias | awk 'BEGIN { FS="[= ]" } /\.git=.cd / { print $2 }')
    [ -n "${ALIASES}" ] && unalias ${ALIASES}

    # Find git repos and set alias
    while read GITREPO
    do
        local GITPATH=${GITREPO%/.git}
        local ALIASFULLNAME=$(echo ${GITPATH} | sed -e "s#^${PREFIX}##" -e 's#/#-#g' -e 's/^/gitrepo-/').git
        alias ${ALIASFULLNAME}="cd ${GITPATH}"
    done <<<"$(find ${PREFIX} -type d -name .git | LANG=C sort)"
}
# Setup aliases
gitaliases

#
# Get a kubernetes / k8s zsh profile
#
alias k8sprofile='source ~/bin/zshrc-k8s.zsh'

#
# Get your regular zsh profile
#
alias zshprofile='source ~/.zshrc'

#
# Use to get syntax highligthing with the help of "vim"
# Usage: <cmd> | vaml
#
function vaml() {
  vim -R -c 'set syntax=yaml' -;
}

#
# Use to get syntax highligthing with the help of "yq"
# Requires the "yq" package, i.e. "sudo snap install yq"
# Usage: <cmd> | yqp
#
alias yqp='yq e -PC | less -r'

#
# Requires the colordiff package
#
alias diff='colordiff'
