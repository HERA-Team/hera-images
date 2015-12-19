<!-- To HTML-ify this file locally, use `grip --wide` on it. -->

HERA Docker Image Specifications
================================

This repository contains configuration files to create [Docker] images for
various [HERA] services. This allows you to test all of them in a single machine
in a way that is both reproducible and realistic.

[Docker]: https://www.docker.com/
[HERA]: http://reionization.org/

This document assumes that you are familiar with the basic concepts of both
Docker and HERA’s software architecture.


The Images
==========

Below is a table of the different images that are provided and their key
characteristics and parameters. For each listed image, there is a subdirectory
in this repository with its corresponding
[Dockerfile](https://docs.docker.com/engine/reference/builder/) and supporting
files.

* [`stack`]
* [`ssh-stack`]
* [`rsync-pot`]
* [`test-db`]
* [`test-librarian`]
* [`test-rtp`]

<!-- this awkward setup lets us hyperlink image descriptions more easily -->
[`stack`]: #stack
[`ssh-stack`]: #ssh-stack
[`rsync-pot`]: #rsync-pot
[`test-db`]: #test-db
[`test-librarian`]: #test-librarian
[`test-rtp`]: #test-rtp


`stack`
-------

This image provides the HERA software stack install on top of an
[Anaconda Python] distribution. It is based on the
[`continuumio/miniconda`](https://hub.docker.com/r/continuumio/miniconda/)
Docker image.

[Anaconda Python]: http://docs.continuum.io/anaconda/index

**Build.** Build this image by running the [stack/build.sh](stack/build.sh)
script. The built image will be named something like `hera-stack:YYYYMMDD`. It
will also label that image as `hera-stack:dev`.

The build script takes 4 arguments pointing to Git repositories or checkouts
for [Aipy], [Capo], the [HERA Librarian], and the [RTP].

[Aipy]: https://github.com/AaronParsons/aipy
[Capo]: https://github.com/dannyjacobs/capo/
[HERA Librarian]: http://herawiki.berkeley.edu/doku.php/librarian
[RTP]: https://github.com/jonr667/still_workflow

**Launch.** This image needs no special setup to be launched.

**Access.** This image runs no services; its default command is instead
`/bin/bash`. It’s intended to be used interactively.


`ssh-stack`
-------

This image extends the [`stack`] image to set up the root user to be able to
SSH into other hosts without a password. It is used as a base for various HERA
services that expect to be able to do this.

**Build.** Build this image by running the
[ssh-stack/build.sh](ssh-stack/build.sh) script. The built image will be named
something like `hera-ssh-stack:YYYYMMDD`. It will also label that image as
`hera-ssh-stack:dev`.

**Launch.** This image needs no special setup to be launched.

**Access.** By default, this image runs `sshd` in daemon mode. If making a
derived image, you have to run `sshd` yourself!


`rsync-pot`
-------------------

This image provides an [rsync] server that can send and receive files in a
volume named `/data`. It is based on the standard
[`debian:jessie`](https://hub.docker.com/_/debian/) Docker image.

[rsync]: https://rsync.samba.org/

**Build.** Build this image by running the
[rsync-pot/build.sh](rsync-pot/build.sh) script. The built image will be named
something like `hera-rsync-pot:YYYYMMDD`. It will also label that image as
`hera-rsync-pot:dev`.

**Launch.** When you start a container based on this image, you may want to
mount a volume at the location `/data` to pre-seed the image with data, or to
access data that are synced to the server. If you don’t, everything will work,
but getting data out of the server will be a bit more of a hassle.

**Access.** The container runs an [rsync] server on the standard port, 873.


`test-db`
-------------------

This image provides a backing database for testing the HERA stack. It is a
Frankenstein combination of the standard
[`mysql:5.7`](https://hub.docker.com/_/mysql/) Docker image and our [`stack`]
image.

**Build.** Build this image by running the
[test-db/build.sh](test-db/build.sh) script. The built image will be named
something like `hera-test-db:YYYYMMDD`. It will also label that image as
`hera-test-db:dev`.

**Launch.** When you start a container based on this image, you must set the
environment variable `MYSQL_ROOT_PASSWORD`.

**Access.** The container runs a [MySQL](https://www.mysql.com/) server on the
standard port, 3306.

On first startup the Librarian database is initialized with the following:

* A `source` named `RTP` with authenticator `9876543210`.
* A `source` named `Correlator` with authenticator `9876543211`.
* A `store` named `liblocal` with 100 GiB capacity and a `path_prefix` of
  `/hera/localstore`.
* A `store` named `rsync0` with 100 GiB capacity and an `rsync_prefix` of
  `rsync0`.

Note that while the database server records this information, the
[HERA Librarian] web application is the one that actually uses it, so
hostnames and such need to be resolvable by the [`test-librarian`] container,
not the database container.

On first startup the RTP database is initialized with the current schema, but
left empty.


`test-librarian`
----------------

This image runs an Apache/PHP server for testing the [HERA Librarian] web
application. It is based on the standard
[`php:7.0-apache`](https://hub.docker.com/_/php/) Docker image.

**Build.** Build this image by running the
[test-librarian/build.sh](test-librarian/build.sh) script. The built image
will be named something like `hera-test-librarian:YYYYMMDD`. It will also
label that image as `hera-test-librarian:dev`.

**Launch.** When launching the service, you must
[“link”](https://docs.docker.com/v1.8/userguide/dockerlinks/) it with a
container running the [`test-db`] image under the internal name `db`. **Note**
that inter-container linking in Docker is evolving rapidly and so the precise
procedure for this may change. You must also set the `HERA_DB_PASSWORD`
environment variable to the password used to access the database. Finally, if
you want to experiment with sample data, you should mount a volume with HERA
data at `/hera/localstore/data`.

**Access.** Once started, the service runs an instance of the Librarian web
app on port 80, accessible at the URL `/hl.php`.

See the description of the [`test-db`] image for a summary of the
configuration that the Librarian is preloaded with.

Inside the image, the librarian source code is stored in `/var/www/html`, so
if you use Docker’s `-v` option to mount a Git checkout of the librarian at
that location, you can test code changes on the fly.


`test-rtp`
----------------

This image run the server that drives the RTP pipeline. It is based on the
[`ssh-stack`] image.

**Build.** Build this image by running the
[test-rtp/build.sh](test-rtp/build.sh) script. The built image will be named
something like `hera-test-rtp:YYYYMMDD`. It will also label that image as
`hera-test-rtp:dev`.

**Launch.** When launching the service, you must set the `HERA_DB_PASSWORD`
environment variable to the password used to access the database.

An `EOFError` exception gets thrown on RTP startup, but it is in a background
thread and can safely be ignored.

**Access.** Once started, the service runs SSHD on port 22 and the very
simplistic RTP HTTP server on port 14204.


Running a Test Rig
==================

To test the HERA online system, you first need to build the various images
described above, following the directions given above for each image. You can
then proceed to launch each service.

First, to allow the different services to automatically be able to look up
each other’s host names, we need to create a special virtual “network” that
they all share:

```
sudo docker network create -d bridge hera
```

(As a side note, containers only auto-discover each other is their host names
are explicitly set, which is why we give the `-h` option to `docker run` when
creating the various services.)

Now we can launch the backing database:

```
HERA_DB_PASSWORD=1234
sudo docker run -d --net hera --name db -h db \
  -e MYSQL_ROOT_PASSWORD=$HERA_DB_PASSWORD hera-test-db:dev
```

If you ever want to examine the database directly, you can do so by running
a temporary container on the same network:

```
sudo docker run -it --net hera --rm mysql mysql -hdb -uroot -p$HERA_DB_PASSWORD
```

Now we can start the Librarian itself. We also mount a volume of data so that
there are things to look at. Finally, we expose the Librarian web interface on
<http://localhost:21106/hl.php> in case you want to interact with it directly:

```
DEMO_VOLUME=/b/hera-samples/digilab_pot0 # will likely vary
sudo docker run -d --net hera --name librarian -h librarian \
  -e HERA_DB_PASSWORD=$HERA_DB_PASSWORD \
  -v $DEMO_VOLUME:/hera/localstore/data \
  -p 21106:80 \
  hera-test-librarian:dev
```

Now we need to load our sample data into the Librarian. The easiest way to do
this is by using a temporary client image that has access to the full software
stack:

```
sudo docker run --rm --net hera \
  -v $DEMO_VOLUME:/data \
  hera-stack:dev /bin/bash -c \
  "echo '{\"sites\":{\"docker\":{\"url\":\"http://librarian/\",\"authenticator\":\"9876543211\"}}}' >/.hl_client.cfg &&
  /hera/librarian/add_obs_librarian.py --site docker --store liblocal /data/*.uv"
```

Now we can start up the RTP server:

```
sudo docker run -d --net hera --name rtp-server -h rtp-server \
  -e HERA_DB_PASSWORD=$HERA_DB_PASSWORD \
  -v $DEMO_VOLUME:/data \
  -p 14204:14204 \
  hera-test-rtp:dev hera-bootup.sh --server
```
