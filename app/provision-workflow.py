import os
import requests
import fmt
import sys
import json
import subprocess

wfjson = sys.argv[1]
print("Processing workflow file " + wfjson + "...")
subprocess.call("rm -f /tmp/error", shell=True)

with open(wfjson) as json_file:
    data = json.load(json_file)
    name = data['name']
    version = data['version']
    print("Processing provisioning workflow " + name + "; version=" + str(version) + "...")

    #verify if this workflow already exists
    r = requests.get('http://localhost:8080/api/metadata/workflow/' + name + '?version=' + str(version))
    if r.status_code==200:
        print('[INFO] Workflow already provisioned. Skipping. name=' + name + '; version=' + str(version))

    elif r.status_code == 404:
        print('====================================================================')
        print('[INFO] Provisioning workflow. name=' + name + '; version=' + str(version))
        print(data)
        print('====================================================================')
        r = requests.post(url='http://localhost:8080/api/metadata/workflow', data=json.dumps(data), headers={'Content-Type': 'application/json'})
        if r.status_code == 204:
            print('[INFO] Workflow provisioned successfully. name=' + name + '; version=' + str(version))

        else:
            print('')
            print('[ERROR] Error provisioning workflow. name=' + name + '; version=' + str(version) + '; status=' + str(r.status_code) + '; body=' + r.content)
            print('')
            subprocess.call("touch /tmp/error", shell=True)

    else:
        print('[ERROR] Error getting workflow. status=' + str(r.status_code) + '; name=' + name + '; version=' + str(version))
        subprocess.call("touch /tmp/error", shell=True)


