FROM postgres:12

COPY docker-entrypoint.sh /usr/local/bin/

RUN mkdir /dump
WORKDIR /dump

ENTRYPOINT ["docker-entrypoint.sh"]
