#!/bin/bash
# download-kubernetes-tools.sh
# 27.10.2021 - 2023, Stein Arne Storslett
# *************************************************************
#
# Download and install various Kubernetes tools
# The script must be run from a Linux type host, WSL, Mac
# and requires bash to run.
#
# IF "brew" from https://brew.sh is available tools will be installed with brew.
#
# Some tools are downloaded from internal servers since they are not publicly available.
# Example "oc" from OpenShift

#
# Download and run with
# curl -sS https://raw.githubusercontent.com/sastorsl/scripts/main/bin/download-kubernetes-tools.sh | bash
#
# Add options as such, i.e. set directory to /usr/local/bin and use `sudo`
# `bash -s -- <params>` will send params to the script
# curl -sS https://raw.githubusercontent.com/sastorsl/scripts/main/bin/download-kubernetes-tools.sh | bash -s -- -d /usr/local/bin -s
#
# *************************************************************

#
# Defaults
#
OC_URL="https://downloads-openshift-console.apps.os-global.finods.com/amd64/linux/oc.tar"
DEFAULT_DESTDIR=$HOME/bin
DESTDIR=${DEFAULT_DESTDIR}
K8S_PROFILE=${HOME}/.bashrc_k8s
COMPLETIONS=${HOME}/.bash_completion.d
USE_PROXY="no"  # By default don't use an https_proxy, unless a test determine it is required
DEFAULT_PROXY="${https_proxy}"
#
# Common curl options
#
CURL="curl --fail --silent --show-error --location"
FILE_DIR_MODE="755"
FILE_READ_MODE="644"

usage () {
    echo "Usage: $0 [-h|[-d <directory>] [-m <mode>] [-o <url>] [-p <url>] [-s]]"
    echo "Download and install Kubernetes tools to a directory."
    echo ""
    echo "-d,   Destination directory. Default: ${DESTDIR}"
    echo "-h,   Display this help"
    echo "-m,   Override destination mode for both directory and executables. Example: -m 775"
    echo "-o,   Override the default URL for OpenShifts oc-command. Default ${OC_URL}"
    echo "-p,   Configure https_proxy if proxy is required. Setting this option forces use of proxy. Default \"${DEFAULT_PROXY}\""
    echo "-s,   Invoke \"sudo\" to install. Use if the destination directory requires sudo privileges."
    echo ""
    exit 0
}

SUDO=""

while getopts ":d:o:p:sh" o; do
    case "${o}" in
        d)
            DESTDIR=${OPTARG}
            K8S_PROFILE=${DESTDIR}/bashrc_k8s
            COMPLETIONS=${DESTDIR}/bash_completion.d
            ;;
        h)
            usage
            ;;
        m)
            SET_MODE=${OPTARG}
            ;;
        o)
            OC_URL=${OPTARG}
            ;;
        p)
            PROXY_URL=${OPTARG}
            USE_PROXY="yes"
            ;;
        s)
            SUDO="sudo"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


#
# Run commands with bash, with or without sudo
#
runbash () {
    ${SUDO} bash -c "$@"
    EC=$?
    if [ $EC -ne 0 ]
    then
        echo "ERROR EC=$EC running command \"$@\""
        echo "Consider the \"-s\" option if you need sudo privileges."
        return $EC
    fi
}

#
# Perform a rudimentary proxy test with the proxy setting from the user
#
proxy_override_test () {
   export https_proxy=${PROXY_URL}
   export http_proxy=${PROXY_URL}
   if ! curl -m 5 -f -s https://raw.githubusercontent.com/ >/dev/null
   then
       echo "ERROR connecting to the internet with the provided proxy ${https_proxy}."
       exit 5
   fi
}

#
# Perform a rudimentary proxy test and set the default if it works.
#
test_proxy () {
    if curl -f -s https://raw.githubusercontent.com/ >/dev/null
    then
        :  # We're good to go
    else
        if [ -z "${DEFAULT_PROXY}" ]
        then
            echo "ERROR Unable to connect outside."
            echo "Set an \"https_proxy=<your-proxy>\" to use proxy"
            exit 1
        fi
        if https_proxy=${DEFAULT_PROXY} curl -f -sS https://raw.githubusercontent.com/
        then
            export https_proxy=${DEFAULT_PROXY}
        else
            echo "ERROR connecting to the internet even with proxy ${DEFAULT_PROXY}."
            echo "Consider overriding the proxy (see -h)."
            exit 1
        fi
    fi
}

