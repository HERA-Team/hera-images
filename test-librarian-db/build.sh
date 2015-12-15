#! /bin/bash
# Copyright 2015 the HERA Collaboration.
# Licensed under the MIT License.

usage="$0

This script builds a Docker image for the database server that backs the
Librarian software system. You should run it from a Git checkout of the
Librarian source code. When it is done, your Docker system will have a new
image called \"hera-test-librarian-db:YYYYMMDD\" that you can then use, where
YYYYMMDD encodes today's date."

# Are we in a Librarian Git checkout?

if git ls-files |grep -q -F hl.php ; then
    true # yes
else
    echo >&2 "$usage"
    exit 1
fi

# OK. Setup options and useful variables.

specdir=$(dirname $0)
if [ ! -f $specdir/Dockerfile ] ; then
    echo >&2 "error: \"$specdir/Dockerfile\" should exist but doesn't"
    exit 1
fi

imagename=hera-test-librarian-db:$(date +%Y%m%d)

: ${DOCKER:=sudo docker} # i.e., default $DOCKER to 'sudo docker' if unset

# We're going to build an image from the current HEAD commit. We complain
# if there are uncommitted changes.

git update-index -q --refresh
hash=$(git show-ref -h --hash=6 |head -n1)
echo "Building an image for commit $hash."

if [ -n "$(git diff-index --name-only HEAD --)" ] ; then
    echo >&2 "warning: the current git repository has uncommitted changes; they will be ignored"
fi

# Set up files and build.

set -e
work=$(mktemp -d)
echo "Temporary work directory is $work ."
mkdir $work/librarian
git archive HEAD |(cd $work/librarian && tar x)
(cd $specdir && cp -a * .dockerignore $work)
$DOCKER build -t $imagename $work
echo "Built image $imagename ."
rm -rf $work
exit 0
