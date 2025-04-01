#!/bin/bash

source "$(dirname $0)/tools"

say stop containers
docker stop nred mqtt flux gfna

say remove containers
docker rm nred mqtt flux gfna

say remove network iot.net
docker network rm iot.net
