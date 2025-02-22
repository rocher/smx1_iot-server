#!/bin/bash

docker stop nred mqtt flux gfna
docker rm   nred mqtt flux gfna
docker network rm iot.net
