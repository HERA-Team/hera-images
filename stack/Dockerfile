# Copyright 2015 the HERA Collaboration
# Licensed under the MIT License.
#
# Build by running "build.sh"; see ../README.md for more information.
#
# This builds a reasonable base image with an Anaconda Python installation
# (well, Miniconda) and the standard HERA software stack.

FROM continuumio/miniconda:3.18.3p0
MAINTAINER Peter Williams <pwilliams@cfa.harvard.edu>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    build-essential

RUN conda install -y \
    ephem \
    numpy \
    psutil \
    scipy \
    sqlalchemy

RUN pip install \
    configparser \
    pyfits

RUN mkdir -p /hera

COPY aipy /hera/aipy
RUN cd /hera/aipy && \
    python ./setup.py install

COPY capo /hera/capo
RUN cd /hera/capo && \
    (cd Compress/ddr_compress && python setup.py install) && \
    python ./setup.py install

COPY librarian /hera/librarian

COPY rtp /hera/rtp

CMD ["/bin/bash"]
