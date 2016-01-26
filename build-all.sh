#! /bin/bash
# Copyright 2016 the HERA Collaboration.
# Licensed under the MIT License.

usage="$0 <aipy> <capo> <librarian> <rtp> <omnical>

Build Docker images for all of the HERA components."

if [ $# -ne 5 ] ; then
    echo >&2 "$usage"
    exit 1
fi

aipy="$1"
capo="$2"
librarian="$3"
rtp="$4"
omnical="$5"

set -e
stack/build.sh "$aipy" "$capo" "$librarian" "$rtp" "$omnical"
ssh-stack/build.sh
test-db/build.sh
test-librarian/build.sh "$librarian"
test-rtp/build.sh
