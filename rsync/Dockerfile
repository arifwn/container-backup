FROM alpine:3.9

RUN apk add --no-cache rsync openssh-client bash

COPY docker-entrypoint.sh /usr/local/bin/

RUN mkdir /source
WORKDIR /source

ENTRYPOINT ["docker-entrypoint.sh"]
