FROM alpine:3.16

RUN apk add --no-cache mysql-client bash

COPY docker-entrypoint.sh /usr/local/bin/

RUN mkdir /dump
WORKDIR /dump

ENTRYPOINT ["docker-entrypoint.sh"]
