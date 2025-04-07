#!/bin/bash

LAST_MINUTE=100
LAST_VALUE=0

function randomize_value() {
    # $1 => value

    MINUTE=$(date +%M)
    if [ "$MINUTE" == "$LAST_MINUTE" ]; then
        VALUE=$LAST_VALUE
    else
        VALUE=${3}${RANDOM}
        LAST_VALUE=$VALUE
        LAST_MINUTE=$MIN
    fi
}

function mqtt_send() {
    # $1 => subtopic: int or ext
    # $2 => pid
    # $3 => value, format x.y (e.g. 20.1)
    # $4 => tid, only for ext

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

START=$(date +%s)
while true; do
    INC=$(echo "7/1+l($(date +%s) - $START + 2)" | bc -l)
    mqtt_send int sim_one $(echo "24.7 - $INC" | bc -l)
    mqtt_send int sim_two $(echo "29.5 - $INC" | bc -l)

    mqtt_send ext sim_one $(randomize_value 20.11) dht22
    mqtt_send ext sim_one $(randomize_value 20.15) ds180
    mqtt_send ext sim_one $(randomize_value 20.16) ds181

    mqtt_send ext sim_two $(randomize_value 20.26) dht22
    mqtt_send ext sim_two $(randomize_value 20.07) ds182
done
