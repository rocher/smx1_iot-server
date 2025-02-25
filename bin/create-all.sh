#!/bin/bash

BIN=$(realpath $(dirname $0))
ROOT=$(realpath $BIN/..)
VOL=$ROOT/vol
source $BIN/tools

# Clean unsused and ignored files
cd $ROOT
git clean -dfqx
cd -

# Pull all required docker images
say get image NodeRED
docker pull nodered/node-red

say get image Eclipse-Mosquitto
docker pull eclipse-mosquitto

say get image InfluxDB
docker pull influxdb

say get image Grafana
docker pull grafana/grafana

# Create iot.net network
say create network iot.net
docker network create \
       --driver bridge \
       --subnet 172.22.0.0/16 \
       --gateway 172.22.0.1 \
       iot.net

# Run all required docker containers
say run container nred
docker run \
       --detach \
       --hostname nred \
       --name nred \
       --network iot.net \
       --ip 172.22.0.11 \
       --publish 1880:1880 \
       --volume $VOL/nred/data:/data \
       nodered/node-red

say run container mqtt
chmod 0700 $VOL/mqtt/config/pwdfile
docker run \
       --detach \
       --hostname mqtt \
       --name mqtt \
       --user $(id -u) \
       --network iot.net \
       --ip 172.22.0.12 \
       --publish 1883:1883 \
       --volume $VOL/mqtt/config:/mosquitto/config \
       --volume $VOL/mqtt/data:/mosquitto/data \
       --volume $VOL/mqtt/log:/mosquitto/log \
       eclipse-mosquitto

say run container flux
docker run \
       --detach \
       --hostname flux \
       --name flux \
       --network iot.net \
       --ip 172.22.0.13 \
       --publish 8086:8086 \
       --volume $VOL/flux/data:/var/lib/influxdb2 \
       --volume $VOL/flux/config:/etc/influxdb2 \
       --env DOCKER_INFLUXDB_INIT_MODE=setup \
       --env DOCKER_INFLUXDB_INIT_USERNAME=admin \
       --env DOCKER_INFLUXDB_INIT_PASSWORD=admin1234 \
       --env DOCKER_INFLUXDB_INIT_ORG=inspalamos \
       --env DOCKER_INFLUXDB_INIT_BUCKET=smx1 \
       influxdb

say configure container flux
BUCKET=$(docker exec flux influx bucket ls | \
             grep smx1 | \
             sed -e 's/^\([a-z0-9]*\).*/\1/' \
      )
docker exec flux influx v1 auth create \
       --org inspalamos \
       --username asd \
       --password asdasdasd \
       --read-bucket $BUCKET \
       --write-bucket $BUCKET

say run container gfna
docker run \
       --detach \
       --hostname gfna \
       --name gfna \
       --user $(id -u) \
       --network iot.net \
       --ip 172.22.0.14 \
       --publish 3000:3000 \
       --volume $VOL/gfna/data:/var/lib/grafana \
       grafana/grafana

say status
docker ps -a