#
# Test if we need a proxy
#
if [ ${USE_PROXY} = "yes" ]
then
    proxy_override_test
else
    test_proxy
fi
[ -n "$https_proxy" ] && PRX=" with proxy ${https_proxy}"

#
# Check if there is a mode override
#
if [ -n "$SET_MODE" ]
then
    if ! [[ $yournumber =~ "^7[57]5$" ]]
    then
        echo "ERROR: Mode must be 755 or 775"
        exit 1
    else
        FILE_DIR_MODE=${SET_MODE}
    fi
fi

#
# Tell the user what will happen and if we are doing sudo
#
echo "Downloading Kubernetes tools to directory ${DESTDIR}${SUDO:+with sudo privileges}${PRX}"
echo ""

whatnow () {
    echo "Setup ${DESTDIR}/$1"
}

trackprogress () {
    PROGRESS[${1}]=$(ls -l ${DESTDIR}/${1})
}

# *************************************************
# MAIN
# *************************************************

#
# Setup the destination directory
#
runbash "mkdir -p ${COMPLETIONS} && chmod ${FILE_DIR_MODE} ${COMPLETIONS}"
runbash "mkdir -p ${DESTDIR} && chmod ${FILE_DIR_MODE} ${DESTDIR}"

#
# Keep track
#
declare -A PROGRESS

if which brew
then
    BREW="yes"
    brew upgrade &&
    brew update -y &&
    brew install \
        argocd            \
        bash-completion@2 \
        gh                \
        helm              \
        hub               \
        jq                \
        krew              \
        kube-ps1          \
        kubectx           \
        kubernetes-cli    \
        kubeseal          \
        stern             \
        yq
else
    echo "\"brew\" is not installed or not available on path. Continuing with regular downloads."
    BREW="no"
fi

if [ "$BREW" = "no" ]
then
    #
    # Install the latest kubectl version
    # https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
    #
    BINFILE="kubectl"
    URLVERSION="https://dl.k8s.io/release/stable.txt"
    VERSION=$(${CURL} ${URLVERSION}) ; EC=$?
    whatnow ${BINFILE}
    if [ -n "$VERSION" ]
    then
        runbash "cd ${DESTDIR} && ${CURL} --remote-name https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/${BINFILE}" || exit $?
        runbash "chmod ${FILE_DIR_MODE} ${DESTDIR}/${BINFILE}" || exit $?
        runbash "${DESTDIR}/${BINFILE} completion bash > ${COMPLETIONS}/${BINFILE}.bash" || exit $?
        trackprogress ${BINFILE}
    else
        echo "ERROR getting versjon from URL ${URLVERSION} - EC=$EC - Output: ${VERSION}"
        exit 1
    fi

    #
    # Install helm with the "get_helm.sh" script from https://helm.sh/docs/intro/install/
    #
    BINFILE="helm"
    whatnow ${BINFILE}
    [ -z "$SUDO" ] && SUDOOPT=" --no-sudo"  # Drop sudo in the helm-script if not set
    runbash "cd ${DESTDIR} && ${CURL} -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" || exit $?
    runbash "chmod ${FILE_DIR_MODE} ${DESTDIR}/get_helm.sh" || exit $?
    runbash "cd ${DESTDIR} && HELM_INSTALL_DIR=${DESTDIR} PATH=\"$PATH:${DESTDIR}\" ./get_helm.sh ${SUDOOPT}" || exit $?
    runbash "chmod ${FILE_DIR_MODE} ${DESTDIR}/${BINFILE}" || exit $?
    runbash "${DESTDIR}/${BINFILE} completion bash > ${COMPLETIONS}/${BINFILE}.bash" || exit $?
    trackprogress ${BINFILE}

    #
    # Download and install the "stern" command from github
    # Please update this file if the version has been changed
    #
    BINFILE="stern"
    whatnow ${BINFILE}
    VERSION=$(curl -I -s https://github.com/stern/stern/releases/latest 2>&1  | \
              awk 'tolower($1) ~ /^location:/ { sub("\r$", "") ; n=split($2,L,"/") ; print L[n] }')
    runbash "cd ${DESTDIR} && ${CURL} -s -L https://github.com/stern/stern/releases/download/${VERSION}/stern_${VERSION#v}_linux_amd64.tar.gz | tar zxf - ${BINFILE}" || exit $?
    runbash "chmod ${FILE_DIR_MODE} ${DESTDIR}/${BINFILE}" || exit $?
    runbash "${DESTDIR}/${BINFILE} --completion bash > ${COMPLETIONS}/${BINFILE}.bash" || exit $?
    trackprogress ${BINFILE}

    #
    # Download and install the "kubectx" tools from github
    #
    BINFILE="kubectx"
    whatnow ${BINFILE}
    runbash "cd ${DESTDIR} && ${CURL} -o ${BINFILE} https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx" || exit $?
    runbash "chmod ${FILE_DIR_MODE} ${DESTDIR}/${BINFILE}" || exit $?
    runbash "${CURL} https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubectx.bash > ${COMPLETIONS}/${BINFILE}.bash" || exit $?
    trackprogress ${BINFILE}

    #
    # Download and install the "kubens" tools from github
    #
    BINFILE="kubens"
    whatnow ${BINFILE}
    runbash "cd ${DESTDIR} && ${CURL} -o ${BINFILE} https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens" || exit $?
    runbash "chmod ${FILE_DIR_MODE} ${DESTDIR}/${BINFILE}" || exit $?
    runbash "${CURL} https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubens.bash > ${COMPLETIONS}/${BINFILE}.bash" || exit $?
    trackprogress ${BINFILE}

    #
    # Download and install the "kube-ps1" kubernetes prompt
    #
    BINFILE="kube-ps1.sh"
    whatnow ${BINFILE}
    runbash "cd ${DESTDIR} && ${CURL} -o ${BINFILE} https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh" || exit $?
    runbash "chmod 644 ${DESTDIR}/${BINFILE}" || exit $?
    trackprogress ${BINFILE}

    #
    # Download and install the "argo" for ArgoCD tools from github
    #
    BINFILE="argo"
    whatnow ${BINFILE}
    VERSION=$(curl -I -s https://github.com/argoproj/argo-workflows/releases/latest 2>&1  | \
              awk 'tolower($1) ~ /^location:/ { sub("\r$", "") ; n=split($2,L,"/") ; print L[n] }')
    runbash "cd ${DESTDIR} && ${CURL} -s -L -o - https://github.com/argoproj/argo-workflows/releases/download/${VERSION}/argo-linux-amd64.gz | gzip -dc > ${BINFILE}" || exit $?
    runbash "chmod ${FILE_DIR_MODE} ${DESTDIR}/${BINFILE}" || exit $?
    runbash "${DESTDIR}/${BINFILE} completion bash > ${COMPLETIONS}/${BINFILE}.bash" || exit $?
    trackprogress ${BINFILE}

    echo "Downloaded the following files:"
    echo ""
    for BINARY in "${!PROGRESS[@]}"
    do
      echo "${PROGRESS[$BINARY]}"
    done
