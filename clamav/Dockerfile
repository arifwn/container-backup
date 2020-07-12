FROM mkodockx/docker-clamav:alpine-edge

RUN apk add --no-cache curl

COPY clamd.conf /etc/clamav/clamd.conf
COPY freshclam.conf /etc/clamav/freshclam.conf
COPY awhitelist.ign2 /store/awhitelist.ign2
COPY scan.sh /usr/bin/scan.sh
