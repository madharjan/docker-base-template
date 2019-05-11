#!/bin/bash

set -e

if [ "${DEBUG}" = true ]; then
  set -x
fi

DISABLE_TEMPLATE=${DISABLE_TEMPLATE:-0}

if [ ! "${DISABLE_TEMPLATE}" -eq 0 ]; then
  touch /etc/service/TEMPLATE/down
else
  rm -f /etc/service/TEMPLATE/down
fi

TEMPLATE_VERSION=${TEMPLATE_VERSION:-1.5}

TEMPLATE_DATABASE=${TEMPLATE_DATABASE:-postgres}
TEMPLATE_USER=user
TEMPLATE_GROUP=group

TEMPLATE_DATA_DIR=${TEMPLATE_DATA_DIR:-/var/lib/TEMPLATE/}

mkdir -p ${TEMPLATE_DATA_DIR}
cd ${TEMPLATE_DATA_DIR}

if [ ! -s "$TEMPLATE_DATA_DIR/VERSION" ]; then
  echo "Initializing Template ..."


  echo 'Template init process complete; ready for start up.'
fi
