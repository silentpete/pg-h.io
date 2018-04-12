#!/bin/sh
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
docker build -t remote_storage_adapter ${CWD}/.
