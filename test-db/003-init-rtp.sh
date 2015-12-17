#! /bin/bash
# Copyright 2015 the HERA Collaboration.
# Licensed under the MIT License.

set -e -x

# Even though we're not doing anything real, still.py complains if we don't
# have a full config file.

cat <<EOF >/hera/rtp/etc/still.cfg
[dbinfo]
dbuser = root
dbpasswd = $MYSQL_ROOT_PASSWORD
dbhost = localhost
dbport = 3306
dbtype = mysql
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

# For whatever reason, the SQLAlchemy binding expects the server socket to be
# in /tmp rather than /var/run. And at this init stage the server doesn't seem
# to be accepting network connections so that workaround doesn't work. So we
# just do a symlink hack.

mkdir /hera/rtp/log
ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock
/hera/rtp/bin/still.py --client --init
rm -f /tmp/mysql.sock
