# Copyright 2015-2017 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh".
#
# To initialize the RTP database we need to have access to the full HERA
# software stack, so we can't just use a standard PostgreSQL image. I've copied
# all of their stuff from github:docker-library:9737ce4.
#
# See https://hub.docker.com/_/postgres/ for information on on how the base
# image works.
#
# The available version of Postgres evolves quickly. If the build dies due to the
# requested version of postgres not being found, check for what's available at:
#
#    http://apt.postgresql.org/pub/repos/apt/pool/main/p/postgresql-9.5/
#
# You want the latest "pgdg70+1" version (unless the underlying Debian release
# changes).

FROM hera-stack:latest
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

ENV PG_MAJOR 9.5
ENV PG_VERSION 9.5.13-2.pgdg70+1
ENV LANG en_US.utf8
ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

COPY setup1.sh /setup/
RUN /bin/bash /setup/setup1.sh
COPY 0* setup2.sh /setup/
RUN /bin/bash /setup/setup2.sh

EXPOSE 5432

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres"]
