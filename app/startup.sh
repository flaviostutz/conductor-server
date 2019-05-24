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

/app/provisioning.sh &

/app/start-conductor.sh
