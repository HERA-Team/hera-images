#! /bin/bash
# Copyright 2015 the HERA Collaboration.
# Licensed under the MIT License.

set -e -x

# Even though we're not doing anything real, still.py complains if we don't
# have a full config file. We also don't use fill-configs.sh since we're
# too weird: we have $POSTGRES_PASSWORD not $HERA_DB_PASSWORD and the host
# should be "".

cat <<EOF >/hera/rtp/etc/still.cfg
[dbinfo]
dbuser = postgres
dbpasswd = $POSTGRES_PASSWORD
dbhost =
dbport = 5432
dbtype = postgresql
dbname = hera_rtp

[Still]
hosts = AUTO
port = 14204
data_dir = /tmp
path_to_do_scripts = /tmp
actions_per_still = 2
timeout = 14400
sleep_time = 5
block_size = 10
cluster_scheduler = 0

[WorkFlow]
prioritize_obs = 1
neighbors = 1
lock_all_neighbors_to_same_still = 1
actions = FAKE
actions_endfile = FAKE

[FAKE]
args = [basename]
EOF

ln -s /var/run/postgresql/.s.PGSQL.5432 /tmp/
/hera/rtp/bin/still.py --client --init
rm -f /tmp/.s.PGSQL.5432
