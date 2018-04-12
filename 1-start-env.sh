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

info "starting environment"

# Run all start_service.sh files
for VAR in $(find . -type f -name "start_service.sh"); do info "running ${VAR}"; ${VAR}; done;

docker-compose up -d
