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
**The HERA test setup requires Docker version 1.10 or newer.** (Well, the
older instructions work with 1.9.)

I’ve written the commands below without a `sudo` prefix. On Linux, you
probably need them.

To do this demo, you need to load the appropriate server “images” into your
[Docker] installation. For serious development, you’ll probably end up having
to build them yourself, but for a quick test you can fetch them off of the
[Docker Hub]. This involves dowloading about 4 gigs of data. Run:

```
docker pull docker.io/pkgw/hera-test-db:20160216
docker pull docker.io/pkgw/hera-test-librarian:20160216
docker pull docker.io/pkgw/hera-test-rtp:20160216
docker pull docker.io/pkgw/hera-rsync-pot:20160216
```

[Docker Hub]: https://hub.docker.com/

For convenience we also give them shorter aliases:

```
docker tag -f docker.io/pkgw/hera-test-db:20160216 hera-test-db:latest
docker tag -f docker.io/pkgw/hera-test-librarian:20160216 hera-test-librarian:latest
docker tag -f docker.io/pkgw/hera-test-rtp:20160216 hera-test-rtp:latest
docker tag -f docker.io/pkgw/hera-rsync-pot:20160216 hera-rsync-pot:latest
```

You also need to download some raw HERA data. I use a copy of the files in
`/data/pot0/zen.*.uv` on the `pot0` machine inside the Berkeley `digilab` test
setup — the JDs range from 2456892.20012 to 2456892.70844, and the total size
is about 0.5 GB. (By the way, with modern versions of SSH there are awesome
ways to make it so that you can `scp` files from `pot0` directly to your local
machine — ask Peter for the info.) **However**, the directory structure should
go `<datadir>/<integer JD>/zen.*.uv`, so if you copy the digilab `pot0` files
you need to put them inside a subdirectory named `2456892` in `raw`. There are
also data in `/data4/paper/HERA2015/2457*/` on `folio` at UPenn, but those are
the `.uvA` files so some of the commands below would need changing.

Starting everything up
----------------------

Once you’ve pulled all of the the images and some example data, we can spin up
a self-contained test network.

First, change to the `rig` directory within a checkout of this `hera-images`
repository.

Create a directory called `onsitepot` and copy your demo data into it. The
final directory structure should look like `onsitepot/24.../zen.*.uv`.

To start up the servers on OS X:

```
DB_PASSWORD=1234 docker-compose up -d
```

This should say that it created and started a bunch of stuff. On Linux, the
needed command is probably:

```
sudo DB_PASSWORD=1234 /full/path/to/docker-compose -d
```

