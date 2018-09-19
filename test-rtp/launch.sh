#! /bin/bash
# Copyright 2015-2016 the HERA Collaboration.
# Licensed under the MIT License.

set -e

for f in /opt/conda/etc/conda/activate.d/* ; do
    source "$f"
done

/hera/fill-configs.sh

# Meh, just run this in the background.
/usr/sbin/sshd -D &

# We need to wait for the database to be ready to accept connections before we
# can start. This is a simple (but hacky) way of doing this:
host=db
port=5432

while true ; do
    (echo >/dev/tcp/$host/$port) >/dev/null 2>&1 && break
    echo waiting for database ...
    sleep 1
done

exec /hera/rtp/bin/still.py "$@"
