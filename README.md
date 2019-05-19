# conductor-server
Netflix's Conductor Server Docker container

## Usage

* Create docker-compose.yml

```yml
version: '2.3'

services:

  conductor-ui:
    image: flaviostutz/conductor-ui
    environment:
      - WF_SERVER=http://conductor-server:8080/api/
    ports:
      - 5000:5000
    links:
      - conductor-server

  conductor-server:
    image: flaviostutz/conductor-server
    environment:
      - CONFIG_PROP=config.properties
    ports:
      - 8080:8080
    links:
      - elasticsearch:es
      - dynomite:dyno1
    depends_on:
      elasticsearch:
        condition: service_healthy
      dynomite:
        condition: service_healthy

  dynomite:
    image: flaviostutz/dynomite:0.7.0
    ports:
      - 8102:8102
    healthcheck:
      test: timeout 5 bash -c 'cat < /dev/null > /dev/tcp/localhost/8102'
      interval: 5s
      timeout: 5s
      retries: 12

  elasticsearch:
    image: elasticsearch:5.6.16-alpine
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
```

* Run "docker-compose up"

* Open browser at http://localhost:5000 for UI and http://localhost:8080/api for server API
