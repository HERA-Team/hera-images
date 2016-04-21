# Copyright 2016 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh" from a directory containing a librarian Git
# checkout.

FROM hera-ssh-stack:latest
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

COPY setup.sh hl_client.cfg insecure_* ssh_host_* /setup/
RUN /bin/bash /setup/setup.sh
COPY launch.sh /

EXPOSE 80
CMD ["/launch.sh"]
