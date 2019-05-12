# docker-template

[![Build Status](https://travis-ci.com/madharjan/docker-template.svg?branch=master)](https://travis-ci.com/madharjan/docker-template)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-template.svg)](http://microbadger.com/images/madharjan/docker-template)

Docker container for Name Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Environment variables to create database, user and set password
* Bats [bats-core/bats-core](https://github.com/bats-core/bats-core) based test cases

## Template Server 1.0 (docker-template)

| Variable           | Default      | Example        |
|--------------------|--------------|----------------|
| DISABLE_TEMPLATE   | 0            | 1 (to disable) |
| TEMPLATE_DATABASE  | test         | mydb           |
| TEMPLATE_USERNAME  | user         | myuser         |
| TEMPLATE_PASSWORD  | pass         | mypass         |

## Build

### Clone this project

```bash
git clone https://github.com/madharjan/docker-template
cd docker-template
```

### Build Containers

```bash
# login to DockerHub
docker login

# build
make

# tests
make run
make tests
make clean

# tag
make tag_latest

# release
make release
```

### Tag and Commit to Git

```bash
git tag 1.0
git push origin 1.0
```

## Run Container

### Prepare folder on host for container volumes

```bash
sudo mkdir -p /opt/docker/template/etc/
sudo mkdir -p /opt/docker/template/lib/
sudo mkdir -p /opt/docker/template/log/
```

### Run `docker-template`

```bash
docker stop template
docker rm template

docker run -d \
  -e TEMPLATE_DATABASE=mydb \
  -e TEMPLATE_USERNAME=myuser \
  -e TEMPLATE_PASSWORD=mypass \
  -p 1234:1234 \
  -v /opt/docker/template/etc:/etc/template \
  -v /opt/docker/template/lib:/var/lib/template \
  -v /opt/docker/template/log:/var/log/template \
  --name template \
  madharjan/docker-template:1.0
```

## Run via Systemd

### Systemd Unit File - basic example

```txt
[Unit]
Description=Template Server

After=docker.service

[Service]
TimeoutStartSec=0

ExecStartPre=-/bin/mkdir -p /opt/docker/template/etc
ExecStartPre=-/bin/mkdir -p /opt/docker/template/lib
ExecStartPre=-/bin/mkdir -p /opt/docker/template/log
ExecStartPre=-/usr/bin/docker stop template
ExecStartPre=-/usr/bin/docker rm template
ExecStartPre=-/usr/bin/docker pull madharjan/docker-template:9.5

ExecStart=/usr/bin/docker run \
  -e TEMPLATE_DATABASE=mydb \
  -e TEMPLATE_USERNAME=myuser \
  -e TEMPLATE_PASSWORD=mypass \
  -p 1234:1234 \
  -v /opt/docker/template/etc:/etc/template/etc/ \
  -v /opt/docker/template/lib:/var/lib/template/ \
  -v /opt/docker/template/log:/var/log/template \
  --name template \
  madharjan/docker-template:1.0

ExecStop=/usr/bin/docker stop -t 2 template

[Install]
WantedBy=multi-user.target
```

### Generate Systemd Unit File

| Variable                 | Default          | Example                                                          |
|--------------------------|------------------|------------------------------------------------------------------|
| PORT                     | 1234             | 8080                                                             |
| VOLUME_HOME              | /opt/docker      | /opt/data                                                        |
| VERSION                  | 1.0              | latest                                                           |
| TEMPLATE_DATABASE        | postgres         | mydb                                                             |
| TEMPLATE_USERNAME        | postgres         | user                                                             |
| TEMPLATE_PASSWORD        |                  | pass                                                             |

```bash
docker run --rm -it \
  -e PORT=1234 \
  -e VOLUME_HOME=/opt/docker \
  -e VERSION=9.5 \
  -e TEMPLATE_DATABASE=mydb \
  -e TEMPLATE_USERNAME=user \
  -e TEMPLATE_PASSWORD=pass \
  madharjan/docker-template:1.0 \
  /bin/sh -c "template-systemd-unit" | \
  sudo tee /etc/systemd/system/template.service

sudo systemctl enable template
sudo systemctl start template
```
