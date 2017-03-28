#!/bin/bash
set -e

WATCH_FILE=$1
LOCK_FILE=$2
IMAGE=$3
SERVICE=$4

while true; do
  # Wait on a change on the watchfile
  inotifywait -e create ${WATCH_FILE}

  echo Waiting on lock release
  if [ `flock -n $LOCK_FILE}` ]; then
    echo Lock aquired
    while rm touchfile 2>/dev/null; do 
      OLD_IMAGE_HASH=`docker images ${IMAGE} -q`

      docker pull ${IMAGE}
  
      if [ "`docker images ${IMAGE} -q`" == "${OLD_IMAGE_HASH}" ]; then
        systemctl restart ${SERVICE}
      fi
    done
    flock -u ${LOCK_FILE}
    echo Lock freed
  else
    echo Deployment currently running
  fi
done
