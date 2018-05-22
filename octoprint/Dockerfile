# Octoprint itself
FROM resin/raspberrypi3-debian:stretch

RUN apt-get update && \
    apt-get install python-pip python-dev python-setuptools virtualenv \
	    python-virtualenv git libyaml-dev build-essential ffmpeg dbus && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/octoprint/OctoPrint

RUN git clone https://github.com/foosel/OctoPrint.git /opt/octoprint/OctoPrint && \
    virtualenv venv && \
	./venv/bin/python setup.py install 

WORKDIR /opt/octoprint

COPY bin bin/
COPY etc etc/

VOLUME /opt/octoprint/data

EXPOSE 5000

CMD ["/opt/octoprint/bin/run.sh"]
