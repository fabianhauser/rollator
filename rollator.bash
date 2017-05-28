#!/bin/bash
set -e

WATCH_FILE=$1
WATCH_DIR=`dirname $1`
LOCK_FILE=$2
IMAGE=$3
SERVICE=$4

while true; do
  echo "Wait on a watchfile change"
  inotifywait -e create ${WATCH_DIR}

  while rm ${WATCH_FILE} 2>/dev/null; do 
    echo "Doing rollover"
    OLD_IMAGE_HASH=`docker images ${IMAGE} -q`

    echo "Pulling container"
    docker pull ${IMAGE}
  
    if [ "`docker images -q ${IMAGE}`" != "${OLD_IMAGE_HASH}" ]; then
      echo "Restarting container"
      systemctl restart ${SERVICE}
    else
      echo "No restart required (hashes match)"
    fi
    echo "Rollover finished"
  done
done
