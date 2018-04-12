#!/bin/sh

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Stand up a golang container, pull the code into the container, build the binary
docker build -t temp-pne-image ${CWD}/.

# Start the container, but because nothing keeps it running, it'll exit
docker run -d --name=pne temp-pne-image:latest

# Copy the built binary out of the container to the current directory
docker cp pne:/tmp/prometheus_node_exporter ${CWD}/

docker rm pne

docker rmi temp-pne-image
