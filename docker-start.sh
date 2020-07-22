#!/bin/bash
set -u -e -x
base="${1:-quay.io/travelping/upf:testing-tcp-fixes_v20.09-rc0-228-ge91a08234_release}"
docker rm -f vpptest || true
docker build -t vpptest --build-arg "BASE=${base}" .
docker run -it --privileged --shm-size 1024m --name vpptest vpptest
