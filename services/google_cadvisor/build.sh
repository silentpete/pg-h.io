#!/bin/sh

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Stand up a golang container, pull the code into the container, build the binary
docker build -t temp-cadvisor-image ${CWD}/.

# Start the container, but because nothing keeps it running, it'll exit
docker run -d --name=cadvisor temp-cadvisor-image:latest

# Copy the built binary out of the container to the current directory
docker cp cadvisor:/tmp/cadvisor ${CWD}/

docker rm cadvisor

docker rmi temp-cadvisor-image
