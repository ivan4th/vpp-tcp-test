# VPP TCP test

Start VPP:

```console
$ ./docker-start.sh [IMAGE_NAME]
```

Prebuilt image names are:
* `quay.io/travelping/upf:testing-tcp-fixes_v20.09-rc0-228-ge91a08234_debug` - debug image
* `quay.io/travelping/upf:testing-tcp-fixes_v20.09-rc0-228-ge91a08234_release` - release image

The image name defaults to the release one.

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
instead of the proxy:

```console
$ docker exec -it vpptest /test.sh 80
```

You can also run `./start.sh` and `./test.sh` from a VM with VPP
installed, without using Docker.

# Building the base VPP images

The images are built from this branch on GitHub:
https://github.com/travelping/vpp/tree/testing/tcp-fixes

This branch is based on
[a commit in VPP master](https://github.com/fdio/vpp/commit/dd4ccf2623b547654d215ffcf42f9813e42aa90c)
that was the HEAD of the master branch as of Jul 22 2020.

It includes Travelping's
[build files](https://github.com/travelping/vpp/commit/25e25920beedc5a8d978f24d19b0233682a51888)
and the proposed
[fix for pending TCP timers](https://github.com/travelping/vpp/commit/e91a082345f235e7f6cd89d2b3680e7bc23b1e05).
The images are built by our GitLab CI pipelines [like this](https://gitlab.com/travelping/vpp/-/pipelines/169410308).

In order to build the image from source, you need to run the following
``` console
$ # for release image
$ DOCKER_BUILDKIT=1 docker build -f extras/docker/Dockerfile -t vpp .
$ # for debug image
$ DOCKER_BUILDKIT=1 docker build -f extras/docker/Dockerfile.devel -t vpp .
```

# Test results

* [crash-debug-http_static-mspace_malloc-macdocker.log](logs/crash-debug-http_static-mspace_malloc-macdocker.log): Mac Docker, debug build, http_static, crash in `mspace_malloc()`
* [crash-debug-http_static-tcp_prepare_retransmit_segment.log](logs/crash-debug-http_static-tcp_prepare_retransmit_segment.log): Linux Docker, debug build, TCP retransmit crash
* [crash-debug-proxy-dead-session-macdocker.log](logs/crash-debug-proxy-dead-session-macdocker.log): Mac Docker, debug build, proxy, a crash on reference to a free proxy session
* [crash-debug-proxy-svm_fifo-macdocker.log](logs/crash-debug-proxy-svm_fifo-macdocker.log): Mac Docker, debug build, proxy, a crash in SVM FIFO code (`svm_fifo_init_ooo_lookup()`)
* [crash-debug-proxy-svm_fifo.log](logs/crash-debug-proxy-svm_fifo.log): Linux Docker, debug build, a crash in SVM FIFO code (`svm_fifo_init_ooo_lookup()`)
* [crash-release-http_static-timer_remove.log](logs/crash-release-http_static-timer_remove.log): Linux Docker, release build, a crash in `timer_remove()`
* [crash-release-proxy-svm_fifo.log](logs/crash-release-proxy-svm_fifo.log): Linux Docker, release build, a crash in SVM FIFO code (`f_update_ooo_deq()`)
