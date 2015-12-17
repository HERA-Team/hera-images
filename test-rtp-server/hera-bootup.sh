#! /bin/bash
#
# Copyright 2015 the HERA Collaboration
# Licensed under the MIT License.

set -e
sed -e "s/@DB_PASSWORD@/$HERA_DB_PASSWORD/g" </hera/rtp/etc/still.cfg.tmpl >/hera/rtp/etc/still.cfg
exec /hera/rtp/bin/still.py --server
