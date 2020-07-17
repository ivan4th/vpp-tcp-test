#!/bin/bash
set -u -e -x
docker build -t vpptest .
docker run -it --rm --privileged --shm-size 1024m --name vpptest vpptest
