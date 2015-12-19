# Copyright 2015 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh"; see ../README.md for more information.
#
# This is strongly derived from the image posted at
# https://hub.docker.com/r/bfosberry/rsync/ , which in turn is derived from
# https://github.com/nabeken/docker-volume-container-rsync . We then go ahead
# and customize for HERA.

FROM debian:jessie
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    rsync

RUN mkdir -p /data
RUN chmod a+rw /data

ADD entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 873
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]