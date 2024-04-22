#!/bin/bash
# Since brew is ever faithful and installs the latest kubectl version,
# which might or might not miss your clusters I created this monstrosity
#
MINORVERSION="v1\.27"
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
BINDIR=$HOME/.local/bin

LAST_VERSION=$(
  GH_REPO=kubernetes/kubernetes gh release list \
    --json tagName \
    --exclude-drafts \
    --exclude-pre-releases \
    -L 30 \
    --template '{{range .}}{{.tagName}}{{"\n"}}{{end}}' |
      grep "${MINORVERSION}" |
      sort -V |
      tail -1
)

echo "Fetching kubectl version ${LAST_VERSION:?}"

mkdir -p ${BINDIR:?}

(
  curl \
    --location \
    --progress-bar \
    --output \
    ${BINDIR:?}/kubectl \
    "https://dl.k8s.io/release/${LAST_VERSION:?}/bin/${OS:?}/${ARCH:?}/kubectl"
  chmod 755 ${BINDIR:?}/kubectl
  ls -l ${BINDIR:?}/kubectl
  echo "Ensure ${BINDIR:?} is first in your '\$PATH' variable and run 'hash -r' to update the path cache"
)
