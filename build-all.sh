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

images_dir=$(dirname "$0")

set -e
$images_dir/stack/build.sh "$aipy" "$omnical" "$capo" "$librarian" "$rtp" "$mandc"
$images_dir/ssh-stack/build.sh
$images_dir/rsync-pot/build.sh
$images_dir/test-db/build.sh
$images_dir/test-librarian/build.sh "$librarian"
$images_dir/test-rtp/build.sh