fi

if [ -n "$OC_URL" ]
then
    #
    # Download and install the latest OpenShift "oc" command from the local cluster
    # Unset proxy settings since we are fetching from internal networks
    #
    BINFILE="oc"
    whatnow ${BINFILE}
    runbash "cd ${DESTDIR} && https_proxy= ${CURL} -o oc.tar ${OC_URL}" || exit $?
    runbash "cd ${DESTDIR} && tar xf oc.tar && rm -f oc.tar" || exit $?
    runbash "chmod ${FILE_DIR_MODE} ${DESTDIR}/${BINFILE}" || exit $?
    runbash "${DESTDIR}/${BINFILE} completion bash > ${COMPLETIONS}/${BINFILE}.bash" || exit $?
    trackprogress ${BINFILE}
fi

#
# Setup a bashr_k8s file which can be sourced by users
#
runbash "cd ${DESTDIR} && ${CURL} -s -o - https://raw.githubusercontent.com/sastorsl/scripts/main/config/bashrc_k8s.template | sed -e s%XXX_COMPLETION_DIRECTORY_XXX%${COMPLETIONS}% -e s%XXX_DESTINATION_DIRECTORY_XXX%${DESTDIR}% > ${K8S_PROFILE} && chmod -v ${FILE_READ_MODE} ${K8S_PROFILE}"
runbash "find ${COMPLETIONS} -type f -exec chmod -v ${FILE_READ_MODE} {} \;"
runbash "if ! grep -q 'HOME/.bash_completion.d' ${HOME}/.bash_completion ; then echo 'for FILE in \$HOME/.bash_completion.d/*.bash; do   source \$FILE; done'"
runbash "if ! grep -q ${COMPLETIONS} ${HOME}/.bash_completion ; then echo 'for FILE in $COMPLETIONS/*.bash; do   source \$FILE; done'"

echo "Completed."
