# Copyright 2015-2016 the HERA Collaboration
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

COPY setup1.sh /setup/
RUN /bin/bash /setup/setup1.sh
COPY 00* setup2.sh /setup/
RUN /bin/bash /setup/setup2.sh

VOLUME /var/lib/mysql
EXPOSE 3306

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld"]
