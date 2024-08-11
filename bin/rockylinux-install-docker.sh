#!/bin/bash
# 11.08.2023, sastorsl
# https://docs.rockylinux.org/gemstones/containers/docker/

sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo || exit $?

sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin || exit $?

sudo systemctl --now enable docker || exit $?

sudo usermod -a -G docker $(whoami) || exit $?
