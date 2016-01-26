# Copyright 2015 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh".
#
# I originally used the standard Docker mysql image, but to initialize the RTP
# database we need to have access to the full HERA software stack. So now we
# are FROM the hera-stack image, which is from Continuum's Miniconda, which is
# FROM debian:wheezy. Below I have just copied the current (as of 2015/12/16,
# commit ee6ac03) mysql Dockerfile bits. The Dockerfile for the official image
# is based on debian:jessie, not wheezy, so I needed to change (1) the distro
# name in the 'echo "deb..."' line, and (2) MYSQL_VERSION.
#
# See https://github.com/docker-library/docs/tree/master/mysql for some docs
# on how the base image works.

FROM hera-stack:latest
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

# Duplicate the mysql setup of the official Docker MySQL image.

RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN mkdir /docker-entrypoint-initdb.d
RUN apt-get update && apt-get install -y perl pwgen --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5
ENV MYSQL_MAJOR 5.7
ENV MYSQL_VERSION 5.7.10-1debian7
RUN echo "deb http://repo.mysql.com/apt/debian/ wheezy mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list
RUN { \
	echo mysql-community-server mysql-community-server/data-dir select ''; \
	echo mysql-community-server mysql-community-server/root-pass password ''; \
	echo mysql-community-server mysql-community-server/re-root-pass password ''; \
	echo mysql-community-server mysql-community-server/remove-test-db select false; \
    } | debconf-set-selections \
    && apt-get update && apt-get install -y mysql-community-server="${MYSQL_VERSION}" && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf \
    && echo 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
    && mv /tmp/my.cnf /etc/mysql/my.cnf
VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Now do our own customization

RUN echo "create database hera_lib; use hera_lib;" >/docker-entrypoint-initdb.d/000-create-librarian.sql && \
    cat /hera/librarian/hl_schema.sql /hera/librarian/hl_constraints.sql \
      >>/docker-entrypoint-initdb.d/000-create-librarian.sql
COPY 001-stub-librarian.sql /docker-entrypoint-initdb.d/
COPY 002-create-rtp.sql /docker-entrypoint-initdb.d/
COPY 003-init-rtp.sh /docker-entrypoint-initdb.d/

EXPOSE 3306
CMD ["mysqld"]
