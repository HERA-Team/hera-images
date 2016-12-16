#! /bin/bash
# Copyright 2016 the HERA Collaboration
# Licensed under the MIT License.

set -e -x

mkdir -p /var/run/sshd /root/.ssh /etc/ssh

cp /setup/ssh_host_rsa_key /etc/ssh/
cp /setup/ssh_host_rsa_key.pub /etc/ssh/
rm -f /etc/ssh/ssh_host_dsa* /etc/ssh/ssh_host_ecdsa*
chmod 600 /etc/ssh/ssh_host*

cp /setup/insecure_id_rsa /root/.ssh/id_rsa
cp /setup/insecure_id_rsa.pub /root/.ssh/id_rsa.pub
cp /setup/insecure_id_rsa.pub /root/.ssh/authorized_keys
cp /setup/ssh_host_rsa_key.pub /root/.ssh/known_hosts
echo -n '* ' >/root/.ssh/known_hosts
cat /etc/ssh/ssh_host_rsa_key.pub >>/root/.ssh/known_hosts
chmod 700 /root/.ssh
chmod 600 /root/.ssh/*

# Enable insecure but efficient arcfour256 cipher:
echo 'Ciphers arcfour256,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com' >>/etc/ssh/sshd_config

# Self-destruct!
cd /
rm -rf /setup/
