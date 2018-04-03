#!/bin/sh

# Keep state of container on host (I know, that's it's own debate)
if [[ ! -d /data ]]; then
  echo 'creating /data'
  sudo mkdir /data
fi

# prometheus data
container=prometheus
uid=9090
gid=9090
if [[ ! -d /data/${container} ]]; then
  echo -e "creating /data/${container}"
  sudo mkdir /data/${container}
fi
echo -e "set ${container} permissions"
sudo groupadd -r ${gid}
sudo useradd -u ${uid} -g ${gid} ${gid}
sudo chown ${uid}:${gid} -R /data/${container}

# grafana data
container=grafana
uid=104
gid=107
if [[ ! -d /data/${container} ]]; then
  echo -e "creating /data/${container}"
  sudo mkdir /data/${container}
fi
echo -e "set ${container} permissions"
sudo groupadd -r ${gid}
sudo useradd -u ${uid} -g ${gid} ${gid}
sudo chown ${uid}:${gid} -R /data/${container}
