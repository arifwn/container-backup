FROM python:3.11
ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install -y --no-install-recommends \
        tar zip bash \
    && rm -rf /var/lib/apt/lists/*

ENV VERSION=1.4.2 \
    AUTHORIZATION_FAIL_MAX_RETRIES=3


RUN pip install b2==${VERSION}

RUN mkdir /source
WORKDIR /source

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "docker-entrypoint.sh" ]