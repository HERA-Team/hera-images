#! /bin/bash
# Copyright 2016 the HERA Collaboration
# Licensed under the MIT License.
#
# Both the www-data and root users need to be set up for passwordless SSH. The
# former for adding observations, the latter for running rsync copies.

set -e -x

# Packages

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  openssh-client \
  rsync \
  zip
rm -rf /var/lib/apt/lists/*

# SSH

mkdir -p /var/run/sshd /root/.ssh /etc/ssh

cp /setup/ssh_host_rsa_key /etc/ssh/
cp /setup/ssh_host_rsa_key.pub /etc/ssh/
rm -f /etc/ssh/ssh_host_dsa* /etc/ssh/ssh_host_ecdsa*
chmod 600 /etc/ssh/ssh_host*

for home in /root /var/www ; do
    mkdir -p $home/.ssh
    cp /setup/insecure_id_rsa $home/.ssh/id_rsa
    cp /setup/insecure_id_rsa.pub $home/.ssh/id_rsa.pub
    cp /setup/insecure_id_rsa.pub $home/.ssh/authorized_keys
    cp /setup/ssh_host_rsa_key.pub $home/.ssh/known_hosts
    echo -n '* ' >$home/.ssh/known_hosts
    cat /etc/ssh/ssh_host_rsa_key.pub >>$home/.ssh/known_hosts
    chmod 700 $home/.ssh
    chmod 600 $home/.ssh/*

    if [ "$home" = /var/www ] ; then
	chown -R www-data:www-data $home/.ssh
    fi

    cp /setup/hl_client.cfg $home/.hl_client.cfg
done

# PHP

cp /setup/php.ini /usr/local/etc/php/

docker-php-ext-install pcntl
docker-php-ext-install mysqli

# Self-destruct!
cd /
rm -rf /setup/
