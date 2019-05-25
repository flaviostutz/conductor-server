#!/bin/bash
set -e

echo "Preparing config file"
if [ "$DYNOMITE_HOSTS" == "" ]; then
    echo "DYNOMITE_HOSTS environment variable is required"
    exit 1
fi
if [ "$ELASTICSEARCH_URL" == "" ]; then
    echo "ELASTICSEARCH_URL environment variable is required"
    exit 1
fi

envsubst < /app/config.properties.tmpl > /app/config.properties

echo "========"
cat /app/config.properties
echo "========"

echo "==== Starting Conductor ===="

echo "Waiting Dynomite to be available..."
IFS=':' read -r -a DH <<< "$DYNOMITE_HOSTS"
DYNO_HOST_PORT="${DH[0]} ${DH[1]}"
timeout -t 60 bash -c "until nc -z -w 1 $DYNO_HOST_PORT; do sleep 1; done"
RESULT=$?
if [ "$RESULT" -ne 0 ]; then
    echo "Timeout waiting Dynomite connection. Exiting."
    exit 1
fi
sleep 5

/app/provisioning.sh &

/app/start-conductor.sh
