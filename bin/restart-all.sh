#!/bin/bash

source $(dirname $0)/tools

say stop containers
docker restart nred mqtt flux gfna
