#!/bin/bash
set -e

WATCH_FILE=$1
WATCH_DIR=`dirname $1`
LOCK_FILE=$2
IMAGE=$3
SERVICE=$4

while true; do
  echo "Wait on a change on the watchfile"
  inotifywait -e create ${WATCH_DIR}

  echo "Waiting on lock release"
  ( flock -n 9 || exit 1
    echo "Lock aquired"
    while rm ${WATCH_FILE} 2>/dev/null; do 
      OLD_IMAGE_HASH=`docker images ${IMAGE} -q`

      echo "Pulling container"
      docker pull ${IMAGE}
  
      if [ "`docker images -q ${IMAGE}`" != "${OLD_IMAGE_HASH}" ]; then
        echo "Restarting container"
        systemctl restart ${SERVICE}
      else
        echo "No restart required (hashes match)"
      fi
    done
    echo "Lock freed"
  ) 9>$LOCK_FILE
  echo "Continue"
done
