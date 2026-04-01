#!/bin/bash

if [ -n "$1" ]; then
  PROJECT="$1"
else
  PROJECT="../esp8266-projects"
fi

if [ -z "$SMING_PATH" ]; then
  SMING_PATH="$(dirname $0)/../Sming"
fi

if [ ! -d "$PROJECT" ]; then
  echo "Error: Project directory '$PROJECT' does not exist."
  exit 1
fi

echo "Running ESP8266 Docker container with project directory: $PROJECT"

MAPPED_PATHS="-v $PROJECT:/workspace"

if [ -d "$SMING_PATH" ]; then
  MAPPED_PATHS="$MAPPED_PATHS -v $SMING_PATH:/opt/Sming"
fi

DEV=$( ls /dev/ttyUSB* 2>/dev/null | tail -n 1 )
GID=$( stat -c '%g' $DEV )
docker run -it --rm \
  --device=$DEV \
  --group-add $GID \
  $MAPPED_PATHS \
  esp8266-sming
