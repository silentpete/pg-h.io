#!/bin/sh

# TODO: remove repeated function into function file and source the file
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

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: sourced variable
pid_file="pid"

# TODO: put this in a sourced function
if [[ $(ps -ef | grep -v grep | grep -c prometheus_node_exporter) > 0 ]]; then
  info_msg "found service, removing"
  pid=$(cat "${CWD}/${pid_file}")
  kill -9 "${pid}"
fi
