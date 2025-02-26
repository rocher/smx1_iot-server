#!/bin/bash

source $(dirname $0)/tools

say get image NodeRED
docker pull nodered/node-red

say get image Eclipse-Mosquitto
docker pull eclipse-mosquitto

say get image InfluxDB
docker pull influxdb

say get image Grafana
docker pull grafana/grafana

say status
docker images
