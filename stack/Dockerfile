# Copyright 2015-2017 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh"; see ../README.md for more information.
#
# This builds a reasonable base image with an Anaconda Python installation
# (well, Miniconda) and the standard HERA software stack.

FROM continuumio/miniconda:4.3.14
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    libgl1-mesa-swx11 \
  && rm -rf /var/lib/apt/lists/* && \
  mkdir -p /hera

RUN conda install -y 'libgfortran =3.0.0' \
  && conda config --add channels conda-forge \
  && conda config --remove channels defaults \
  && conda update -y --all \
  && conda install -y \
    alembic \
    astropy \
    basemap \
    configparser \
    python-dateutil \
    ephem \
    flask \
    flask-sqlalchemy \
    mako \
    matplotlib \
    netifaces \
    numpy \
    pandas \
    psutil \
    psycopg2 \
    pyproj \
    scipy \
    sqlalchemy \
    tabulate

COPY hera/aipy /hera/aipy
RUN cd /hera/aipy && python ./setup.py install

COPY hera/omnical /hera/omnical
RUN cd /hera/omnical && python ./setup.py install

COPY hera/capo /hera/capo
RUN cd /hera/capo && \
      (cd Compress/ddr_compress && python setup.py install) && \
      python ./setup.py install

COPY hera/librarian /hera/librarian
RUN cd /hera/librarian && python ./setup.py install

COPY hera/rtp /hera/rtp
RUN cd /hera/rtp && mkdir -p log etc

COPY hera/mandc /hera/mandc
RUN cd /hera/mandc && python ./setup.py install

COPY fill-configs.sh hl_client.cfg /hera/
RUN cp /hera/hl_client.cfg /.hl_client.cfg && \
    cp /hera/hl_client.cfg /root/.hl_client.cfg && \
    echo export PATH=/opt/conda/bin:\$PATH >>/root/.bashrc
