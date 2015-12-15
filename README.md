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

* [`test-librarian-db`]
* [`test-librarian`]

<!-- this awkward setup lets us hyperlink image descriptions more easily -->
[`test-librarian-db`]: #test-librarian-db
[`test-librarian`]: #test-librarian


`test-librarian-db`
-------------------

This image provides the backing database for testing the [HERA Librarian]
service. It is based on the standard
[`mysql:5.7`](https://hub.docker.com/_/mysql/) Docker image.

[HERA Librarian]: http://herawiki.berkeley.edu/doku.php/librarian

**Build.** Build this image by running the
[test-librarian-db/build.sh](test-librarian-db/build.sh) script *from a Git
checkout of the Librarian repository*. The built image will package the code
contained in the HEAD commit of that repository, and will be named something
like `hera-test-librarian-db:YYYYMMDD`. It will also label that image as
`hera-test-librarian-db:dev`.

**Launch.** When you start a container based on this image, you must set the
environment variable `MYSQL_ROOT_PASSWORD`.

**Access.** The container runs a [MySQL](https://www.mysql.com/) server on the
standard port, 3306.

On first startup the database is initialized with the following:

* A `source` named `RTP` with authenticator `9876543210`.
* A `source` named `Correlator` with authenticator `9876543211`.
* A `store` named `liblocal` with 100 GiB capacity and a `path_prefix` of
  `/hera/localstore`.
* A `store` named `rsync0` with 100 GiB capacity and an `rsync_prefix` of
  `rsync0`.

Note that while the database server records this information, the
[HERA Librarian] web application is the one that actually uses it, so
hostnames and such need to be resolvable by the [`test-librarian-db`]
container, not the database container.


`test-librarian`
----------------

This image runs an Apache/PHP server for testing the [HERA Librarian] web
application. It is based on the standard
[`php:7.0-apache`](https://hub.docker.com/_/php/) Docker image.

**Build.** Build this image by running the
[test-librarian/build.sh](test-librarian/build.sh) script *from a Git checkout
of the Librarian repository*. The built image will package the code contained
in the HEAD commit of that repository, and will be named something like
`hera-test-librarian:YYYYMMDD`. It will also label that image as
`hera-test-librarian:dev`.

**Launch.** When launching the service, you must
[“link”](https://docs.docker.com/v1.8/userguide/dockerlinks/) it with a
container running the [`test-librarian-db`] image under the internal name
`libdb`. **Note** that inter-container linking in Docker is evolving rapidly
and so the precise procedure for this may change. You must also set the
`HERA_LIBDB_PASSWORD` environment variable to the password used to access the
database. Finally, if you want to experiment with sample data, you should
mount a volume with HERA data at `/hera/localstore`.

**Access.** Once started, the service runs an instance of the Librarian web
app on port 80, accessible at the URL `/hl.php`.

See the description of the [`test-librarian-db`] image for a summary of the
configuration that the Librarian is preloaded with.


Running a Test Rig
==================

To test the HERA online system, you first need to build the various images
described above, following the directions given above for each image. You can
then proceed to launch each service.

First, the backing database for the Librarian:

```
HERA_LIBDB_PASSWORD=1234
sudo docker run -d --name libdb -e MYSQL_ROOT_PASSWORD=$HERA_LIBDB_PASSWORD hera-test-librarian-db:dev
```

Then the Librarian itself, linked to its backing database. We also expose the
Librarian web interface on <http://localhost:21106/hl.php> in case you want to
interact with it directly:

```
sudo docker run -d --name librarian -e HERA_LIBDB_PASSWORD=$HERA_LIBDB_PASSWORD \
  --link libdb:libdb -p 21106:80 hera-test-librarian:dev
```
