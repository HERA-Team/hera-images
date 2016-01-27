# Copyright 2015 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh"; see ../README.md for more information.
#
# This is strongly derived from the image posted at
# https://hub.docker.com/r/bfosberry/rsync/ , which in turn is derived from
# https://github.com/nabeken/docker-volume-container-rsync . We then go ahead
# and customize for HERA.

FROM hera-ssh-stack:latest
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    rsync \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data
RUN chmod a+rw /data

ADD entrypoint.sh /entrypoint.sh

EXPOSE 873
ENTRYPOINT ["/entrypoint.sh"]
