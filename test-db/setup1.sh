# /bin/bash
# Copyright 2016 the HERA Collaboration
# Licensed under the MIT License.
#
# Based on the official Docker Postgres image, but we've added this setup script
# to significantly streamline the image generation. The init is split into two
# pieces so that it's quick to rebuild when we're only changing the database
# initialization.

set -e -x

groupadd -r postgres --gid=999
useradd -r -g postgres --uid=999 postgres

echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' $PG_MAJOR >/etc/apt/sources.list.d/pgdg.list
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
apt-get update

# "grab gosu for easy step-down from root"
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
apt-get install -y --no-install-recommends ca-certificates wget
wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)"
wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc"
gpg --verify /usr/local/bin/gosu.asc
rm /usr/local/bin/gosu.asc
chmod +x /usr/local/bin/gosu
apt-get purge -y --auto-remove ca-certificates wget

apt-get install -y locales
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

mkdir /docker-entrypoint-initdb.d

apt-get install -y postgresql-common
sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf
apt-get install -y postgresql-$PG_MAJOR=$PG_VERSION postgresql-contrib-$PG_MAJOR=$PG_VERSION

rm -rf /var/lib/apt/lists/*

mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

# No self-destruct -- that's setup2.sh's job.
