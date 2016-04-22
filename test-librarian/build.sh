#! /bin/bash
# Copyright 2016 the HERA Collaboration.
# Licensed under the MIT License.

usage="$0

This script builds a Docker image of version 2 of the HERA Librarian software
subsystem. The argument is a URL to a Git checkout or repository for the
librarian software; see the 'fetch-tree.sh' script.

When the build is done, your Docker system will have a new image called
\"hera-test-librarian:YYYYMMDD\" that you can then use, where YYYYMMDD encodes
today's date."

# Setup options and useful variables.

specdir=$(dirname $0)
if [ ! -f $specdir/Dockerfile ] ; then
    echo >&2 "error: \"$specdir/Dockerfile\" should exist but doesn't"
    exit 1
fi

imagename=hera-test-librarian:$(date +%Y%m%d)
: ${DOCKER:=docker}

# Set up files and build.

set -e
work=$(mktemp -d ${TMPDIR:-/tmp}/heraimage.XXXXXX)
echo "Temporary work directory is $work ."
(cd $specdir && cp -a * .dockerignore $work)
cp $specdir/../stack/hl_client.cfg $work
cp $specdir/../ssh-stack/insecure_* $specdir/../ssh-stack/ssh_host* $work
$DOCKER build -t $imagename $work
echo "Built image $imagename ."
$DOCKER tag $imagename ${imagename%:*}:latest
rm -rf $work
exit 0
