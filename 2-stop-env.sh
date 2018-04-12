#!/bin/sh

function info () {
  echo -e "\e[32mINFO: $1\e[0m"
}

function warn () {
  echo -e "\e[33mWARN: $1\e[0m"
}

function error () {
  echo -e "\e[31mERROR: $1\e[0m"
}

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pid_file="pid"

info "stopping environment"
docker-compose down
# Run all stop_service.sh files
for VAR in $(find . -type f -name "stop_service.sh"); do info "running ${VAR}"; ${VAR}; done;
