FROM postgres:11

COPY docker-entrypoint.sh /usr/local/bin/

RUN mkdir /dump
WORKDIR /dump

ENTRYPOINT ["docker-entrypoint.sh"]
