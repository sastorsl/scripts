#!/bin/zsh
# 03.04.2024, sastorsl, install Rancher Desktop with brew
#
# Run with
# zsh ./install-rancherdesktop.sh
#
which brew &>/dev/null || { echo "the brew binary is missing or not in your \$PATH - Aborting..." ; exit 1 ; }

echo "Ensuring Rancher Desktop and the docker CLI is installed with brew."

echo "NB! This is a DESTRUCTIVE action - your environment will be removed and reconfigured"
echo "Type <enter> to continue or <ctrl>+C to ABORT"
read __xxx

function brew-install () {
    local package=$1
    if brew list ${package} &>/dev/null
    then
        echo "Package/formula \"${package}\" is already installed - nothing to do"
    else
        brew install ${package}
    fi
}

function brew-install-cask () {
    local package=$1
    if brew list --cask ${package} &>/dev/null
    then
        echo "Package/cask \"${package}\" is already installed - nothing to do"
    else
        brew install --cask ${package}
    fi
}

# Ensure the brew environment is in good shape
if ! brew doctor
then
    echo "An error was discovered during \"brew doctor\". Fix the issues and retry."
    exit 1
fi

echo "Ensure the brew environment is updated - Running brew update|upgrade"
brew update && brew upgrade

if [ $(uname -p) = "arm" ]
then
    brew-install qemu
else
    brew-install hyperkit  # Supports x86_64 architecture
fi

brew-install-cask rancher
brew-install docker docker-compose

CERTNAME="ROOTCA"
CERTPATH="${HOME}/.docker/certs.d"
CERTFILE="${CERTPATH}/${CERTNAME}.crt"

echo "Setup a certificate directory with the ${CERTNAME} certificate"
echo "Extract the ${CERTNAME} certificate from the Mac keychain."
mkdir -pv ${CERTPATH}
ROOTCERT=$(security find-certificate -c ${CERTNAME} -p) ; EC=$?
if [ $EC -eq 0 ]
then
    echo ${ROOTCERT}
    echo "Adding certificate ${CERTNAME} to ${CERTFILE}"
    echo "${ROOTCERT}" > ${CERTFILE}
    diff ${CERTFILE} <(echo "${ROOTCERT}")
    if [ $? -ne 0 ]
    then
        echo "ERROR the ROOTCERT and ${CERTFILE} differs"
        exit 1
    fi
else
    echo "ERROR unable to fetch the ${CERTNAME} certificate from the keychain."
fi

if ! which rdctl >/dev/null 2>&1
then
  echo "the 'rdctl' binary is missing or not in your path"
  echo "unable to configure rancher desktop"
fi

rdctl start

sleep 5

# Configure
# See `rdctl set --help`
rdctl set \
  --application.auto-start=false  \
  --application.start-in-background=true \
  --application.telemetry.enabled=false \
  --application.updater.enabled=false \
  --application.window.quit-on-close=false \
  --container-engine.name=containerd \
  --kubernetes.enabled=true \
  --kubernetes.options.flannel=true \
  --kubernetes.options.traefik=false \
  --kubernetes.version="1.27.6" \
  --virtual-machine.memory-in-gb=20 \
  --virtual-machine.number-cpus=10
