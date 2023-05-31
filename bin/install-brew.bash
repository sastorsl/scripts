#!/bin/bash
# 26.05.2023, Stein Arne Storslett
#
# Download and install "brew" from "brew.sh", and install relevant kubernetes tooling.
# Always revise https://brew.sh for changes to the installation procedure.
#
# This script is meant to be run with bash and for a bash shell environment
# and with either an "apt" based general package manager such as in Debian / Ubuntu
# or "yum" / "dnf" based as in Fedora and RedHat Linux.
#
# Download and run with
# curl -sS https://raw.githubusercontent.com/sastorsl/scripts/main/bin/install-brew.bash | bash
#

#
# This script is intended for bash
#
if [ -z "${BASH_VERSINFO}" ]
then
    echo "This script is intended for bash only."
    exit 1
fi

RED="31"
GREEN="32"
YELLOW="33"
BLUE="34"
GREENBOLD="\e[1;${GREEN}m"
REDITALIC="\e[3;${RED}m"
BLUENORMAL="\e[0;${BLUE}m"
YELLOWBOLD="\e[1;${YELLOW}m"
ENDCOLOR="\e[0m"

logdo () {
    echo -e "${YELLOWBOLD}$@${ENDCOLOR}"
}

logerr () {
    echo -e "${REDITALIC}$@${ENDCOLOR}"
}

logok () {
    echo -e "${GREENBOLD}$@${ENDCOLOR}"
}

logok "Discovering the system package manager"

if which apt >/dev/null 2>&1
then
    PKGTYPE="apt"
    PKGMGR="sudo apt"
elif which apt-get >/dev/null 2>&1
then
    PKGTYPE="apt"
    PKGMGR="sudo apt-get"
elif which dnf >/dev/null 2>&1
then
    PKGTYPE="yum"
    PKGMGR="sudo dnf"
elif which yum >/dev/null 2>&1
then
    PKGTYPE="yum"
    PKGMGR="sudo yum"
else
    logerr "Unknown package manager. PR's welcome."
    cat /etc/lsb-release /etc/redhat-release 2>/dev/null
    exit 99
fi

get_setup () {
if [ "${PKGTYPE}" = "apt" ]
then
    ${PKGMGR} update && ${PKGMGR} upgrade -y
    ${PKGMGR:?} install -y build-essential
elif [ "${PKGTYPE}" = "yum" ]
then
    ${PKGMGR} update -y
    ${PKGMGR:?} groupinstall -y 'Development Tools'
fi
}

logdo "Updating system packages."
get_setup

# "curl" and "git" are required by brew
logdo "Ensuring curl and git is available."
${PKGMGR:?} install -y curl file git

# Install brew - periodically check with https://brew.sh to see if the command has been changed
# NB! Review inststructions from the script
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if ! grep -qE "^[^#]*eval .*/home/linuxbrew/.linuxbrew/bin/brew shellenv" $HOME/.bashrc
then
    logdo "Adding brew to your \$PATH, and other environment variables, on boot"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
else
    logok "Brew config is OK - already added to your $HOME/.bashrc"
fi

#
# Update bash completions
#
logok "Configuring bash completion setup."
curl -sS https://raw.githubusercontent.com/sastorsl/scripts/main/bin/bash-completion-d.bash | bash

logdo "Adding or updating bash_completions for brew"
curl -s https://raw.githubusercontent.com/sastorsl/scripts/main/config/bash_completion.d/brew.bash > ${HOME}/.bash_completion.d/brew.bash

logok "Setting up brew shell environment for the installation phase."
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

logdo "Turn off brew analytics."
brew analytics off

logdo "Installing tools."
brew install \
    argocd \
    bash-completion@2 \
    gh \
    helm \
    hub \
    jq \
    krew \
    kube-ps1 \
    kubectx \
    kubernetes-cli \
    kubeseal \
    openshift-cli \
    stern \
    yq

logdo "Add or update ${HOME}/.bashrc_k8s"
curl -s https://raw.githubusercontent.com/sastorsl/scripts/main/config/bashrc_k8s.brew_template > ${HOME}/.bashrc_k8s

if ! grep -q k8sprofile ${HOME}/.bashrc
then
    echo "alias k8sprofile='source ~/.bashrc_k8s'" >> ${HOME}/.bashrc
fi

logok "
###
### READ THE FOLLOWING LINES CAREFULLY!
###
### Get OpenShift aliases for oc-<env> by adding the following files"
[ -f $HOME/.user_email ] && /bin/mv -f ${HOME}/.user_email ${HOME}/.openshift_user
if [ ! -f ${HOME}/.openshift_user ]
then
    logdo "# echo your.email@hostname.com > $HOME/.openshift_user    # Your email address or username used in OpenShift clusters"
fi
if [ ! -f ${HOME}/.openshift_domain ]
then
    logdo "# echo YOURDOMAINNAME.COM > $HOME/.openshift_domain   # DOMAIN Part of the hostname (finNNN.com)"
fi

logok "
### Type the following to get new config right away"
logdo "source $HOME/.bashrc"
logok "### Type the following to get a nice prompt for your kubernetes / openshift clusters."
logdo "k8sprofile"

# Add to current shell so you get going
logok "
### Run the following command right now to get started with brew."
logdo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
