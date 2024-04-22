#!/bin/bash
# Download a specific version of rancher for MacOS
#
MINORVERSION="v1.9.1"
SHASUFFIX="sha512sum"
GITREPO="rancher-sandbox/rancher-desktop"
VOLUME_PATTERN="[^ ]*/Volumes/Rancher.*"
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
BINDIR=$HOME/.local/bin
DOWNLOAD_DIR=${HOME:?}/Downloads

if [ "$1" = "--force" ]
then
  FORCE="yes"
fi

echo "Fetching rancher-desktop version ${MINORVERSION:?}"
if ! which gh >/dev/null 2>&1
then
  echo "Relying on the 'gh' binary. Please install with 'brew install gh' or similar."
  exit 1
fi

case ${ARCH:?} in
  arm64) PATTERN="aarch64.dmg" ;;
  x86_64) PATTERN="x86_64.dmg" ;;
  *) echo "Unable to match your os architecture to a known package name. Aborting..."
     exit 1
     ;;
esac

# Get release spesifications
RELEASE_FILE=$(
  GH_REPO=${GITREPO:?} gh release view ${MINORVERSION:?} \
    --json assets \
    --jq '.assets[] | select(.name|endswith("'${PATTERN:?}'"))|.name'
)

RELEASE_PATH=${DOWNLOAD_DIR:?}/${RELEASE_FILE:?}
RELEASE_PATH_SHA=${DOWNLOAD_DIR:?}/${RELEASE_FILE:?}.${SHASUFFIX:?}

cd ${DOWNLOAD_DIR:?} || { echo "ERROR unable to enter directory ${DOWNLOAD_DIR:?}. Aborting ..." ; exit 1 ; }

# Download repo file
GH_REPO=${GITREPO:?} gh release download \
    -p "*${PATTERN:?}" \
    --clobber \
    ${MINORVERSION:?} || exit $?

# Download checksum file
GH_REPO=${GITREPO:?} gh release download \
  -p "*${PATTERN:?}.${SHASUFFIX:?}" \
  --clobber \
  ${MINORVERSION:?} || exit $?

 Verify checksum
sha512sum -c ${RELEASE_PATH_SHA:?} || exit $?

#
# TODO: The below install is broken and does not work very well.
# Install manually for now
#

echo "${RELEASE_PATH:?} is downloaded. Please install manually using the Launcher..."
