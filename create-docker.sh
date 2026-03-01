#!/bin/bash
docker image build -t esp8266-sming .

docker container rm esp8266
docker container create --name esp8266 -it esp8266-sming /bin/bash
