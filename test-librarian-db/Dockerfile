# Copyright 2015 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh" from a directory containing a librarian Git
# checkout.
#
# See https://github.com/docker-library/docs/tree/master/mysql for some docs
# on how the base image works.

FROM mysql:5.7
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

COPY librarian /hera/librarian
RUN echo "create database hera_lib; use hera_lib;" >/docker-entrypoint-initdb.d/000-create.sql && \
    cat /hera/librarian/hl_schema.sql /hera/librarian/hl_constraints.sql \
      >>/docker-entrypoint-initdb.d/000-create.sql
COPY 001-docker-context.sql /docker-entrypoint-initdb.d/
