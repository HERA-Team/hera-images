#! /bin/bash
# Copyright 2015 the HERA Collaboration.
# Licensed under the MIT License.

usage="$0

This script builds a Docker image for a Real Time Pipe (RTP) server. When the
build is done, your Docker system will have a new image called
\"hera-test-rtp-server:YYYYMMDD\" that you can then use, where YYYYMMDD
encodes today's date."

# Setup options and useful variables.

specdir=$(dirname $0)
if [ ! -f $specdir/Dockerfile ] ; then
    echo >&2 "error: \"$specdir/Dockerfile\" should exist but doesn't"
    exit 1
fi

imagename=hera-test-rtp-server:$(date +%Y%m%d)

: ${DOCKER:=sudo docker} # i.e., default $DOCKER to 'sudo docker' if unset

# Set up files and build.

set -e
work=$(mktemp -d)
echo "Temporary work directory is $work ."
(cd $specdir && cp -a * .dockerignore $work)
$DOCKER build -t $imagename $work
echo "Built image $imagename ."
$DOCKER tag -f $imagename ${imagename%:*}:dev
rm -rf $work
exit 0
