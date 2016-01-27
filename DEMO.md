<!-- To HTML-ify this file locally, use `grip --wide` on it. -->

HERA Docker Test Rig: Demonstration
===================================

This document walks you through how to boot up the [HERA] services in a
[Docker]-based test environment.

[Docker]: https://www.docker.com/
[HERA]: http://reionization.org/


Preliminaries
-------------

First, I am assuming some broad familiarity with [Docker] here. Fortunately,
Docker is so hot right now, so if you need a more general introduction or
leads on a non-HERA-specific problem,
[we can help you with that](https://www.google.com/search?q=docker%20tutorial).

To do this demo, you need to load the appropriate server “images” into your
[Docker] installation. For serious development, you’ll probably end up having
to build them yourself, but for a quick test you can fetch them off of the
[Docker Hub]. This involves dowloading about 4 gigs of data. Run:

```
sudo docker pull docker.io/pkgw/hera-test-db
sudo docker pull docker.io/pkgw/hera-test-librarian
sudo docker pull docker.io/pkgw/hera-test-rtp
```

[Docker Hub]: https://hub.docker.com/

Note that you need to rerun these commands to fetch updated versions of these
images. For convenience we also give them shorter aliases:

```
sudo docker tag -f docker.io/pkgw/hera-test-db hera-test-db:latest
sudo docker tag -f docker.io/pkgw/hera-test-librarian hera-test-librarian:latest
sudo docker tag -f docker.io/pkgw/hera-test-rtp hera-test-rtp:latest
```

You will also need a data workspace. Set a shell variable `$DATA` to the path
of some directory where you can fool around and write a few gigs of data. Of
course, if you are typing the commands in multiple shells, or closing and
opening your shells, then you’ll need to re-set this variable (as well as a
few others defined below):

```
$ DATA=/customized/path/to/your/scratch/directory
```

(The eternal bane of Unix shell instructions: here and throughout I assume
`sh`-like shell syntax. If you use a `csh`-like shell, you must write `set foo
= bar` instead of `foo=bar`.)


One-time setup
--------------

You need to put some raw HERA data in `$DATA/raw`. I use a copy of the files
in `/data/pot0/zen.*.uv` on the `pot0` machine inside the Berkeley `digilab`
test setup — the JDs range from 2456892.20012 to 2456892.70844, and the total
size is about 0.5 GB. (By the way, with modern versions of SSH there are
awesome ways to make it so that you can `scp` files from `pot0` directly to
your local machine — ask Peter for the info.) **However**, the directory
structure should go `<datadir>/<integer JD>/zen.*.uv`, so if you copy the
digilab `pot0` files you need to put them inside a subdirectory named
`2456892` in raw. There are also data in `/data4/paper/HERA2015/2457*/` on
`folio` at UPenn, but those are the `.uvA` files and I don’t think they’re
fully raw.

**IMPORTANT**: if you’re running the demo on a Fedora or other SELinux-enabled
machine, your Docker containers may not be allowed to access these directories
by default. The files will appear inside the container but any access attempt
will result in “Permission denied” even when it looks like everything should
be OK. In that case, run:

```
sudo chcon -Rt svirt_sandbox_file_t $DATA
```

To allow the different services to automatically be able to look up each
other’s host names, we need to create a special virtual “network” in Docker
that they can all share:

```
sudo docker network create -d bridge hera
```

You only need to run this command the first time you try any of this stuff out.

**TODO**: I think this command requires a relatively recent version of Docker
— how recent?

We also need to set the database password as a shell variable. The database
won’t be visible outside of your machine so it doesn’t need to be a good
password:

```
$ DB_PASSWORD=1234
```


Demo: firing off RTP processing
-------------------------------

Now we can start with the fun stuff. The following command creates a Docker
container named `db` that will run the `hera-test-db` image — we are
essentially starting up a little encapsulated database server:

```
sudo docker run -d --net hera --name db -h db \
  -e MYSQL_ROOT_PASSWORD=$DB_PASSWORD \
  hera-test-db
```

Here’s a brief rundown of the options used here:

* The `-d` flag means to run the server as a daemon, in the background, rather
  than staying in the foreground of your terminal.
* The `--net hera` option says that this container should run on your `hera`
  network. This is needed for the containers to all talk to each other.
* The `--name db` option gives this container a fixed name that we can use to
  refer to it in subsequent `docker` commands.
* The `-h db` option sets the container’s hostname on the network. This is
  needed so that other servers can find it.
* The `-e MYSQL_ROOT_PASSWORD=$DB_PASSWORD` option sets an environment
  variable inside the container that, by the convention used in this particular
  image, sets the database’s root password.

If you ever want to examine the database directly, you can do so by running
the MySQL command-line client in a temporary container on the same network:

```
sudo docker run -it --net hera --rm mysql mysql -hdb -uroot -p$DB_PASSWORD
```

And if you want to see the logs from the MySQL server, run:

```
sudo docker logs db
```

Now we can start a Librarian container. We’re going to imagine that this
version is running on the HERA site, so it has access to the raw correlator
data.

```
mkdir -p $DATA/librarian/
cp -a $DATA/raw/* $DATA/librarian/

sudo docker run -d --net hera --name librarian -h librarian \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/librarian:/data \
  -p 21106:80 \
  hera-test-librarian
```

The extra options here are:

* The `-v` option gives the container access to a volume on your machine, so
  that it can see the raw data.
* The `-p` option exposes the Librarian’s web server (port 80 inside the
  container) on your machine (port 21106 on your machine). This makes it so
  that you can interact with the librarian directly by visiting
  <http://localhost:21106/hl.php>. The “authenticator” string embedded in the
  image is `9876543211`.

Now we tell the Librarian about the raw data. The easiest way to do this is by
using a temporary client image that has access to the full software stack:

```
sudo docker run --rm --net hera \
  -v $DATA/librarian:/data \
  hera-test-db /bin/bash -c \
  "echo '{\"sites\":{\"docker\":{\"url\":\"http://librarian/\",\"authenticator\":\"9876543211\"}}}' >/.hl_client.cfg &&
  /hera/librarian/add_obs_librarian.py --site docker --store liblocal /data/*/*.uv"
```

Now is a good time to visit <http://localhost:21106/hl.php> — you should see
the raw data listed in its output.

Now we can start up a couple of RTP servers that will crunch data for us. If
you’re running and re-running the demo, you should probably blow away their
subdirectories in `$DATA` for repeatability:

```
mkdir -p $DATA/rtpserver0 $DATA/rtpserver1

sudo docker run -d --net hera --name rtpserver0 -h rtpserver0 \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/rtpserver0:/data \
  -p 14204:14204 \
  hera-test-rtp hera-bootup.sh --server

sudo docker run -d --net hera --name rtpserver1 -h rtpserver1 \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/rtpserver1:/data \
  -p 14205:14204 \
  hera-test-rtp hera-bootup.sh --server
```

And an RTP client that will tell the servers what to do. For simplicity we also have it
host the raw data by aliasing it to the Librarian’s data directory:

```
sudo docker run -d --net hera --name rtpclient -h rtpclient \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/librarian:/data \
  hera-test-rtp hera-bootup.sh --client
```

Now we tell RTP about the data and reset the status of the observations to
trigger processing. *This is the part that should happen automagically once we
get RTP and the Librarian talking to each other!* We need to run this command
“inside” the `rtpclient` container because the hostname of the client is
inserted into the database; we can do this with the `docker exec` command.

```
sudo docker exec rtpclient /bin/bash -c \
  "/hera/rtp/bin/add_observations_paper.py /data/*/*.uv &&
  /hera/rtp/bin/reset_observations.py --file /data/*/*.uv"
```

If all is well this should set your RTP servers off to crunch the data, which
should start appearing in `$DATA/rtpserver*`. You can monitor progress with
commands like:

```
sudo docker logs -f rtpclient
```

while will follow the log output of the client (hit control-C to quit showing
the logs; this won’t disturb the container).

Finally, to clean up:

```
sudo docker stop rtpclient rtpserver0 rtpserver1 librarian db
sudo docker rm rtpclient rtpserver0 rtpserver1 librarian db
```


Demo: adding in a pot server
----------------------------

The following commands basically run through the same setup as the previous
demo, but store the data on a separate “pot” server that the Librarian and RTP
copy files from and to. To run these without building images, you will need to
run a `docker pull` command as at the top of this file but specifying the
`hera-rsync-pot` repository.

```
sudo docker run -d --net hera --name db -h db \
  -e MYSQL_ROOT_PASSWORD=$DB_PASSWORD \
  hera-test-db

mkdir -p $DATA/pot0/
cp -a $DATA/raw/* $DATA/pot0/

sudo docker run -d --net hera --name pot0 -h pot0 \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/pot0:/data \
  hera-rsync-pot

sudo docker run -d --net hera --name librarian -h librarian \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/librarian:/data \
  -p 21106:80 \
  hera-test-librarian

sudo docker exec pot0 /bin/bash -c \
  "echo '{\"sites\":{\"docker\":{\"url\":\"http://librarian/\",\"authenticator\":\"9876543211\"}}}' >/.hl_client.cfg &&
  /hera/librarian/add_obs_librarian.py --site docker --store pot0 /data/*/*.uv"

mkdir -p $DATA/rtpserver0

sudo docker run -d --net hera --name rtpserver0 -h rtpserver0 \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/rtpserver0:/data \
  hera-test-rtp hera-bootup.sh --server

sudo docker run -d --net hera --name rtpclient -h rtpclient \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/raw:/data \
  hera-test-rtp hera-bootup.sh --client

sudo docker exec pot0 /bin/bash -c \
  "/hera/rtp/bin/add_observations_paper.py /data/*/*.uv &&
  /hera/rtp/bin/reset_observations.py --file /data/*/*.uv"

# RTP crunching happens here

sudo docker stop rtpclient rtpserver0 librarian pot0 db

sudo docker rm rtpclient rtpserver0 librarian pot0 db
```
