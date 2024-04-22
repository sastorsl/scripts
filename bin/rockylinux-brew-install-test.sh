#!/bin/bash
#

nerdctl run \
  -ti \
  --rm \
  --platform amd64 \
  -v $HOME/.docker/certs.d:/etc/pki/ca-trust/source/anchors \
  rockylinux:8 bash -c '
    update-ca-trust
    dnf -y install git procps sudo
    dnf -y groupinstall "Development Tools"
    echo "brewtest ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/brewtest
    useradd -m brewtest
    sudo su - brewtest -c /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo "eval \"$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"") >> /home/brewtest/.bashrc
    sudo su - brewtest -c /bin/bash -c "brew install gcc"
    sudo su - brewtest -c /bin/bash -c "brew install gh"
    sudo su - brewtest -c /bin/bash -c "gh"
  '
