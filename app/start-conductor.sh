#!/bin/sh
echo "Starting Conductor server..."

cd /app/libs

java -jar conductor-server-*-all.jar /app/config.properties
