#!/bin/sh

# Keep state of container on host (I know, that's it's own debate)
if [[ ! -d /data ]]; then
  echo 'creating /data'
  sudo mkdir /data
fi

# prometheus data
if [[ ! -d /data/prometheus ]]; then
  echo 'creating /data/prometheus'
  sudo mkdir /data/prometheus
fi

# always reset permission
sudo chown 9090:9090 -R /data/prometheus
