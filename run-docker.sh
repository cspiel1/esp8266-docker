#!/bin/bash

if [ -n "$1" ]; then
  PROJECT="$1"
else
  PROJECT="../esp8266-projects"
fi

if [ ! -d "$PROJECT" ]; then
  echo "Error: Project directory '$PROJECT' does not exist."
  exit 1
fi

echo "Running ESP8266 Docker container with project directory: $PROJECT"

docker run -it --rm \
  --device=/dev/ttyUSB0 \
  -v $PROJECT:/workspace \
  esp8266-sming
