FROM flaviostutz/gradle-warmed:jdk8-2.1 AS builder
# jdk8-1.0
# FROM maven:3.6.1-jdk-8 AS builder

ARG CONDUCTOR_VERSION=v2.24.2
ARG LOG_LEVEL='INFO'

#conductor build
WORKDIR /
RUN git clone https://github.com/Netflix/conductor.git
WORKDIR /conductor
RUN git checkout tags/$CONDUCTOR_VERSION
RUN sed -i 's/DEBUG/INFO/g' server/src/main/resources/log4j.properties

#prometheus metrics plugin
WORKDIR /
RUN git clone https://github.com/mohelsaka/conductor-prometheus-metrics.git
WORKDIR /conductor-prometheus-metrics
RUN cp -r src/main/java/com/conductor_integration /conductor/server/src/main/java/com/
RUN rm /conductor/server/src/main/java/com/netflix/conductor/server/SwaggerModule.java
ADD /add-dependencies.sh /
RUN /add-dependencies.sh
RUN echo "/conductor/server/build.gradle" && cat /conductor/server/build.gradle

#build
WORKDIR /conductor
RUN gradle build -x test --no-daemon --build-cache


FROM openjdk:8-jre-alpine

RUN apk add --update python py-pip bash curl gettext netcat-openbsd
RUN pip install requests fmt

RUN mkdir -p /app/config /app/logs /app/libs

COPY --from=builder /conductor/docker/server/bin /app
# COPY --from=builder /conductor/docker/server/config /app/config
COPY --from=builder /conductor/server/build/libs/conductor-server-*-all.jar /app/libs

# RUN chmod +x /app/startup.sh

ADD /app/* /app/

# ADD /example/provisioning /provisioning

ENV DYNOMITE_HOSTS ''
ENV DYNOMITE_CLUSTER 'dyno1'
ENV ELASTICSEARCH_URL ''
ENV LOADSAMPLE 'false'
ENV PROVISIONING_UPDATE_EXISTING_TASKS 'true'

EXPOSE 8080
EXPOSE 8090

ENTRYPOINT [ "/bin/bash"]
CMD [ "/app/startup.sh" ]

