#!/bin/bash

# Pull all required docker images
docker pull nodered/node-red
docker pull eclipse-mosquitto
docker pull influxdb
docker pull grafana/grafana

# Create iot.net network
docker network create \
       --driver bridge \
       --subnet 172.22.0.0/16 \
       --gateway 172.22.0.1 \
       iot.net

# Run all required docker containers
docker run \
       --detach \
       --hostname nred \
       --user root \
       --name nred \
       --network iot.net \
       --ip 172.22.0.11 \
       --publish 1880:1880 \
       --volume $HOME/iot-server/vol/nred/data:/data \
       nodered/node-red

docker run \
       --detach \
       --hostname mqtt \
       --name mqtt \
       --network iot.net \
       --ip 172.22.0.12 \
       --publish 1883:1883 \
       --volume $HOME/vol/mqtt/config:/mosquitto/config \
       --volume $HOME/vol/mqtt/data:/mosquitto/data \
       --volume $HOME/mosquitto/log:/mosquitto/log \
       eclipse-mosquitto

docker run \
       --detach \
       --hostname flux \
       --name flux \
       --network iot.net \
       --ip 172.22.0.13 \
       --publish 8086:8086 \
       --volume $HOME/vol/flux/data:/var/lib/influxdb2 \
       --volume $HOME/vol/flux/config:/etc/influxdb2 \
       --env DOCKER_INFLUXDB_INIT_MODE=setup \
       --env DOCKER_INFLUXDB_INIT_USERNAME=qwe \
       --env DOCKER_INFLUXDB_INIT_PASSWORD=qweqweqwe \
       --env DOCKER_INFLUXDB_INIT_ORG=inspalamos \
       --env DOCKER_INFLUXDB_INIT_BUCKET=smx1 \
       influxdb

docker run \
       --detach \
       --hostname gfna \
       --name gfna \
       --user $(id -u) \
       --network iot.net \
       --ip 172.22.0.14 \
       --publish 3000:3000 \
       --volume $HOME/vol/gfna/data:/var/lib/grafana \
       grafana/grafana
