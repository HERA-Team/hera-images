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
might need it.

### Pulling images

To do this demo, you need to load the appropriate server “images” into your
[Docker] installation. For serious development, you’ll probably end up having
to build them yourself, but for a quick test you can fetch them off of the
[Docker Hub]. This involves dowloading about 4 gigs of data. In the directory
containing this file, run:

```
./pull.sh -t 20160422
```

[Docker Hub]: https://hub.docker.com/

This will download the needed images and give them useful short aliases — the
`docker pull` and `docker tag` lines printed by the script show what it’s
doing.

For development, you sometimes need to build images yourself. See
[BUILDING.md] for instructions on that.

### Seeding with data

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


Trying it out
-------------

Once you’ve pulled all of the the images and some example data, we can spin up
a self-contained test network. First, change to the `rig` directory within a
checkout of this `hera-images` repository.

Next, create a directory called `onsitepot` and copy your demo data into it.
The final directory structure should look like `onsitepot/24.../zen.*.uv`.

To start up the servers:

```
export DB_PASSWORD=1234
docker-compose up -d
```

This should say that it created and started a bunch of stuff. If you a running
an older version of MacOS, then you might run into an ‘Illegal Instruction:4’.
Follow the solution on
[stack overflow](http://stackoverflow.com/questions/33595593/what-does-illegal-instruction-4-mean-with-docker-compose-on-a-mac).

Most nontrivial examples need some data. Start out by copying some data into a
directory named something like `rig/onsitepot/2456892/`.

We can now simulate various processes in the test rig.

### Registering data with the librarian and viewing the results

Let’s say that some new data have been created on a pot and that we want to
tell the Librarian about them. This command registers them:

```
docker exec rig_onsitepot_1 /bin/bash -c \
  "add_obs_librarian.py --site onsite-correlator --store onsitepot --store_path /data '*/*.uv*'"
```

This should churn for a while, then print out the names of the files it added.

The default configuration provides web access to the Librarian over the port
21106, so you should be able to visit <http://localhost:21106/> with
`9876543210` as the “authenticator” and see the web interface. On OS X machines,
you need to replace `localhost` with a particular IP address
[as per this webpage](http://www.markhneedham.com/blog/2015/11/08/docker-1-9-port-forwarding-on-mac-os-x/).

### Copying data from one librarian to another

Let’s say that we have some data on the “onsite” librarian and we want to copy
them to a different “offsite” librarian. As with the first example, you have
to tell the Librarian about your data if you haven’t already done so:

```
docker exec rig_onsitepot_1 /bin/bash -c \
  "add_obs_librarian.py --site onsite-correlator --store onsitepot --store_path /data '*/*.uv*'"
```

(Running this command twice results in nothing changing — the Librarian already
knows about these files so it doesn’t need to do anything.)

The rest rig creates an “offsite” Librarian as well. Its web UI is exposed to
the local host on port 21107, so you can access it here:
<http://localhost:21107/>. (Once again, on a Mac you need to change
`localhost` to a magic IP address.)

We can now launch a copy of a file like this:

```
docker exec rig_onsitepot_1 /bin/bash -c \
  "launch_librarian_copy.py onsite-rtp offsite-karoo zen.2456892.48958.xx.uv"
```

where the last argument is the name of a file obtained from the
[localhost onsite status UI](http://localhost:21106/). The copy will happen
very quickly since everything is happening on your one machine. If you now
check out the [status UI of the offsite Librarian](http://localhost:21107/),
you should see that the file has appeared. You should also see it in the
`rig/offsitepot/` data-storage directory.

### Registering data with the RTP system and processing everything

Let’s say that we want to push some data through the real time processor. For
now, RTP and the Librarian don’t talk to each other, so we need to manually
notify it about data:

```
docker exec rig_onsitepot_1 /bin/bash -c \
  "/hera/rtp/bin/add_observations_paper.py /data/*/*.uv*"
```

To trigger processing, we need to flag the data as ready for processing:

```
docker exec rig_onsitepot_1 /bin/bash -c \
  "/hera/rtp/bin/reset_observations.py --file /data/*/*.uv*"
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

### Cleaning up

Shutting down the test network is straightforward:

```
docker-compose down
```

This both stops *and deletes* your containers, so it blows away any setup that
you’ve done. It doesn’t delete the data directories creatd below `rig/`. To
really blow everything away, in `rig/` you need to run:

```
rm -rf offsitelibrarian offsitepot onsitelibrarian onsitepot
```
