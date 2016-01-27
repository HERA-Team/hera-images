# Copyright 2015-2016 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh" from a directory containing a librarian Git
# checkout.
#
# See https://github.com/docker-library/docs/tree/master/php for some docs on
# how the base image works.

FROM php:7.0-apache
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

COPY setup.sh hl_client.cfg php.ini insecure_* ssh_host_* /setup/
COPY librarian /var/www/html/
COPY launch.sh /
RUN /bin/bash /setup/setup.sh

EXPOSE 80
CMD ["/launch.sh"]