If you a running an older version of MacOS, then you might run into an ‘Illegal Instruction:4’. Follow the solution on [stack overflow](http://stackoverflow.com/questions/33595593/what-does-illegal-instruction-4-mean-with-docker-compose-on-a-mac).

We can now simulate various processes in the test rig.

### Registering data with the librarian and viewing the results

Let’s say that some new data have been created on a pot and that we want to
tell the Librarian about them. This command registers them:

```
docker exec rig_onsitepot_1 /bin/bash -c \
  "add_obs_librarian.py --site onsite --store onsitepot /data/*/*.uv
```

The default configuration provides web access to the Librarian over the port
21106, so you should be able to visit <http://localhost:21106/hl.php> with
`9876543210` as an authenticator and see the web interface. On OS X machines,
you need to replace `localhost` with a particular IP address
[as per this webpage](http://www.markhneedham.com/blog/2015/11/08/docker-1-9-port-forwarding-on-mac-os-x/).

### Registering data with the RTP system and processing everything

Let’s say that we want to push some data through the real time processor. For
now, RTP and the Librarian don’t talk to each other, so we need to manually
notify it about data:

```
docker exec rig_onsitepot_1 /bin/bash -c \
  "/hera/rtp/bin/add_observations_paper.py /data/*/*.uv"
```

To trigger processing, we need to flag the data as ready for processing:

```
docker exec rig_onsitepot_1 /bin/bash -c \
  "/hera/rtp/bin/reset_observations.py --file /data/*/*.uv"
```

Things should now start crunching inside the `rig_rtpclient_1` and
`rig_rtpserver_1` containers. The following commands will print out the output
from these containers, which should show the processing steps running:

```
docker logs rig_rtpclient_1
docker logs rig_rtpserver_1
```

Files will appear in the `rig` subdirectories `rtpclient`, `rtpserver`, and so
on. When datasets are fully processed, the processed data will appear back in
the `onsitepot` directory.

### Copying data from one librarian to another

Let’s say that we have some data on the “onsite” librarian and we want to copy
them to a different “offsite” librarian. As with the first example, you have
to tell the Librarian about your data **if you haven’t already done so**:

```
docker exec rig_onsitepot_1 /bin/bash -c \
  "add_obs_librarian.py --site onsite --store onsitepot /data/*/*.uv
```

Now we tell the librarian that we want to copy all of the data to the
`offsitepot` in `offsite` system:

```
docker exec rig_onsitepot_1 /bin/bash -c \
  "/var/www/html/copy_maker --remote_site offsite --remote_store offsitepot"
```

To actually execute the copies, we have to run the `copy_master` program on
the onsite librarian:

```
docker exec rig_onsitelibrarian_1 /bin/bash -c \
  "/var/www/html/copy_master"
```

This will only run ten copies by default. They will appear to succeed but due
to some database bugs there are actually errors, which you will see if you
visit <http://localhost:21106/hl.php?action=tasks> (again, replacing
`localhost` with an IP address if you’re on OS X).


### Cleaning up

Shutting down the test network is straightforward:

```
docker-compose down
```

This both stops *and deletes* your containers, so it blows away any setup that
you’ve done. It doesn’t delete the data directories creatd below `rig/`.


---

Older, harder instructions compatible with Docker 1.9
=====================================================

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
`2456892` in `raw`. There are also data in `/data4/paper/HERA2015/2457*/` on
`folio` at UPenn, but those are the `.uvA` files and I don’t think they’re
fully raw.

> **IMPORTANT**: if you’re running the demo on a Fedora or other SELinux-enabled
> machine, your Docker containers may not be allowed to access these directories
> by default. The files will appear inside the container but any access attempt
> will result in “Permission denied” even when it looks like everything should
> be OK. In that case, run:
>
> ```
> sudo chcon -Rt svirt_sandbox_file_t $DATA
> ```

To allow the different services to automatically be able to look up each
other’s host names, we need to create a special virtual “network” in Docker
that they can all share:

```
docker network create -d bridge hera
```

You only need to run this command the first time you try any of this stuff out.

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
docker run -d --net hera --name db -h db \
  -e POSTGRES_PASSWORD=$DB_PASSWORD \
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
* The `-e POSTGRES_PASSWORD=$DB_PASSWORD` option sets an environment
  variable inside the container that, by the convention used in this particular
  image, sets the database’s root password.

If you ever want to examine the database directly, you can do so by running
the Postgres command-line client in a temporary container on the same network:

```
docker run -it --net hera --rm hera-test-db psql -hdb -Upostgres
```

And if you want to see the logs from the Postgres server, run:

```
docker logs db
```

Now we can start a Librarian container. We’re going to imagine that this
version is running on the HERA site, so it has access to the raw correlator
data.

```
mkdir -p $DATA/onsitelibrarian/
cp -a $DATA/raw/* $DATA/onsitelibrarian/

docker run -d --net hera --name onsitelibrarian -h onsitelibrarian \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/onsitelibrarian:/data \
  -p 21106:80 \
  hera-test-librarian /launch.sh onsite
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
docker run --rm --net hera \
  -v $DATA/onsitelibrarian:/data \
  hera-test-db /bin/bash -c \
  "/hera/librarian/add_obs_librarian.py --site onsite --store onsitelibrarian /data/*/*.uv"
```

Now is a good time to visit <http://localhost:21106/hl.php> (with `9876543211`
as the authenticator) — you should see the raw data listed in its output.

Now we can start up a couple of RTP servers that will crunch data for us. If
you’re running and re-running the demo, you should probably blow away their
subdirectories in `$DATA` for repeatability:

```
mkdir -p $DATA/rtpserver0 $DATA/rtpserver1

docker run -d --net hera --name rtpserver0 -h rtpserver0 \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/rtpserver0:/data \
  -p 14204:14204 \
  hera-test-rtp /launch.sh --server

docker run -d --net hera --name rtpserver1 -h rtpserver1 \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/rtpserver1:/data \
  -p 14205:14204 \
  hera-test-rtp /launch.sh --server
```

And an RTP client that will tell the servers what to do. For simplicity we also have it
host the raw data by aliasing it to the Librarian’s data directory:

```
docker run -d --net hera --name rtpclient -h rtpclient \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/onsitelibrarian:/data \
  hera-test-rtp /launch.sh --client
```

Now we tell RTP about the data and reset the status of the observations to
trigger processing. *This is the part that should happen automagically once we
get RTP and the Librarian talking to each other!* We need to run this command
“inside” the `rtpclient` container because the hostname of the client is
inserted into the database; we can do this with the `docker exec` command.

