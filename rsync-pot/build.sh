#! /bin/bash
# Copyright 2015 the HERA Collaboration.
# Licensed under the MIT License.

# This custom build script is pretty pointless in this case, but it maintains
# consistency with the other images.

usage="$0

This script builds a Docker image of an rsync server. You may run it from
anywhere. When it is done, your Docker system will have a new image called
\"hera-rsync-pot:YYYYMMDD\" that you can then use, where YYYYMMDD encodes
today's date. The image will also be aliased to \"hera-rsync-pot:latest\"."

# Setup options and useful variables.

specdir=$(dirname $0)
if [ ! -f $specdir/Dockerfile ] ; then
    echo >&2 "error: \"$specdir/Dockerfile\" should exist but doesn't"
    exit 1
fi

imagename=hera-rsync-pot:$(date +%Y%m%d)
: ${DOCKER:=docker}

# Set up files and build.

set -e
work=$(mktemp -d ${TMPDIR:-/tmp}/heraimage.XXXXXX)
echo "Temporary work directory is $work ."
(cd $specdir && cp -a * .dockerignore $work)
$DOCKER build -t $imagename $work
echo "Built image $imagename ."
$DOCKER tag $imagename ${imagename%:*}:latest
rm -rf $work
exit 0
