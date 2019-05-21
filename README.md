# docker-template

[![Build Status](https://travis-ci.com/madharjan/docker-template.svg?branch=master)](https://travis-ci.com/madharjan/docker-template)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-template.svg)](http://microbadger.com/images/madharjan/docker-template)

Docker container for Name Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Environment variables to user and set password
* Bats [bats-core/bats-core](https://github.com/bats-core/bats-core) based test cases

## Template Server 1.0 (docker-template)

### Environment

| Variable           | Default      | Example        |
|--------------------|--------------|----------------|
| DISABLE_TEMPLATE   | 0            | 1 (to disable) |
| TEMPLATE_USERNAME  | user         | myuser         |
| TEMPLATE_PASSWORD  | pass         | mypass         |

## Build

```bash
# clone project
git clone https://github.com/madharjan/docker-base-template
cd docker-base-template

# build
make

# tests
make run
make test

# clean
make clean
```

## Run

**Note**: update environment variables below as necessary

```bash
# prepare foldor on host for container volumes
sudo mkdir -p /opt/docker/template/etc/
sudo mkdir -p /opt/docker/template/lib/
sudo mkdir -p /opt/docker/template/log/

# stop & remove previous instances
docker stop template
docker rm template

# run container
docker run -d \
  -e TEMPLATE_USERNAME=myuser \
  -e TEMPLATE_PASSWORD=mypass \
  -p 1234:1234 \
  -v /opt/docker/template/etc:/etc/template \
  -v /opt/docker/template/lib:/var/lib/template \
  -v /opt/docker/template/log:/var/log/template \
  --name template \
  madharjan/docker-template:1.0
```

## Systemd Unit File

**Note**: update environment variables below as necessary

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
  -e TEMPLATE_USERNAME=myuser \
  -e TEMPLATE_PASSWORD=mypass \
  -p 1234:1234 \
  -v /opt/docker/template/etc:/etc/template \
  -v /opt/docker/template/lib:/var/lib/template \
  -v /opt/docker/template/log:/var/log/template \
  --name template \
  madharjan/docker-template:1.0

ExecStop=/usr/bin/docker stop -t 2 template

[Install]
WantedBy=multi-user.target
```

## Generate Systemd Unit File

| Variable                 | Default          | Example                                                          |
|--------------------------|------------------|------------------------------------------------------------------|
| PORT                     |                  | 8080                                                             |
| VOLUME_HOME              | /opt/docker      | /opt/data                                                        |                                                           |
|                          |                  |                                                                  |
| TEMPLATE_USERNAME        |                  | user                                                             |
| TEMPLATE_PASSWORD        |                  | pass                                                             |

```bash
# generate template.service
docker run --rm \
  -e PORT=8080 \
  -e VOLUME_HOME=/opt/docker \
  -e NAME=template \
  -e TEMPLATE_USERNAME=user \
  -e TEMPLATE_PASSWORD=pass \
  madharjan/docker-template:1.0 \
  template-systemd-unit | \
  sudo tee /etc/systemd/system/template.service

sudo systemctl enable template
sudo systemctl start template
```
