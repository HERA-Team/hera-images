#! /bin/bash
# Copyright 2016 the HERA Collaboration.
# Licensed under the MIT License.

usage="$0 <aipy> <omnical> <capo> <librarian> <rtp> <mandc>

Build Docker images for all of the HERA components."

if [ $# -ne 6 ] ; then
    echo >&2 "$usage"
    exit 1
fi

aipy="$1"
omnical="$2"
capo="$3"
librarian="$4"
rtp="$5"
mandc="$6"

set -e
stack/build.sh "$aipy" "$omnical" "$capo" "$librarian" "$rtp" "$mandc"
ssh-stack/build.sh
rsync-pot/build.sh
test-db/build.sh
test-librarian/build.sh "$librarian"
test-rtp/build.sh
