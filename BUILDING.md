<!-- To HTML-ify this file locally, use `grip --wide` on it. -->

Building the Docker Images
==========================

To test server interactions with the current [HERA] codebase, you can just use
the images I’ve put up on [Docker Hub]. And you can do some development by
using Docker’s `-v` option to place modified code into the `/hera/` software
directories. But for serious work you will probably need to end up rebuilding
the Docker images. Fortunately, the process should be straightforward.

[HERA]: http://reionization.org/
[Docker Hub]: https://hub.docker.com/

It takes about 8 minutes to rebuild all of the images on my machine. The time
it takes will depend on your network connection, though, since the build
process involves downloading a lot of software.


Preliminaries
-------------

You can actually build the images without explicitly checking out all of the
HERA code, but it’s easiest to do so. You should check out the following
repositories:

* AIPY: [Aaron’s fork](https://github.com/AaronParsons/aipy/)
* Omnical: [Aaron’s fork](https://github.com/AaronParsons/omnical/)
* CAPO: [Danny’s fork](https://github.com/dannyjacobs/capo/)
* Librarian: [HERA-Team fork](https://github.com/HERA-Team/librarian/)
* RTP (AKA “still”): [HERA-Team fork](https://github.com/HERA-Team/RTP/)
* Monitor and Control: [HERA-Team fork](https://github.com/HERA-Team/Monitor_and_Control/)


Building the images
-------------------

I’ve written scripts that run the appropriate `docker build` commands. Run them
as follows. First:

```
./stack/build.sh <aipy> <omnical> <capo> <librarian> <rtp> <m&c>
```

**For example**, you might write:

```
./stack/build.sh ~/code/{aipy,omnical,capo,librarian,RTP,Monitor_and_Control}
```

… using some helpful `bash` expansion tricks, if you put the checkouts in
`~/code/`.

Here, each bracketed term should be the path to the corresponding Git
checkout. You can also provide a URL that allows you to define the input
software more reproducibly and/or avoid needing a local checkout of the
repository in question; see the comments in [fetch-tree.sh](fetch-tree.sh).

Running this script will create a Docker image named `hera-stack:YYYYMMDD`,
where the bit after the colon is the date. It will also alias it to
`hera-stack:latest`.

```
./ssh-stack/build.sh
```

This builds `hera-ssh-stack:YYYYMMDD` analogously.

```
./test-db/build.sh
```

This builds `hera-test-db:YYYYMMDD` analogously.

```
./test-librarian/build.sh <librarian>
```

This one needs to be pointed at just the Librarian Git checkout. This builds
`hera-test-librarian:YYYYMMDD` analogously.

```
./test-rtp/build.sh
```

This builds `hera-test-rtp:YYYYMMDD` analogously.


Publishing images
-----------------

This section probably isn’t relevant to you. It has notes on publishing built
Docker images to [Docker Hub].

1. Create an account on [Docker Hub]. My user name is `pkgw`, so my user page
is <https://hub.docker.com/r/pkgw/>.
1. Create repositories for the images you want to host on your account. The
push step will get pretty far before erroring out if you don’t!
1. Once an image has been built locally, “tag” it to indicate that it should
also be associated with an online registry: e.g. `docker tag
hera-stack docker.io/pkgw/hera-stack:20160127`.
1. Then “push” it to the repo.

Overall, the usual pattern will be:

```
date=$(date +%Y%m%d)
user=pkgw
base=hera-stack
docker tag $base:$date docker.io/$user/$base:$date
docker tag -f $base:$date docker.io/$user/$base:latest
docker push docker.io/$user/$base:$date
docker push docker.io/$user/$base:latest
```

This is automated in the [publish.sh](publish.sh) shell script.

**XXX**: Having a separate repository for each element of the stack means I
have to rendundantly upload the data for the software stack to each one
independently. Not the worst (if you’ve got OK bandwidth), but annoying.

The images that need to be uploaded are:

* `hera-stack`
* `hera-rsync-pot`
* `hera-test-db`
* `hera-test-librarian`
* `hera-test-rtp`
