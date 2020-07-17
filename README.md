# VPP TCP test

Start VPP:

```console
$ ./docker-start.sh
```

This sets up networking, starts nginx webserver, and then starts VPP
under gdb and configures it. After VPP configuration is complete, run
the test script in another window:

```console
$ docker exec -it vpptest /test.sh
```

That will run a cyclic test based on [wrk](https://github.com/wg/wrk)
and [netem](https://man7.org/linux/man-pages/man8/tc-netem.8.html)
that you need to interrupt with Ctrl-C at some point.

The test uses the proxy example with nginx behind it by default.

You can specify port 80 for the test script to use `http_static`
instead of the proxy, but this crashes VPP immediately at the moment
with a SEGV in memory allocation code:

```console
$ docker exec -it vpptest /test.sh 80
```

You can also run `./start.sh` and `./test.sh` from a VM with VPP
installed, without using Docker.
