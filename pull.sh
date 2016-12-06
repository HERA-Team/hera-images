#! /bin/bash
# Copyright 2016 the HERA Collaboration.
# Licensed under the MIT License.
#
# Pull new images from the Docker Hub.

: ${HUBUSER:=pkgw}
: ${IMAGES:=hera-rsync-pot hera-test-db hera-test-librarian hera-test-rtp}
: ${TAGARGS:=}
: ${DOCKER:=docker}

set -e

function mydocker () {
    echo + docker "$@"
    $DOCKER "$@"
}

if [ "$1" = "-t" ] ; then
    shift
    tag=true
else
    tag=false
fi

if [ $# -ne 1 ] ; then
    echo "usage: $0 [-t] <version>

Where <version> is something like 20161206. This pulls HERA images from the
Docker Hub. If '-t' is given it will also tag them with names like
'hera-test-db:latest', which is the form assumed by the sample scripts and
docker-compose setup.

"
    exit 1
fi

VERSION="$1"

for image in $IMAGES ; do
    mydocker pull docker.io/$HUBUSER/$image:$VERSION

    if $tag ; then
	mydocker tag docker.io/$HUBUSER/$image:$VERSION $image:latest
    fi
done
