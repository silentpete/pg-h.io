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

if [[ $(ps -ef | grep -v grep | grep -c prometheus_node_exporter) > 0 ]]; then
  info "found service, removing"
  pid=$(cat "${CWD}/${pid_file}")
  kill -9 "${pid}"
fi
