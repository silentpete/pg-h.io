#!/bin/sh

# TODO: remove repeated function into function file and source the file
function info() {
  echo -e "\e[32mINFO: $1\e[0m"
}

function warn() {
  echo -e "\e[33mWARN: $1\e[0m"
}

function error() {
  echo -e "\e[31mERROR: $1\e[0m"
  exit 1
}

# firewalld_add_service is used to create a services xml file which will be added.
# After creating the file, the firewalld service config will be reloaded.
# arg 1: service name
# arg 2: port number
function firewalld_add_service() {
  if [[ ! ${#} -eq 2 ]]; then
    error "firewalld_add_service: received invalid number of arguments: ${}#"
  fi

  if [[ ! $(firewall-cmd --state) -eq "running" ]]; then
    error "firewalld is not running"
  fi

  service="${1,,}"
  port="$2"
  f_path="/etc/firewalld/services"

  if [[ -f "${f_path}/${service}.xml"  ]]; then
    warn "${service}.xml already exists, guessing it is already allowed"
  else

  info "creating firewalld service file ${service}.xml"
  contents="<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<service>\n  <short>${service}</short>\n  <description>${service}</description>\n  <port protocol=\"tcp\" port=\"${port}\"/>\n</service>"
  touch "${f_path}/${service}.xml"
  echo -e "${contents}" > "${f_path}/${service}.xml"
  # firewalld takes 5 seconds to see the newly added file
  # reference: https://firewalld.org/documentation/howto/add-a-service.html
  sleep 5

  info "firewalld adding service ${service}"
  firewall-cmd --permanent --add-service=${service}
  if [[ $? -ne 0 ]]; then
    error "firewalld add service failed"
  fi

  info "firewalld reload services"
  firewall-cmd --reload
  if [[ $? -ne 0 ]]; then
    error "firewalld reload services failed"
  fi

  fi
}

# Run all build.sh files
for VAR in $(find . -type f -name "build.sh"); do
  info "building ${VAR}"
  ${VAR}
done

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
uid=472 # 5.1.0 change to running as 472:472
gid=472
if [[ ! -d "${c_data_path}" ]]; then
  info "creating ${c_data_path}"
  sudo mkdir "${c_data_path}"
fi
info "set ${container} permissions"
sudo groupadd -r ${gid}
sudo useradd -u ${uid} -g ${gid} ${gid}
sudo chown ${uid}:${gid} -R "${c_data_path}"

# influxdb data
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

# Add allowed services to firewalld
firewalld_add_service "cadvisor" "8181"
firewalld_add_service "node-exporter" "9100"
