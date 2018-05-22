# Webcam streamer
FROM resin/raspberrypi3-debian:stretch

RUN apt-get update && \
    apt-get install python-flask git build-essential subversion \
	    libjpeg62-turbo-dev imagemagick ffmpeg libv4l-dev cmake && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/webcam

RUN git clone https://github.com/jacksonliam/mjpg-streamer.git /opt/webcam/mjpg-streamer && \
	cd mjpg-streamer/mjpg-streamer-experimental && \
	LD_LIBRARY_PATH=. make

COPY run.py run.py

EXPOSE 5200 8080

CMD ["/opt/webcam/run.py"]
