#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
    echo "$0: assuming arguments for x-proxy"
    set -- x-proxy "$@"
fi

if [ ! -f "/opt/proxy.conf" ]; then
cat <<-EOF > "/opt/proxy.conf"
editable: true
debuggable: false
server:
  name: ""
  host: 0.0.0.0
  port: 9090
  auth:
    username: ""
    password: ""
phrases: {}
miner_group_by: IP
logger:
  level: info
  outputs: output.log
  submit: submit.csv
  slice: 5
  max: 100
tasks:
- name: Arweave
  scan: 60
  block_interval: 300
  chain: AR
  autolines:
  - https://ar.hpool.com/proxy/lines
  info:
    url: https://ar.hpool.com/x-proxynode/getMiningInfo
    interval: 500
    target: 8000000000000000
    method: GET
  submit:
    url: https://ar.hpool.com/x-proxynode/nonce
    url2: ""
    target: 8000000000000000
    upload_best: false
    require_phrase: false
    retry: 2
  status:
    url: https://ar.hpool.com/x-proxynode/status
    interval: 60
    combine: true
  headers:
    X-Account: ""
EOF
fi

if [ "$1" = "x-proxy" ] ; then
    if [ -n "$APIKEY" ]; then
        echo "$(sed "s!X-Account: \"\"!X-Account: \"$APIKEY\"!g" proxy.conf)" > proxy.conf
    fi
    chown -hR nobody .
    cat proxy.conf
    echo "run : $@ "
    exec gosu nobody "$@"
fi

echo "run some: $@"
exec "$@"
