#!/bin/bash

source $(dirname $0)/tools

say restart containers
docker restart nred mqtt flux gfna

say status
docker ps -a
