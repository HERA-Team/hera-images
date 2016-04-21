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

cat <<EOF >server-config.json
{
    "SECRET_KEY": "7efa9258e0b841eda8a682ccdd53c65d493a7dc4b95a5752b0db1bbbe96bd269",
    "SQLALCHEMY_DATABASE_URI": "postgresql://postgres:$HERA_DB_PASSWORD@db:5432/hera_librarian_$1",
    "SQLALCHEMY_TRACK_MODIFICATIONS": false,
    "host": "0.0.0.0",

    "sources": {
        "RTP": {
            "authenticator": "9876543210"
        },
        "Correlator": {
            "authenticator": "9876543211"
        },
        "HumanUser": {
            "authenticator": "9876543212"
        }
    }
}

EOF

exec ./runserver.py
