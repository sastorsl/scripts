#!/bin/bash
# 11.08.2024, sastorsl
# Client tools and stuff to install after a Rocky Linux 9 minimal installation

# Basic tools
dnf -y install \
    bash-completion \
    bind-utils \
    colordiff \
    epel-release \
    fetchmail \
    git \
    logrotate \
    lsof \
    lynx \
    mlocate \
    mutt \
    procmail \
    rsync \
    s-nail \
    tar \
    tmux \
    vim-enhanced \
    wget \

echo
