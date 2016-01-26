#! /bin/bash
# Copyright 2015-2016 the HERA Collaboration.
# Licensed under the MIT License.

usage="$0 <librarian>

This script builds a Docker image of the HERA Librarian software subsystem.
The argument is a URL to a Git checkout or repository for the librarian
software; see the 'fetch-tree.sh' script.

When the build is done, your Docker system will have a new image called
\"hera-test-librarian:YYYYMMDD\" that you can then use, where YYYYMMDD encodes
today's date."

if [ $# -ne 1 ] ; then
    echo >&2 "$usage"
    exit 1
fi

librarian_url="$1"

# Setup options and useful variables.

specdir=$(dirname $0)
if [ ! -f $specdir/Dockerfile ] ; then
    echo >&2 "error: \"$specdir/Dockerfile\" should exist but doesn't"
    exit 1
fi

imagename=hera-test-librarian:$(date +%Y%m%d)

: ${DOCKER:=sudo docker} # i.e., default $DOCKER to 'sudo docker' if unset

# Set up files and build.

set -e
work=$(mktemp -d)
echo "Temporary work directory is $work ."
$specdir/../fetch-tree.sh $librarian_url $work/librarian
(cd $specdir && cp -a * .dockerignore $work)
cp $specdir/../ssh-stack/insecure_* $specdir/../ssh-stack/ssh_host* $work
$DOCKER build -t $imagename $work
echo "Built image $imagename ."
$DOCKER tag -f $imagename ${imagename%:*}:latest
rm -rf $work
exit 0
