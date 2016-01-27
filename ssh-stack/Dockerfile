# Copyright 2015-2016 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh".

FROM hera-stack:latest
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    openssh-server \
  && rm -rf /var/lib/apt/lists/* && \
  mkdir -p /setup

COPY insecure_* ssh_host_* setup.sh /setup/
RUN /bin/bash /setup/setup.sh

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
