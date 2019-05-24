# conductor-server
Netflix's Conductor Server Docker container

## Usage

* Create docker-compose.yml

```yml
version: '2.3'

services:

  conductor-server:
    image: flaviostutz/conductor-server
    environment:
      - DYNOMITE_HOSTS=dynomite:8102:us-east-1c
      - ELASTICSEARCH_URL=elasticsearch:9300
      - LOADSAMPLE=true
    ports:
      - 8080:8080
    depends_on:
      elasticsearch:
        condition: service_healthy
      dynomite:
        condition: service_healthy
    logging:
      driver: "json-file"
      options:
        max-size: "1k"
        max-file: "3"

  conductor-ui:
    image: flaviostutz/conductor-ui
    environment:
      - WF_SERVER=http://conductor-server:8080/api/
    ports:
      - 5000:5000
    links:
      - conductor-server

  dynomite:
    image: flaviostutz/dynomite
    ports:
      - 8102:8102
    healthcheck:
      test: timeout 5 bash -c 'cat < /dev/null > /dev/tcp/localhost/8102'
      interval: 5s
      timeout: 5s
      retries: 12
    logging:
      driver: "json-file"
      options:
        max-size: "1k"
        max-file: "3"

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:5.6.8
    environment:
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - transport.host=0.0.0.0
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - 9200:9200
      - 9300:9300
    healthcheck:
      test: timeout 5 bash -c 'cat < /dev/null > /dev/tcp/localhost/9300'
      interval: 5s
      timeout: 5s
      retries: 12
    logging:
      driver: "json-file"
      options:
        max-size: "1k"
        max-file: "3"
```

* Run "docker-compose up"

* Open browser at http://localhost:5000 for UI and http://localhost:8080/api for server API

## Provisioning Tasks and Workflows

This container has a special feature for deploying task definitions and workflows along with containers, so that those json files can be placed in a git repository and you can create versioned container images with those workflows inside (very similar to the Grafana's provisioning capabilities).

For using this feature:
  * Create a new Dockerfile using 'FROM flaviostutz/conductor-server'
  * Add files to the container at /provisioning/workflows and /provisioning/tasks
    * The json format is the same as in documentation
    * Pay attention to the fact that json files at /tasks must be an array of tasks
  * See an example at [/example](/example)

When the container starts:
  * It will scan for all json files inside /provisioning/tasks
  * Check if each task definition is already present in the running Conductor (using the API)
  * Create any missing task definitions (using the API)
  * Scan for all json files inside /provisioning/workflows
  * Check if each workflow (along with its version) is present in Conductor
  * Deploy any missing workflows (using the API)
  * When restarting a container, it will probably verify that all items were already deployed to Conductor and skip them
  * If any provisioning steps fail, the container will exit.

## ENV Properties

* DYNOMITE_HOSTS Dynomite hosts connection string in format 'domain:port:region'. Use 'us-east-1c' in 'region' if you don't know what to place there. 

* DYNOMITE_CLUSTER Dynomite cluster name. defaults to 'dyno1'

* ELASTICSEARCH_URL Elastic search 'host:port' for acessing ES cluster. Doesn't support multiple servers here

* LOADSAMPLE 'true' for provisioning Conductor demo app and instantiate a workflow. defaults to false
