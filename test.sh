#!/bin/bash
set -u -e -x
port=${1:-555}
while true; do
  ip netns exec client wrk -t200 -c40000 -d30 "http://10.0.0.2:${port}/dl"
  sleep 5
done
