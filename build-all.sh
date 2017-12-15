#! /bin/bash
# Copyright 2016-2017 the HERA Collaboration.
# Licensed under the MIT License.

usage="$0 <omnical> <librarian> <rtp> <mandc>

Build Docker images for all of the HERA components."

if [ $# -ne 4 ] ; then
    echo >&2 "$usage"
    exit 1
fi

omnical="$1"
librarian="$2"
rtp="$3"
mandc="$4"

images_dir=$(dirname "$0")

set -e
$images_dir/stack/build.sh "$omnical" "$librarian" "$rtp" "$mandc"
$images_dir/ssh-stack/build.sh
$images_dir/rsync-pot/build.sh
$images_dir/test-db/build.sh
$images_dir/test-librarian/build.sh
$images_dir/test-rtp/build.sh
