#!/bin/zsh
# 11.10.2023, sastorsl, install colima with brew
#
# Run with
# zsh install-colima.sh
#
which brew &>/dev/null || { echo "the brew binary is missing or not in your \$PATH - Aborting..." ; exit 1 ; }

echo "Ensuring colima and the docker CLI is installed with brew."

echo "NB! This is a DESTRUCTIVE action - your environment will be removed and reconfigured"
echo "Type <enter> to continue or <ctrl>+C to ABORT"
read __xxx

function brew-install () {
    local package=$1
    if brew list ${package} &>/dev/null
    then
        echo "Package \"${package}\" is already installed - nothing to do"
    else
        brew install ${package}
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

brew-install colima docker docker-compose

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

#
# Setup the podman machine
#
CPUS=${1:-4}
MEMORY=${1:-8}
ARCH="x86_64"
K8S="--kubernetes"

echo "Initialize the colima machine and grant ${CPUS} CPUS and ${MEMORY}GiB memory on arch \"${ARCH}\" and k8s flag \"${K8S}\"."

if [ -n "$(colima list 2>/dev/null | grep -v "^PROFILE")" ]
then
    # Cleanup old machine
    colima stop
    colima delete
fi
colima start \
    --arch ${ARCH} \
    --cpu ${CPUS} \
    --memory ${MEMORY} \
    ${K8S} \
    --activate

echo ""
colima list
echo ""


echo "Colima is running"
echo "After a boot you can run \"colima start\" to start using colima"
echo "Run \"source ~/bin/setup-colima.sh\" in any shell where you want to connect to colima"
