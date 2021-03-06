#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

TEMPLATE_VERION=1.0
TEMPLATE_BUILD_PATH=/build/services/template

## Install Template Server
apt-get install -y --no-install-recommends template

mkdir -p /etc/service/template
cp ${TEMPLATE_BUILD_PATH}/template.runit /etc/service/template/run
chmod 750 /etc/service/template/run

## Configure logrotate
