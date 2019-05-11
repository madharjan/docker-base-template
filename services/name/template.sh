#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

NAME_BUILD_PATH=/build/services/name

## Install Name Server
apt-get install -y --no-install-recommends name

mkdir -p /etc/service/name
cp ${POSTGRESQL_BUILD_PATH}/name.runit /etc/service/name/run
chmod 750 /etc/service/name/run

## Configure logrotate
