#! /bin/bash
# Copyright 2015 the HERA Collaboration
# Licensed under the MIT License.

usage="usage: fetch-tree.sh <source URL> <destination path>

Copy a tree of files using a generic source specification. The source is
specified as a URL for flexibility and reproducibility.

git://github.com/pkgw/pwkit.git
git://github.com/pkgw/pwkit.git#master
git://github.com/pkgw/pwkit.git#3d4d76
file:///home/peter/sw/pwkit
dev:///home/peter/sw/pwkit
/home/peter/sw/pwkit

URLs with the \"dev\" protocol cause a directory tree to be copied completely.
All other URLs are passed to Git. This means that \"dev://\" URLs will cause
uncommitted changes and files to be included, while \"file://\" ones won't.

If the source URL is an existing directory, it is treated as a \"dev\" URL.

The destination path should not exist. It will be created as a directory.

\"Production\" mode usage should specify a named commit in a Git repository. "

if [ $# -ne 2 ] ; then
    echo >&2 "$usage"
    exit 1
fi

url="$1"
dest="$2"

if [ -d "$url" ] ; then
    url="dev://$url"
fi

origurl="$url"
protocol=${url%%:*} # strips everything after the first ":"
commit=${url##*#} # strips everything before the final "#"
if [ "$commit" = "$url" ] ; then
    # The URL has no "fragment" piece indicating which commit to use.
    commit=
else
    # It has a fragment; strip it.
    url=${url%%#*}
fi


if [ $protocol = dev ] ; then
    echo >&2 "warning: copying non-reproducible tree for URL $url"
    path=${url##dev://}
    mkdir -p $(dirname "$dest")
    cp -a "$path" "$dest"
    # do not propagate user's built files into the container!:
    [ -f "$dest"/setup.py ] && rm -rf "$dest"/build
    hash="non-reproducible-tree-copy"
else
    cd $(dirname "$dest")
    git clone $url $(basename "$dest")
    cd "$dest"
    git checkout $commit
    hash=$(git show-ref --head |head -n1 |cut -d' ' -f1)
    rm -rf .git
fi

echo "$origurl" >"$dest/.origin_url"
echo "$hash" >"$dest/.origin_hash"
chmod 444 "$dest/.origin_url" "$dest/.origin_hash"
