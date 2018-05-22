# haproxy http/https proxy
FROM resin/raspberrypi3-debian:stretch

RUN apt-get update && \
    apt-get install haproxy ssl-cert && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/haproxy

COPY haproxy.cfg run.sh ./

VOLUME /opt/haproxy/data

EXPOSE 80 443

CMD ["/opt/haproxy/run.sh"]
