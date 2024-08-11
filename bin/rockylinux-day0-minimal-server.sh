#!/bin/bash
# 11.08.2024, sastorsl
# Server tools and stuff to install after a Rocky Linux 9 minimal installation

# Cockpit server administration tool
sudo dnf -y install cockpit

# Manage SELinux
sudo dnf -y install policycoreutils-python-utils

# Apache httpd server
sudo dnf -y install httpd mod_ssl

# Install an updated ddclient which supports cloudflare tokens
cat > /etc/yum.repos.d/fedora-rawhide.repo << EOF
[rawhide]
name=Fedora - Rawhide - Developmental packages for the next Fedora release
failovermethod=priority
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=rawhide&arch=$basearch
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$basearch file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$basearch
EOF
sudo dnf -y install --enablerepo=rawhide ddclient

# Install postfix / mail transport agent
sudo dnf -y install postfix cyrus-sasl-plain

# Install fail2ban and helper
sudo dnf -y install fail2ban whois

# Get ACME help for TLS certificates
sudo dnf -y install certbot python3-certbot-apache

# Samba file sharing
sudo dnf -y install samba samba-client
