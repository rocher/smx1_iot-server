#!/bin/bash

LAST_MINUTE=100
LAST_VALUE=0

function mqtt_send_ext() {
    # $1 => subtopic: int or ext
    # $2 => pid
    # $3 => value, format x.y (e.g. 20.1)
    # $4 => tid, only for ext

    MINUTE=$(date +%M)
    if [ "$MINUTE" == "$LAST_MINUTE" ]; then
        VALUE=$LAST_VALUE
    else
        VALUE=${3}${RANDOM}
        LAST_VALUE=$VALUE
        LAST_MINUTE=$MIN
    fi

    MESSAGE=""
    if [ "$1" == "int" ]; then
        MESSAGE='{"pid": "'${2}'", "value": '${VALUE}'}'
    else
        MESSAGE='{"pid": "'${2}'", "tid": "'${4}'", "value": '${VALUE}'}'
    fi

    docker exec nred \
        mqtt_pub \
            --hostname mqtt.iot.net \
            --topic "/ret/temp/$1" \
            --message "${MESSAGE}" \
            --username qwe \
            --password qwe
}

while true; do
    mqtt_send int sim_one 24.3
    mqtt_send int sim_two 29.5

    mqtt_send ext sim_one 20.11 dht22
    mqtt_send ext sim_one 20.15 ds180
    mqtt_send ext sim_one 20.16 ds181

    mqtt_send ext sim_two 20.19 dht22
    mqtt_send ext sim_two 20.12 ds182
done
