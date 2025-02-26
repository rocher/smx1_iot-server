#!/bin/bash

source $(dirname $0)/tools

say stop containers
docker stop nred mqtt flux gfna

say status
docker ps -a
