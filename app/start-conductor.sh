#!/bin/sh
echo "Starting Conductor server..."

cd /app/libs

java -cp conductor-server-all.jar:prometheus-metrics.jar com.netflix.conductor.bootstrap.Main /app/config.properties
