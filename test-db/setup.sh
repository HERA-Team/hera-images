# /binb/bash
# Copyright 2016 the HERA Collaboration
# Licensed under the MIT License.
#
# Based on the official Docker MySQL image, but we've added this setup script
# to significantly streamline the image generation.

MYSQL_MAJOR=5.7
MYSQL_VERSION=5.7.10-1debian7

set -e -x

groupadd -r mysql
useradd -r -g mysql mysql
mkdir /docker-entrypoint-initdb.d

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  perl \
  pwgen

apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5

echo "deb http://repo.mysql.com/apt/debian/ wheezy mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list
{
  echo mysql-community-server mysql-community-server/data-dir select '';
  echo mysql-community-server mysql-community-server/root-pass password '';
  echo mysql-community-server mysql-community-server/re-root-pass password '';
  echo mysql-community-server mysql-community-server/remove-test-db select false;
} | debconf-set-selections

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  mysql-community-server="${MYSQL_VERSION}"

rm -rf /var/lib/apt/lists/*
rm -rf /var/lib/mysql
mkdir -p /var/lib/mysql

sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf
echo "skip-host-cache
skip-name-resolve" | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf >/tmp/my.cnf
mv /tmp/my.cnf /etc/mysql/my.cnf

# HERA customization:

echo "create database hera_lib; use hera_lib;" >/docker-entrypoint-initdb.d/000-create-librarian.sql
cat /hera/librarian/hl_schema.sql /hera/librarian/hl_constraints.sql \
  >>/docker-entrypoint-initdb.d/000-create-librarian.sql
cp /setup/00* /docker-entrypoint-initdb.d/

# Self-destruct!
cd /
rm -rf /setup
