#!/bin/sh

# TODO: remove repeated function into function file and source the file
function info () {
  echo -e "\e[32mINFO: $@\e[0m"
}
function warn () {
  echo -e "\e[33mWARN: $@\e[0m"
}
function error () {
  echo -e "\e[31mERROR: $@\e[0m"
}

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: sourced variable
pid_file="pid"

info "stopping environment"
docker-compose down
# Run all stop_service.sh files
for VAR in $(find . -type f -name "stop_service.sh"); do info "running ${VAR}"; ${VAR}; done;
