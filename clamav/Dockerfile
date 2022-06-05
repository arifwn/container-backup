FROM alpine:20220316

RUN apk add --no-cache bash clamav clamav-libunrar curl

COPY conf /etc/clamav
COPY bootstrap.sh /
COPY envconfig.sh /
COPY check.sh /
COPY conf/awhitelist.ign2 /var/lib/clamav/awhitelist.ign2
COPY scan.sh /usr/bin/scan.sh

RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav && \
    chown -R clamav:clamav bootstrap.sh check.sh /etc/clamav && \
    chmod u+x bootstrap.sh check.sh 

EXPOSE 3310/tcp

USER clamav

CMD ["/bootstrap.sh"]
