#BUILD METRICS PLUGIN
FROM flaviostutz/maven-prewarmed:3.5-jdk-8 AS METRICS
WORKDIR /
RUN git clone https://github.com/mohelsaka/conductor-prometheus-metrics.git
WORKDIR /conductor-prometheus-metrics
RUN mvn package
RUN mv /conductor-prometheus-metrics/target/prometheus-metrics-1.0-SNAPSHOT-all.jar /prometheus-metrics.jar



#BUILD CONDUCTOR
FROM flaviostutz/gradle-warmed:jdk8-gradle4-1.0 AS CONDUCTOR

ARG CONDUCTOR_VERSION=v2.24.2
ARG LOG_LEVEL='INFO'

WORKDIR /
RUN git clone https://github.com/netflix/conductor.git
WORKDIR /conductor
RUN git checkout tags/$CONDUCTOR_VERSION
RUN sed -i 's/DEBUG/INFO/g' server/src/main/resources/log4j.properties

#remove Swagger to avoid conflicts with other modules on http '/'
#see https://github.com/Netflix/conductor/issues/600#issuecomment-462403419
WORKDIR /
RUN rm /conductor/server/src/main/java/com/netflix/conductor/server/SwaggerModule.java
ADD /remove-swagger.sh /
RUN /remove-swagger.sh

WORKDIR /conductor
RUN gradle build -x test --no-daemon --build-cache

RUN cp /conductor/server/build/libs/conductor-server-*-all.jar /conductor-server-all.jar



#ASSEMBLY RUNNABLE CONTAINER
FROM openjdk:8-jre-alpine

RUN apk add --update python py-pip bash curl gettext netcat-openbsd
RUN pip install requests fmt

RUN mkdir -p /app/config /app/logs /app/libs

COPY --from=CONDUCTOR /conductor/docker/server/bin /app
COPY --from=CONDUCTOR /conductor-server-all.jar /app/libs
COPY --from=METRICS /prometheus-metrics.jar /app/libs

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

