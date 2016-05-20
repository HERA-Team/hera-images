#! /bin/bash
# Copyright 2015-2016 the HERA Collaboration
# Licensed under the MIT License.
#
# We need to set up the runtime configuration of the Librarian server. We must
# be called with an argument giving the name of the Librarian database to use.

if [ -z "$1" ] ; then
    echo >&2 "error: you must specify the name of the librarian database to use"
    exit 1
fi

set -e

cd /hera/librarian/server

cat <<EOF >test-$1-config.json
{
    "server": "tornado",
    "SECRET_KEY": "7efa9258e0b841eda8a682ccdd53c65d493a7dc4b95a5752b0db1bbbe96bd269",
    "SQLALCHEMY_DATABASE_URI": "postgresql://postgres:$HERA_DB_PASSWORD@db:5432/hera_librarian_$1",
    "SQLALCHEMY_TRACK_MODIFICATIONS": false,
    "host": "0.0.0.0",
    "displayed_site_name": "$1",
    "initialize-database": true,
    "flask-debug": true,

    "sources": {
        "RTP": {
            "authenticator": "9876543210"
        },
        "Correlator": {
            "authenticator": "9876543211"
        },
        "Karoo": {
            "authenticator": "9876543212"
        },
        "HumanUser": {
            "authenticator": "human"
        }
    },

    "add-stores": {
      "${1}pot": { "path_prefix": "/data", "ssh_host": "${1}pot" }
    }
}
EOF

# We need to wait for the database to be ready to accept connections before we
# can start. This is a simple (but hacky) way of doing this:

host=db
port=5432

while true ; do
    (echo >/dev/tcp/$host/$port) >/dev/null 2>&1 && break
    echo waiting for database ...
    sleep 1
done

# OK, we can continue

export LIBRARIAN_CONFIG_PATH=test-$1-config.json
exec ./runserver.py
