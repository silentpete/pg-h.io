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

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: sourced variable
pid_file="pid"

info "stopping environment"
docker-compose stop
docker ps -a
docker-compose down
# Run all stop_service.sh files
for VAR in $(find . -type f -name "stop_service.sh"); do info "running ${VAR}"; ${VAR}; done;
