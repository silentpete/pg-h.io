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

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: put this in sourced variables
pid_file="pid"

# TODO: put this in a sourced function
if [[ $(ps -ef | grep -v grep | grep -c prometheus_node_exporter) > 0 ]]; then
  info "found service, removing"
  pid=$(cat "${CWD}/${pid_file}")
  kill -9 "${pid}"
fi

info "starting prometheus node exporter"
${CWD}/prometheus_node_exporter --log.level="info" --log.format="logger:syslog?appname=node-exporter&local=7" &> /dev/null &
echo -e "$!" > "${CWD}/${pid_file}"