#! /bin/bash
# Copyright 2015-2016 the HERA Collaboration
# Licensed under the MIT License.

VOLUME=${VOLUME:-/data}
ALLOW=${ALLOW:-192.168.0.0/16 172.16.0.0/12}
OWNER=${OWNER:-nobody}
GROUP=${GROUP:-nogroup}

chown "${OWNER}:${GROUP}" "${VOLUME}"

[ -f /etc/rsyncd.conf ] || cat <<EOF > /etc/rsyncd.conf
uid = ${OWNER}
gid = ${GROUP}
use chroot = yes
pid file = /var/run/rsyncd.pid
log file = /dev/stdout

[data]
hosts deny = *
hosts allow = ${ALLOW}
read only = false
path = ${VOLUME}
comment = ${VOLUME}
EOF

/hera/fill-configs.sh

# We don't actually use rsync in daemon mode, so all we need to do is run
# sshd. In face, you could achieve the same effect with the current
# hera-ssh-stack image. But it seems better to keep this one distinct in case
# we elaborate things in the future.
###exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf "$@"

exec /usr/sbin/sshd -D
