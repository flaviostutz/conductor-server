FROM openjdk:8-jdk AS builder

ARG CONDUCTOR_VERSION=v2.12.1
ARG LOG_LEVEL='INFO'

WORKDIR /
RUN git clone https://github.com/Netflix/conductor.git
WORKDIR /conductor
RUN git checkout tags/$CONDUCTOR_VERSION
RUN sed -i 's/DEBUG/INFO/g' server/src/main/resources/log4j.properties

RUN ./gradlew build -x test



FROM openjdk:8-jre-alpine

RUN apk add --update python py-pip bash curl gettext
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

EXPOSE 8080
EXPOSE 8090

ENTRYPOINT [ "/bin/bash"]
CMD [ "/app/startup.sh" ]

