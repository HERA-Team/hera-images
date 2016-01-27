# /bin/bash
# Copyright 2016 the HERA Collaboration
# Licensed under the MIT License.
#
# HERA customizations that come after the DB install.

set -e -x

libsetup=/docker-entrypoint-initdb.d/000-create-librarian.sql
echo "create database hera_lib_onsite; use hera_lib_onsite;" >$libsetup
cat /hera/librarian/hl_schema.sql /hera/librarian/hl_constraints.sql >>$libsetup
echo "create database hera_lib_offsite; use hera_lib_offsite;" >>$libsetup
cat /hera/librarian/hl_schema.sql /hera/librarian/hl_constraints.sql >>$libsetup

cp /setup/00* /docker-entrypoint-initdb.d/

# Self-destruct!
cd /
rm -rf /setup
