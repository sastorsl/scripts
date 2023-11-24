#!/bin/bash
# 26.05.2023, Stein Arne Storslett
#
# Download and install "brew" from "brew.sh"
#
# This script is meant to be run with bash and for a bash shell environment
# and with an "apt" based general package manager such as in Debian / Ubuntu
# Always revise https://brew.sh for changes.
#
# Download and run with
# curl -sS https://raw.githubusercontent.com/sastorsl/scripts/main/bin/install-brew.bash | bash
#

echo "Find the system package manager"

if which apt >/dev/null 2>&1
then
    PKGTYPE="apt"
    PKGMGR="apt"
elif which apt-get >/dev/null 2>&1
then
    PKGTYPE="apt"
    PKGMGR="apt-get"
elif which dnf >/dev/null 2>&1
then
    PKGTYPE="yum"
    PKGMGR="dnf"
elif which yum >/dev/null 2>&1
then
    PKGTYPE="yum"
    PKGMGR="yum"
else
    echo "Unknown package manager. PR's welcome."
    cat /etc/lsb-release /etc/redhat-release 2>/dev/null
    exit 99
fi

get_setup () {
if [ "${PKGTYPE}" = "apt" ]
then
    sudo ${PKGMGR} update && ${PKGMGR} upgrade -y
    sudo ${PKGMGR:?} install -y build-essential
elif [ "${PKGTYPE}" = "yum" ]
then
    sudo ${PKGMGR} update -y
    sudo ${PKGMGR:?} groupinstall -y 'Development Tools'
fi
}

echo "Updating system packages."
get_setup

# "curl" and "git" are required by brew
echo "Ensure curl and git is available."
sudo ${PKGMGR:?} install -y curl file git

# Install brew - periodically check with https://brew.sh to see if the command has been changed
# NB! Review inststructions from the script
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Add brew to your \$PATH, and other environment variables, on boot"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc

echo "Add or update bash_completions for brew"
curl -s https://raw.githubusercontent.com/sastorsl/scripts/main/config/bash_completion_brew > ${HOME}/.bash_completion_brew
if ! grep -q bash_completion_brew $HOME/.bash_completion
then
    echo "Add bash completion to your startup shell."
    echo 'source ${HOME}/.bash_completion_brew' >> ${HOME}/.bash_completion
else
    echo "brew bash completion is already added to your startup shell."
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "Turn off brew analytics."
brew analytics off

echo "Install tools."
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
    stern \
    yq

echo "Add or update ${HOME}/.bashrc_k8s"
curl -s https://raw.githubusercontent.com/sastorsl/scripts/main/config/bashrc_k8s.brew_template > ${HOME}/.bashrc_k8s

if ! grep -q k8sprofile ${HOME}/.bashrc
then
    echo "alias k8sprofile='source ~/.bashrc_k8s'" >> ${HOME}/.bashrc
fi

echo "###"
echo "### READ THE FOLLOWING LINES CAREFULLY!"
echo "###"

echo "### Get OpenShift aliases for oc-<env> by adding the following files"
echo "### $HOME/.user_email        # Your email address (or user) used in OpenShift clusters"
echo "### $HOME/.openshift_domain  # DOMAIN Part of the hostname (finNNN.com)"

echo ""
echo "### Type the following to get new config right away"
echo "source $HOME/.bashrc"
echo "### Type `k8sprofile` to get a nice prompt for your kubernetes / openshift clusters."
echo "k8sprofile"

# Add to current shell so you get going
echo ""
echo "### Run the following command right now to get started with brew."
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
