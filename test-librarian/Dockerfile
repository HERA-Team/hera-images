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

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    openssh-client \
    zip \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install mysqli

COPY librarian /var/www/html/
COPY launch.sh /
COPY php.ini /usr/local/etc/php/
COPY insecure_id_rsa /var/www/.ssh/id_rsa
COPY insecure_id_rsa.pub /var/www/.ssh/id_rsa.pub
COPY insecure_id_rsa.pub /var/www/.ssh/authorized_keys
COPY ssh_host_rsa_key /etc/ssh/
COPY ssh_host_rsa_key.pub /etc/ssh/
COPY ssh_host_rsa_key.pub /var/www/.ssh/known_hosts

RUN echo -n '* ' >/var/www/.ssh/known_hosts && \
    cat /etc/ssh/ssh_host_rsa_key.pub >>/var/www/.ssh/known_hosts && \
    chown -R www-data:www-data /var/www/.ssh && \
    chmod 700 /var/www/.ssh && \
    chmod 600 /var/www/.ssh/*

EXPOSE 80
CMD ["/launch.sh"]
