#!/bin/bash

LAST_MINUTE=100
LAST_VALUE=0

function mqtt_send_ext() {
    # $1 => subtopic
    # $2 => pid
    # $3 => tid
    # $4 => value, format x.y (e.g. 20.1)

    MINUTE=$(date +%M)
    if [ "$MINUTE" == "$LAST_MINUTE" ]; then
        VALUE=$LAST_VALUE
    else
        VALUE=${4}${RANDOM}
        LAST_VALUE=$VALUE
        LAST_MINUTE=$MIN
    fi

    docker exec nred \
        mqtt_pub \
            --hostname 172.22.0.12 \
            --topic "/ret/temp/$1" \
            --message '{"pid": "'${2}'", "tid": "'${3}'", "value": '${VALUE}'}' \
            --username qwe \
            --password qwe
}

while true; do
    mqtt_send int sim_one 24.3
    mqtt_send int sim_two 29.5

    mqtt_send ext sim_one dht22 20.11
    mqtt_send ext sim_one ds180 20.15
    mqtt_send ext sim_one ds181 20.16

    mqtt_send ext sim_two dht22 20.19
    mqtt_send ext sim_two ds182 20.12
done
