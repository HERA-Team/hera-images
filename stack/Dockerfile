# Copyright 2015-2016 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh"; see ../README.md for more information.
#
# This builds a reasonable base image with an Anaconda Python installation
# (well, Miniconda) and the standard HERA software stack.

FROM continuumio/miniconda:3.19.0
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
  && rm -rf /var/lib/apt/lists/* && \
  mkdir -p /hera

RUN conda install -y \
    astropy \
    basemap \
    ephem \
    matplotlib \
    numpy \
    psutil \
    psycopg2 \
    scipy \
    sqlalchemy \
  && pip install \
    configparser \
    pyfits

COPY hera fill-still-config.sh hl_client.cfg /hera/

RUN cd /hera/aipy && \
      python ./setup.py install && \
    cd /hera/omnical && \
      python ./setup.py install && \
    cd /hera/capo && \
      (cd Compress/ddr_compress && python setup.py install) && \
      python ./setup.py install && \
    cd /hera/librarian && \
      python ./setup.py install && \
    cd /hera/rtp && \
      mkdir -p log etc && \
    cd /hera/mandc && \
      python ./setup.py install && \
    cp /hera/hl_client.cfg /.hl_client.cfg && \
    cp /hera/hl_client.cfg /root/.hl_client.cfg
