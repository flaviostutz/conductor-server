FROM openjdk:8-jdk AS builder

ARG CONDUCTOR_VERSION=v2.12.1

WORKDIR /
RUN git clone https://github.com/Netflix/conductor.git
WORKDIR /conductor
RUN git checkout tags/$CONDUCTOR_VERSION

RUN ./gradlew build -x test



FROM openjdk:8-jre-alpine

RUN mkdir -p /app/config /app/logs /app/libs

COPY --from=builder /conductor/docker/server/bin /app
COPY --from=builder /conductor/docker/server/config /app/config
COPY --from=builder /conductor/server/build/libs/conductor-server-*-all.jar /app/libs

RUN chmod +x /app/startup.sh

EXPOSE 8080
EXPOSE 8090

CMD [ "/app/startup.sh" ]
ENTRYPOINT [ "/bin/sh"]
