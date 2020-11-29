#!/usr/bin/env python3
# Simple REST wrapper to start / stop streaming

import os
from subprocess import Popen
import sys

from flask import Flask

base_dir = "/opt/webcam/mjpg-streamer/mjpg-streamer-experimental"
mjpg_input = "input_raspicam.so -fps 5"
mjpg_output = "output_http.so -w " + base_dir + "/www"
app = Flask(__name__)
stream = None


def stream_start():
    global stream
    if stream:
        return "Streaming already running"
    else:
        stream = Popen([
            os.path.join(base_dir, 'mjpg_streamer'),
            '-i', mjpg_input,
            '-o', mjpg_output
        ], stdout=sys.stdout, stderr=sys.stderr)
        return "Streaming started"


def stream_stop():
    global stream
    if stream:
        stream.terminate()
        stream.wait()
        stream = None
        return "Streaming stopped"
    else:
        return "Streaming not running"


@app.route("/on")
def stream_on():
    return stream_start()


@app.route("/off")
def stream_off():
    return stream_stop()


def initialize():
    global mjpg_input
    print("*** Starting WebcamStream")
    sys.stdout.flush()
    if os.getenv('BALENA'):
        # Expunge unexpanded variables from docker-compose
        for key, val in os.environ.items():
            if key.startswith('WEBCAM_') and val.startswith('${'):
                os.environ.pop(key)

    # Set Library path for mjpg_streamer
    if os.getenv('LD_LIBRARY_PATH'):
        os.environ['LD_LIBRARY_PATH'] += ':' + base_dir
    else:
        os.environ['LD_LIBRARY_PATH'] = base_dir

    if os.getenv('WEBCAM_INPUT'):
        mjpg_input = os.getenv('WEBCAM_INPUT')

    if os.getenv('WEBCAM_START', 'true') == 'true':
        stream_start()


if __name__ == '__main__':
    initialize()
    app.run(debug=False, host="0.0.0.0", port=5200)
