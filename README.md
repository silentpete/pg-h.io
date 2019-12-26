# pg-h.io

[![Go Report Card](https://goreportcard.com/badge/github.com/silentpete/pg-h.io)](https://goreportcard.com/report/github.com/silentpete/pg-h.io)

## Why pg-h.io?

I work within a linux vagrant box all day long for the most part. I ask programs for help, so this is my help page.

## What is the reason for this site?

I have always wanted to help others and I love what I do for work everyday. I would like to basically try to give out anything I've learned in the broad categories of IT, and this will be where I start writing those things out. I also like to continue learning, so this will also be a place where I can attempt to learn more.

## Local Development Setup

1. Create Vagrant Dev Environment, which can be found at:

    [https://github.com/silentpete/vagrant-box-process-centos](https://github.com/silentpete/vagrant-box-process-centos)

1. Edit hosts file

    ```none
    127.0.0.1 pg-h.io prometheus.pg-h.io alertmanager.pg-h.io blog.pg-h.io cadvisor.pg-h.io grafana.pg-h.io influxdb.pg-h.io node-exporter.pg-h.io
    ```

1. Once in Vagrant host, install git

    ```none
    yum install -y git
    ```

1. Git clone repo

    ```none
    git clone https://github.com/silentpete/pg-h.io.git
    ```

1. Run the Prep Script

    ```none
    ./0-prep-env.sh
    ```

    - the setup for alertmanager asks for gmail app settings.
1. Run the Start Script with the DEV switch. This will give nginx a different configuration.

    ```none
    DEV="nossl." ./1-start-env.sh
    ```

## Linode Setup

I am currently running this site on Linode.com. I am used to working with CentOS 7, so that is the OS for the host I'm writing this for. The host is the minimum template with 1 CPU, 1GB of memory, and 20/25GB of Disk.

1. Stand up Linode Host and SSH in
1. Install git

    ```none
    yum install -y git
    ```

1. Git clone repo

    ```none
    git clone https://github.com/silentpete/pg-h.io.git
    ```

1. Run the Prep Script

    ```none
    ./0-prep-env.sh
    ```

    - the setup for alertmanager asks for gmail app settings.
1. Run the Start Script

    ```none
    ./1-start-env.sh
    ```

Currently this process takes about 10 minutes, but I have plans to reduce it.
