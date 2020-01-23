#!/bin/bash
set -e

echo "Waiting for Conductor to startup before provisioning tasks and workflows..."
# sleep 5
c=0
until $(curl --output /dev/null --silent --head --fail http://localhost:8080/api/metadata/taskdefs); do
    echo "."
    sleep 1
    c=$((c + 1))
    if [[ "$c" -gt 120 ]]; then
        echo 'Timeout waiting for Conductor to start (60s). Aborting provisioning.'
        killall java
    fi 
done


echo "Searching for task defs at /provisioning/tasks..."
found=0
if [ -d /provisioning/tasks ]; then 
    for jsonfile in /provisioning/tasks/*.json ; 
    do
        found=1
        echo "================================="
        python /app/provision-task.py $jsonfile
        if [ -f /tmp/error ]; then
            echo "Error provisioning task. Aborting."
            killall java
        fi
    done
fi
if [ "$found" == "0" ];then
    echo "No json files with taskdefs found at /provisioning/tasks"
fi



echo "Searching for workflow defs at /provisioning/workflows..."
found=0
if [ -d /provisioning/workflows ]; then 
    for jsonfile in /provisioning/workflows/*.json ; 
    do
        found=1
        echo "================================="
        python /app/provision-workflow.py $jsonfile
        if [ -f /tmp/error ]; then
            echo "Error provisioning workflow. Aborting."
            killall java
        fi
    done
fi
if [ "$found" == "0" ];then
    echo "No json files with workflow defs found at /provisioning/workflows"
fi

echo "Provisioning finished"
echo "================================="
