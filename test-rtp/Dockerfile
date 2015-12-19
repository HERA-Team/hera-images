# Copyright 2015 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh".

FROM hera-stack:dev
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    openssh-server

RUN mkdir /var/run/sshd

COPY still.cfg.tmpl /hera/rtp/etc/
COPY hera-bootup.sh /usr/local/bin/

EXPOSE 22
EXPOSE 14204
CMD ["hera-bootup.sh"]
