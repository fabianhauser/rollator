#!/bin/bash
set -e

WATCH_FILE=$1
LOCK_FILE=$2
IMAGE=$3
SERVICE=$4

while true; do
  echo Wait on a change on the watchfile
  inotifywait -e create ${WATCH_FILE}

  echo Waiting on lock release
  ( flock -n 9 || exit 1
    echo Lock aquired
    while rm restart 2>/dev/null; do 
      OLD_IMAGE_HASH=`docker images ${IMAGE} -q`

      docker pull ${IMAGE}
  
      if [ "`docker images ${IMAGE} -q`" == "${OLD_IMAGE_HASH}" ]; then
        systemctl restart ${SERVICE}
      fi
    done
    echo Lock freed
  ) 9>$LOCK_FILE
  echo Continue
done
