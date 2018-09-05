# Octoprint itself
FROM resin/raspberrypi3-debian:stretch

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install python-pip python-dev python-setuptools virtualenv \
	    python-virtualenv git libyaml-dev build-essential ffmpeg dbus \
            jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/octoprint/OctoPrint

ARG release

RUN if [ "${release}" = "latest" ]; then \
      release=$(curl --silent https://api.github.com/repos/foosel/OctoPrint/releases/latest | jq -r .tag_name); \
	fi; \
    git clone --branch "${release}" https://github.com/foosel/OctoPrint.git /opt/octoprint/OctoPrint && \
    virtualenv venv && \
	./venv/bin/python setup.py install 

WORKDIR /opt/octoprint

COPY bin bin/
COPY etc etc/

VOLUME /opt/octoprint/data

EXPOSE 5000

CMD ["/opt/octoprint/bin/run.sh"]
