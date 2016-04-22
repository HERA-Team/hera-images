#! /bin/bash
# Copyright 2016 the HERA Collaboration.
# Licensed under the MIT License.
#
# Publish images to the Docker Hub. Behavior customized with the environment
# variables listed below, although the default should Do The Right Thing if
# you happen to be Peter Williams. Run with DOCKER=true to work in a noop
# mode.

: ${HUBUSER:=pkgw}
: ${VERSION:=$(date +%Y%m%d)}
: ${IMAGES:=hera-stack hera-rsync-pot hera-test-db hera-test-librarian hera-test-rtp}
: ${DOCKER:=docker}
: ${TAGARGS:=}

set -e

function mydocker () {
    echo docker "$@"
    $DOCKER "$@"
}

for image in $IMAGES ; do
    mydocker tag $TAGARGS $image:$VERSION docker.io/$HUBUSER/$image:$VERSION
    mydocker tag $TAGARGS $image:$VERSION docker.io/$HUBUSER/$image:latest
    mydocker push docker.io/$HUBUSER/$image:$VERSION
    mydocker push docker.io/$HUBUSER/$image:latest
done
