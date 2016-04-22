#! /bin/bash
# Copyright 2016 the HERA Collaboration
# Licensed under the MIT License.

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

mkdir -p /root/.ssh
cp /setup/insecure_id_rsa /root/.ssh/id_rsa
cp /setup/insecure_id_rsa.pub /root/.ssh/id_rsa.pub
cp /setup/insecure_id_rsa.pub /root/.ssh/authorized_keys
cp /setup/ssh_host_rsa_key.pub /root/.ssh/known_hosts
echo -n '* ' >/root/.ssh/known_hosts
cat /etc/ssh/ssh_host_rsa_key.pub >>/root/.ssh/known_hosts
chmod 700 /root/.ssh
chmod 600 /root/.ssh/*

cp /setup/hl_client.cfg /root/.hl_client.cfg

# Librarian. The rm -f is a workaround for when I develop
# with local symlinks in place.

rm -f /hera/librarian/server/test_db_*
cp /setup/test_db_* /hera/librarian/server/
chmod +x /hera/librarian/server/test_db_*

# Self-destruct!

cd /
rm -rf /setup/
