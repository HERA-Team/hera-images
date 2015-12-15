# Copyright 2015 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh" from a directory containing a librarian Git
# checkout.
#
# See https://github.com/docker-library/docs/tree/master/php for some docs on
# how the base image works.

FROM php:7.0-apache
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

# apt-get install -y ...

RUN apt-get update && \
    docker-php-ext-install mysqli

COPY librarian /var/www/html/
COPY hera-bootup.sh /usr/local/bin/
COPY php.ini /usr/local/etc/php/

EXPOSE 80
CMD ["hera-bootup.sh"]
