#!/bin/sh

# TODO: remove repeated function into function file and source the file
function info () {
  echo -e "\e[32m$(date --rfc-3339='seconds') INFO: $@\e[0m"
}
function warn () {
  echo -e "\e[33m$(date --rfc-3339='seconds') WARN: $@\e[0m"
}
function error () {
  echo -e "\e[31m$(date --rfc-3339='seconds') ERROR: $@\e[0m"
  exit 1
}

info "starting environment"

# Run all start_service.sh files
for VAR in $(find . -type f -name "start_service.sh"); do info "running ${VAR}"; ${VAR}; done;

docker-compose up -d
