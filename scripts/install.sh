#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

TEMPLATE_CONFIG_PATH=/build/config/template

apt-get update

## Install Template and runit service
/build/services/template/template.sh

mkdir -p /etc/my_init.d
cp /build/services/20-template.sh /etc/my_init.d
chmod 750 /etc/my_init.d/20-template.sh

cp /build/bin/template-systemd-unit /usr/local/bin
chmod 750 /usr/local/bin/template-systemd-unit
