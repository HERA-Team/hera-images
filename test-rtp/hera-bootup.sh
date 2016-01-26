#! /bin/bash
# Copyright 2015-2016 the HERA Collaboration.
# Licensed under the MIT License.

set -e
/hera/rtp/fill-still-config.sh

# Meh, just run this in the background.
/usr/sbin/sshd -D &

exec /hera/rtp/bin/still.py "$@"
