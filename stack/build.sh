#! /bin/bash
# Copyright 2015 the HERA Collaboration.
# Licensed under the MIT License.

usage="$0 <aipy> <omnical> <capo> <librarian> <rtp> <m&c>

Build a Docker image containing the HERA software stack. The arguments <aipy>,
<omnical>, etc., are URLs specifying either a Git repository or a Git checkout.
For production usage the URLs should look something like

  file:///home/peter/sw/aipy#9f530c2

where the \"fragment\" (the bit after the #) specifies the precise commit to
use. For development usage, the special URL form

  dev:///home/peter/sw/aipy

will copy the tree verbatim, including uncommitted changes and files. See the
\"fetch-tree.sh\" script for more information.

When the build completes, your Docker system will have a new image called
\"hera-stack:YYYYMMDD\" that you can then use, where YYYYMMDD encodes today's
date. The image will also be aliased to \"hera-stack:latest\"."

if [ $# -ne 6 ] ; then
    echo >&2 "$usage"
    exit 1
fi

aipy_url="$1"
omnical_url="$2"
capo_url="$3"
librarian_url="$4"
rtp_url="$5"
mandc_url="$6"

# Setup options and useful variables.

specdir=$(dirname $0)
if [ ! -f $specdir/Dockerfile ] ; then
    echo >&2 "error: \"$specdir/Dockerfile\" should exist but doesn't"
    exit 1
fi

imagename=hera-stack:$(date +%Y%m%d)

: ${DOCKER:=sudo docker} # i.e., default $DOCKER to 'sudo docker' if unset

# Set up files and build.

set -e
work=$(mktemp -d)
echo "Temporary work directory is $work ."
mkdir $work/hera
$specdir/../fetch-tree.sh $aipy_url $work/hera/aipy
$specdir/../fetch-tree.sh $omnical_url $work/hera/omnical
$specdir/../fetch-tree.sh $capo_url $work/hera/capo
$specdir/../fetch-tree.sh $librarian_url $work/hera/librarian
$specdir/../fetch-tree.sh $rtp_url $work/hera/rtp
$specdir/../fetch-tree.sh $mandc_url $work/hera/mandc
(cd $specdir && cp -a * .dockerignore $work)
$DOCKER build -t $imagename $work
echo "Built image $imagename ."
$DOCKER tag -f $imagename ${imagename%:*}:latest
rm -rf $work
exit 0
