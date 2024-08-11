#!/bin/bash
# 19.04.2024, sastorsl
# Configure system, install and configure rancher desktop kubernetes

# sudo sysctl -w net.ipv4.ip_unprivileged_port_start=0

NAME="rancher"
DATASTORE=/data/rancher
LOGDIR=${DATASTORE:?}/var/log
AUDITLOG=${LOGDIR:?}/auditlog
LIBDIR=${DATASTORE:?}/var/lib/rancher
DOCKERIMAGE="rancher/rancher:latest"
CURRENT_USER=$(whoami)

[ ${CURRENT_USER:?} == "root" ] && { echo "This script should be run as your personal user." ; exit 1 ; }

# Setup basic directories to persist across restarts
sudo mkdir -p ${DATASTORE:?} ${LOGDIR:?} ${AUDITLOG:?} ${LIBDIR:?}
sudo chown -R ${CURRENT_USER:?}:${CURRENT_USER:?} ${DATASTORE:?}
sudo chmod -R o-rwx ${DATASTORE:?}

# Ensure user is in the docker group
if test $USER != root && ! $(id -Gn $USER | grep -qw docker)
then
    sudo usermod -a -G docker $USER
fi
# Ensure the users shell is fresh with the docker group available
if test $USER != ROOT && ! $(id -Gn | grep -qw docker)
then
    echo "NB! Log out and into this shell again to ensure your user is a member of the docker group."
    echo "For instance do a:"
    echo "sudo su - $USER"
    exit 1
fi

MODULE_FILE=/etc/modules-load.d/rancher.conf 
MODULES="nf_tables
nf_conntrack
iptable_filter
xt_state"

# Setup required kernel modules
if test ! -f ${MODULE_FILE:?} || ! diff ${MODULE_FILE:?} <(echo "${MODULES:?}")
then
    echo Setting up ${MODULE_FILE:?}
    echo "${MODULES:?}" | sudo tee ${MODULE_FILE:?}
else
    echo ${MODULE_FILE:?} is OK
fi

# Ensure required modules are loaded
if [ -n "$(while read i ; do modinfo ${i} >/dev/null 2>&1 || echo MISSING ; done < ${MODULE_FILE:?})" ]
then
    echo "NB! A reboot of the server is required to load required kernel modules. (see ${MODULE_FILE:?})"
    exit 1
fi

# Create a symlink to the host log directory
sudo ln -fns ${LOGDIR:?} /var/log/rancher

docker pull ${DOCKERIMAGE:?}
# Stop and remove any running container to be able to re-configure the container.
# NB! Persistent data must be mounted in as volumes!!!

if [ -n $(docker ps -a -f name=${NAME:?} --format '{{.Names}}' | grep -w "^${NAME:?}$") ]
then
    docker stop --time 10 ${NAME:?}
    docker rm --force ${NAME:?}
fi

docker run \
    --detach \
    --name=${NAME:?} \
    --privileged \
    --restart=unless-stopped \
    --env=AUDIT_LEVEL=1 \
    --publish=8080:80 \
    --publish=6443:443 \
    --volume=${AUDITLOG:?}:/var/log/auditlog \
    --volume=${LIBDIR:?}:/var/lib/rancher \
    ${DOCKERIMAGE:?}

# -v /host/certs:/container/certs \
# -e SSL_CERT_DIR="/container/certs" \
# --env=CATTLE_TLS_MIN_VERSION="1.2" \

for PORT in 8080 6443
do
    sudo firewall-cmd --permanent --zone=home --add-port=${PORT:?}/tcp
    sudo firewall-cmd --zone=home --add-port=${PORT:?}/tcp
done
