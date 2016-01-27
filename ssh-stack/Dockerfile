# Copyright 2015-2016 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh".

FROM hera-stack:latest
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    openssh-server \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd /root/.ssh

COPY insecure_id_rsa /root/.ssh/id_rsa
COPY insecure_id_rsa.pub /root/.ssh/id_rsa.pub
COPY insecure_id_rsa.pub /root/.ssh/authorized_keys
COPY ssh_host_rsa_key /etc/ssh/
COPY ssh_host_rsa_key.pub /etc/ssh/
COPY ssh_host_rsa_key.pub /root/.ssh/known_hosts

RUN echo -n '* ' >/root/.ssh/known_hosts && \
    cat /etc/ssh/ssh_host_rsa_key.pub >>/root/.ssh/known_hosts && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/* && \
    rm -f /etc/ssh/ssh_host_dsa* /etc/ssh/ssh_host_ecdsa* && \
    chmod 600 /etc/ssh/ssh_host*

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
