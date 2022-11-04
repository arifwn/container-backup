FROM postgres:15

COPY docker-entrypoint.sh /usr/local/bin/

RUN mkdir /dump
WORKDIR /dump

ENTRYPOINT ["docker-entrypoint.sh"]