```
docker exec rtpclient /bin/bash -c \
  "/hera/rtp/bin/add_observations_paper.py /data/*/*.uv &&
  /hera/rtp/bin/reset_observations.py --file /data/*/*.uv"
```

If all is well this should set your RTP servers off to crunch the data, which
should start appearing in `$DATA/rtpserver*`. You can monitor progress with
commands like:

```
docker logs -f rtpclient
```

while will follow the log output of the client (hit control-C to quit showing
the logs; this won’t disturb the container).

Finally, to clean up:

```
docker stop rtpclient rtpserver0 rtpserver1 onsitelibrarian db
docker rm rtpclient rtpserver0 rtpserver1 onsitelibrarian db
```


Demo: adding in a pot server
----------------------------

The following commands basically run through the same setup as the previous
demo, but store the data on a separate “pot” server that the Librarian and RTP
copy files from and to. To run these without building images, you will need to
run a `docker pull` command as at the top of this file but specifying the
`hera-rsync-pot` repository.

```
docker run -d --net hera --name db -h db \
  -e POSTGRES_PASSWORD=$DB_PASSWORD \
  hera-test-db

mkdir -p $DATA/onsitepot/
cp -a $DATA/raw/* $DATA/onsitepot/

docker run -d --net hera --name onsitepot -h onsitepot \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/onsitepot:/data \
  hera-rsync-pot

docker run -d --net hera --name onsitelibrarian -h onsitelibrarian \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/onsitelibrarian:/data \
  -p 21106:80 \
  hera-test-librarian /launch.sh onsite

docker exec onsitepot /bin/bash -c \
  "/hera/librarian/add_obs_librarian.py --site onsite --store onsitepot /data/*/*.uv"

mkdir -p $DATA/rtpserver0

docker run -d --net hera --name rtpserver0 -h rtpserver0 \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/rtpserver0:/data \
  hera-test-rtp /launch.sh --server

docker run -d --net hera --name rtpclient -h rtpclient \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/raw:/data \
  hera-test-rtp /launch.sh --client

docker exec onsitepot /bin/bash -c \
  "/hera/rtp/bin/add_observations_paper.py /data/*/*.uv &&
  /hera/rtp/bin/reset_observations.py --file /data/*/*.uv"

# RTP crunching happens here

docker stop rtpclient rtpserver0 onsitelibrarian onsitepot db
docker rm rtpclient rtpserver0 onsitelibrarian onsitepot db
```


Demo: file transfer offsite between Librarians
----------------------------------------------

The librarian containers don't run `sshd`, so we can’t `rsync` to them
directly — to test out the syncing we need to create an offsite pot.

**NOTE**: the copy commands below will cause errors since there are bugs that
need to be fixed
([github issue](https://github.com/HERA-Team/librarian/issues/2)).

```
docker run -d --net hera --name db -h db \
  -e POSTGRES_PASSWORD=$DB_PASSWORD \
  hera-test-db

mkdir -p $DATA/onsitelibrarian/
cp -a $DATA/raw/* $DATA/onsitelibrarian/

docker run -d --net hera --name onsitelibrarian -h onsitelibrarian \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/onsitelibrarian:/data \
  -p 21106:80 \
  hera-test-librarian /launch.sh onsite

mkdir -p $DATA/offsitepot/

docker run -d --net hera --name offsitepot -h offsitepot \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -v $DATA/offsitepot:/data \
  hera-rsync-pot

docker run -d --net hera --name offsitelibrarian -h offsitelibrarian \
  -e HERA_DB_PASSWORD=$DB_PASSWORD \
  -p 21107:80 \
  hera-test-librarian /launch.sh offsite

docker run --rm --net hera \
  -v $DATA/onsitelibrarian:/data \
  hera-test-db /bin/bash -c \
  "/hera/librarian/add_obs_librarian.py --site onsite --store onsitelibrarian /data/*/*.uv"

docker exec onsitelibrarian /bin/bash -c \
  "/var/www/html/copy_maker --remote_site offsite --remote_store offsitepot"

docker exec onsitelibrarian /bin/bash -c \
  "/var/www/html/copy_master"

docker stop onsitelibrarian offsitelibrarian offsitepot db
docker rm onsitelibrarian offsitelibrarian offsitepot db
```

After running `copy_master`, you should be able to visit
<http://localhost:21107/hl.php> and see that a batch of ten files has appeared
in the records of the offsite Librarian instance.
