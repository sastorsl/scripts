#!/bin/bash
# 11.08.2024, sastorsl
# Server tools and stuff to install after a Rocky Linux 9 minimal installation

# Cockpit server administration tool
dnf -y install cockpit

# Manage SELinux
dnf -y install policycoreutils-python-utils

# Apache httpd server
dnf -y install httpd mod_ssl

# Install an updated ddclient which supports cloudflare tokens
wget -O /tmp/ddclient-3.11.2-4.fc41.noarch.rpm https://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/d/ddclient-3.11.2-4.fc41.noarch.rpm
dnf -y install /tmp/ddclient-3.11.2-4.fc41.noarch.rpm

# Install postfix / mail transport agent
dnf -y install postfix cyrus-sasl-plain

# Install fail2ban and helper
dnf -y install fail2ban whois

# Get ACME help for TLS certificates
dnf -y install certbot python3-certbot-apache

# Samba file sharing
dnf -y install samba samba-client
