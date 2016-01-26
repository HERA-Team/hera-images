# Copyright 2015-2016 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh".

FROM hera-ssh-stack:latest
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

COPY still.cfg.tmpl /hera/rtp/etc/
COPY hera-bootup.sh /usr/local/bin/

VOLUME /data
EXPOSE 14204
CMD ["hera-bootup.sh"]
