#!/bin/bash
set -u -e -x

ctlsock="/run/vpp/cli-vpp1.sock"

function ctl {
  vppctl -s "${ctlsock}" "$@"
}

function config_vpp {
  while [[ ! -e ${ctlsock} ]]; do
    sleep 1
  done

  ctl create host-interface name vpp0
  ctl set interface state host-vpp0 up
  ctl set interface ip address host-vpp0 10.0.0.2/24
  ctl create host-interface name vpp1
  ctl set interface state host-vpp1 up
  ctl set interface ip address host-vpp1 10.0.1.2/24

  ctl http static server www-root /www uri tcp://0.0.0.0/80 cache-size 2m
  ctl test proxy server server-uri tcp://10.0.0.2/555 client-uri tcp://10.0.1.1/666
}

ip netns add client
ip link add vpp0 type veth peer name client
ip link set dev client netns client
ip netns exec client ip link set dev lo up
ip netns exec client ip link set dev client up
ip netns exec client ip addr add 10.0.0.1/24 dev client
ip link set dev vpp0 up

ip netns exec client tc qdisc add dev client root netem \
   loss 15% delay 100ms 300ms duplicate 10%

ip netns add server
ip link add vpp1 type veth peer name server
ip link set dev server netns server
ip netns exec server ip link set dev lo up
ip netns exec server ip link set dev server up
ip netns exec server ip addr add 10.0.1.1/24 dev server
ip link set dev vpp1 up

mkdir /www

truncate -s 100 /www/dl
cat >/etc/nginx/conf.d/default.conf <<EOF
server {
    listen       666;
    server_name  localhost;

    location / {
        root   /www;
    }
}
EOF
ip netns exec server nginx

# ( cd /www && ip netns exec server python -m SimpleHTTPServer 666 & )

config_vpp &

# sysctl vm.nr_hugepages=0 || true
# mount /sys -o remount,ro

echo 'run' > /tmp/cmds
echo 'bt' >> /tmp/cmds
gdb -x /tmp/cmds --args \
    /usr/bin/vpp \
    unix { nodaemon cli-listen "${ctlsock}" } \
    api-segment { prefix vpp1 } \
    cpu { workers 0 }
