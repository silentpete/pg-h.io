#!/bin/sh

# TODO: remove repeated function into function file and source the file
function info () {
  echo -e "\e[32mINFO: $1\e[0m"
}

function warn () {
  echo -e "\e[33mWARN: $1\e[0m"
}

function error () {
  echo -e "\e[31mERROR: $1\e[0m"
}

# Run all build.sh files
for VAR in $(find . -type f -name "build.sh"); do info "building ${VAR}"; ${VAR}; done;

data_storage_path="/data"

# Keep state of container on host (I know, that's it's own debate)
if [[ ! -d "${data_storage_path}" ]]; then
  info 'creating /data'
  sudo mkdir "${data_storage_path}"
fi

# Each container could be wrapped in a sourced function
# prometheus data
container="prometheus"
c_data_path="${data_storage_path}/${container}"
uid=9090
gid=9090
if [[ ! -d "${c_data_path}" ]]; then
  info "creating ${c_data_path}"
  sudo mkdir "${c_data_path}"
fi
info "set ${container} permissions"
sudo groupadd -r ${gid}
sudo useradd -u ${uid} -g ${gid} ${gid}
sudo chown ${uid}:${gid} -R "${c_data_path}"

# grafana data
container="grafana"
c_data_path="${data_storage_path}/${container}"
uid=104
gid=107
if [[ ! -d "${c_data_path}" ]]; then
  info "creating ${c_data_path}"
  sudo mkdir "${c_data_path}"
fi
info "set ${container} permissions"
sudo groupadd -r ${gid}
sudo useradd -u ${uid} -g ${gid} ${gid}
sudo chown ${uid}:${gid} -R "${c_data_path}"

# grafana data
container="influxdb"
c_data_path="${data_storage_path}/${container}"
uid=0
gid=0
if [[ ! -d "${c_data_path}" ]]; then
  info "creating ${c_data_path}"
  sudo mkdir "${c_data_path}"
fi
info "set ${container} permissions"
# sudo groupadd -r ${gid}
# sudo useradd -u ${uid} -g ${gid} ${gid}
sudo chown ${uid}:${gid} -R "${c_data_path}"
