#!/bin/sh

# debug_msg: pass in arguments and they will all print in cyan.
function debug_msg() {
  if [[ ${MSG_LEVEL} == "debug" ]]; then
    echo -e "\e[36mtime=\"$(date --rfc-3339='seconds')\" level=DEBUG msg=\"${@}\"\e[0m"
  fi
}

# info_msg: pass in arguments and they will all print in green.
function info_msg() {
  if [[ ${MSG_LEVEL} == "debug" || ${MSG_LEVEL} == "info" ]]; then
    echo -e "\e[32mtime=\"$(date --rfc-3339='seconds')\" level=INFO msg=\"${@}\"\e[0m"
  fi
}

# warn_msg: pass in arguments and they will all print in yellow.
function warn_msg() {
  if [[ ${MSG_LEVEL} == "debug" || ${MSG_LEVEL} == "info" || ${MSG_LEVEL} == "warn" ]]; then
    echo -e "\e[33mtime=\"$(date --rfc-3339='seconds')\" level=WARN msg=\"${@}\"\e[0m"
  fi
}

# error_msg: pass in arguments and they will all print in red, then the script will exit 1.
function error_msg() {
  echo -e "\e[31mtime=\"$(date --rfc-3339='seconds')\" level=ERROR msg=\"${@}\"\e[0m"
  exit 1
}

function install_docker_ce() {
  info_msg "install docker-ce"
  sudo yum install -y yum-utils device-mapper-persistent-data lvm2
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum-config-manager --enable docker-ce-edge
  sudo yum install -y docker-ce
  sudo systemctl enable docker
  sudo systemctl start docker
}

function install_docker_compose() {
  info_msg "install docker-compose"
  sudo curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo curl -L https://raw.githubusercontent.com/docker/compose/1.16.1/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
}

# create_container_storage takes two parameters, the container name and port.
# A /data/<container_name> directory will be created.
# A group and user will be created
# arg 1: container name
# arg 2: container port
function create_container_storage() {
  if [[ ! ${#} -eq 2 ]]; then
    error_msg "firewalld_add_service: received invalid number of arguments: ${#}"
  fi

  container=${1,,}
  uid=${2}
  gid=${uid}
  c_data_path="${data_storage_path}/${container}"

  if [[ ! -d "${c_data_path}" ]]; then
    info_msg "creating ${c_data_path}"
    sudo mkdir "${c_data_path}"
  fi

  if [[ ! $uid -eq 0 ]]; then
    info_msg "create ${container} group"
    sudo groupadd ${container} -g ${gid}
    # sudo useradd -u ${uid} -g ${gid} ${gid}
  fi

  info_msg "set permissions on directory"
  sudo chown ${uid}:${gid} -R "${c_data_path}"

}

# firewalld_add_service is used to create a services xml file which will be added.
# After creating the file, the firewalld service config will be reloaded.
# arg 1: service name
# arg 2: port number
function firewalld_add_service() {
  if [[ ! ${#} -eq 2 ]]; then
    error_msg "firewalld_add_service: received invalid number of arguments: ${#}"
  fi

  if [[ ! $(firewall-cmd --state) -eq "running" ]]; then
    error_msg "firewalld is not running"
  fi

  service="${1,,}"
  port="$2"
  f_path="/etc/firewalld/services"

  if [[ -f "${f_path}/${service}.xml" ]]; then
    warn_msg "${service}.xml already exists, guessing it is already allowed"
  else
    info_msg "creating firewalld service file ${service}.xml"
    contents="<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<service>\n  <short>${service}</short>\n  <description>${service}</description>\n  <port protocol=\"tcp\" port=\"${port}\"/>\n</service>"
    touch "${f_path}/${service}.xml"
    echo -e "${contents}" > "${f_path}/${service}.xml"
    # firewalld takes 5 seconds to see the newly added file
    # reference: https://firewalld.org/documentation/howto/add-a-service.html
    sleep 5

    info_msg "firewalld adding service ${service}"
    firewall-cmd --permanent --add-service=${service}
    if [[ $? -ne 0 ]]; then
      error_msg "firewalld add service failed"
    fi

    info_msg "firewalld reload services"
    firewall-cmd --reload
    if [[ $? -ne 0 ]]; then
      error_msg "firewalld reload services failed"
    fi
  fi
}

# Setup the Docker environment.
install_docker_ce
install_docker_compose

# Run all build.sh files
for VAR in $(find . -type f -name "build.sh"); do
  info_msg "building ${VAR}"
  ${VAR}
done

# Keep state of containers on host (I know, that's it's own debate)
data_storage_path="/data"
if [[ ! -d "${data_storage_path}" ]]; then
  info_msg "creating ${data_storage_path}"
  sudo mkdir "${data_storage_path}"
fi

# Create the host data storage location
create_container_storage "prometheus" "9090"
create_container_storage "grafana" "472"
create_container_storage "influxdb" "0"

# Add allowed services to firewalld
firewalld_add_service "cadvisor" "8181"
firewalld_add_service "node-exporter" "9100"
