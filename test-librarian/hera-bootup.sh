#! /bin/bash
#
# Copyright 2015 the HERA Collaboration
# Licensed under the MIT License.
#
# This is a slight modification of the Docker launch script:
#   https://github.com/docker-library/php/blob/master/7.0/apache/apache2-foreground
# We need to set up the runtime configuration of the Librarian server.

set -e

cat <<EOF >/var/www/html/hl_server.cfg
{ 
"db_host": "db",
"db_user": "root",
"db_name": "hera_lib",
"db_passwd": "$HERA_DB_PASSWORD",
"max_transfers": 10,
"title": "HERA Librarian Docker container"
}
EOF

rm -f /var/run/apache2/apache2.pid

exec apache2 -DFOREGROUND
