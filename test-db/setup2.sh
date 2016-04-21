# /bin/bash
# Copyright 2016 the HERA Collaboration
# Licensed under the MIT License.
#
# HERA customizations that come after the DB install.

set -e -x

cp /setup/00* /docker-entrypoint-initdb.d/

# Self-destruct!
cd /
rm -rf /setup
