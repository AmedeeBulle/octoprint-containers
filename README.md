OctoPrint containers
====================

# Contents
<!-- TOC START min:1 max:3 link:true update:false -->
- [Introduction](#introduction)
- [Resin.io setup](#resinio-setup)
  - [Install ResinOS on your Pi](#install-resinos-on-your-pi)
  - [Configure your OctoPrint device](#configure-your-octoprint-device)
  - [Install the software on the Device](#install-the-software-on-the-device)
- [Docker setup](#docker-setup)
  - [Prepare the Raspberry Pi](#prepare-the-raspberry-pi)
  - [Get the containers](#get-the-containers)
    - [Option 1: Download the containers](#option-1-download-the-containers)
    - [Option 2: Re-Build the containers](#option-2-re-build-the-containers)
  - [Configure and run the OctoPrint server](#configure-and-run-the-octoprint-server)
  - [Updates](#updates)
- [First run](#first-run)

<!-- TOC END -->
# Introduction
This is a Docker setup for [OctoPrint](https://octoprint.org/) on Raspberry Pi 3B/3B+.  
It can be run with [resin.io](https://resin.io/) or as _Plain Docker_ on Raspbian.

The setup is made of 3 containers:
- `octoprint`: runs the main [OctoPrint](https://octoprint.org/) application
- `webcam`: runs the webcam streaming service (`mjpg-streamer`)
- `haproxy`: exposes the above containers on http and https ports

Note that this setup only runs on Raspberry Pi 3B(+), as [resin.io](https://resin.io/) only supports multi-containers on these platforms.  
The _Plain Docker_ setup on Raspbian might work on older models, but it has not been tested.

# Resin.io setup
Although it may seem complex at first, [resin.io](https://resin.io/) allows you to install and configure [OctoPrint](https://octoprint.org/) on a Pi in a few clicks.  
Also if you have multiple [OctoPrint](https://octoprint.org/) servers, they will be managed from a central place.

For additional help and nice screenshots of the [resin.io](https://resin.io/) interface look at [Get started with Raspberry Pi 3 and Python](https://docs.resin.io/learn/getting-started/raspberrypi3/python/) on the [resin.io](https://resin.io/) site.

## Install ResinOS on your Pi
1. Create an account at [resin.io](https://resin.io/) and sign in
1. Add your public SSH key to your [resin.io](https://resin.io/) profile
1. On [resin.io](https://resin.io/), create an "Application" for managing your Pi.  
Choose "Raspberry Pi 3" as Device Type.
1. Add a Device to your Application.
  - Configure wifi here if your Pi is wireless.
  - Download the ResinOS image for your Pi.
1. Follow the instructions to write the OS on your SD-Card and boot your Pi.  
After a while your Pi will appear in your Application Dashboard.
1. If you like you can change the name of your device.

## Configure your OctoPrint device
The Environment Variables menu "E(x)" allows you to add variables to configure the device for your usage.

You can add the following variables:

Name         | Default                    | Description
-------------|----------------------------|------------
WEBCAM_START | `true`                     | Start the webcam streaming at boot time.<br>Use false if you have no webcam or want to start it from the [OctoPrint](https://octoprint.org/) menu
WEBCAM_INPUT | `input_raspicam.so -fps 5` | The input plugin for [`mjpg-streamer`](https://github.com/jacksonliam/mjpg-streamer).<br>Default is for the Raspberry Pi camera, see the documentation for others.<br>Example for an USB webcam: `input_uvc.so -d /dev/video0 -r 640x480 -fps 5`.

## Install the software on the Device
The device is now ready, we need to push the containers through [resin.io](https://resin.io/).  
The following commands need to be executed from the terminal on your local machine -- __not__ on the Raspberry Pi!  
(On Windows, use [Git BASH](https://gitforwindows.org/) or something similar).

Clone this repository:
```
$ git clone https://github.com/AmedeeBulle/octoprint-containers.git
$ cd octoprint-containers/
```
Add the address of your [resin.io](https://resin.io/) repository. This command is displayed in the top-left corner of your application dashboard on the web site and looks like:
```
$ git remote add resin <USERNAME>@git.resin.io:<USERNAME>/<APPNAME>.git
```
Push the code to [resin.io](https://resin.io/):
```
$ git push resin master
```
This will trigger a build on the [resin.io](https://resin.io/) servers. If all goes well it will finish with a nice unicorn &#x1f984 ASCII art.  
Your Raspberry Pi will download and run the containers automatically; after that your [OctoPrint](https://octoprint.org/) server will be ready to go!

For future updates, you simply need to pull the new code and push it back to [resin.io](https://resin.io/) and your device will be updated!
```
$ git pull origin master
$ git push resin master
```

# Docker setup
If you do not want to use the [resin.io](https://resin.io/) services, you can run the exact same configuration directly on your Raspberry Pi.

## Prepare the Raspberry Pi
Download and install [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/) to your Pi (Follow the instructions from the Foundation).  
Although it will work with the full _Desktop_ environment, I strongly recommend the _Lite_ version.

As root, install `git`, `docker` and `docker-compose`:
```
# apt-get update
# apt-get install git curl python-pip
# curl -sSL https://get.docker.com | sh
# pip install docker-compose
```
Ensure your linux user (`pi` or whatever you choose) is in the `docker` group:
```
# usermod -a -G docker <YourLinuxUser>
```
At this point you need to completely logout and re-login to activate the new group.

From here, __you don't need root access anymore__.

Clone this repository:
```
$ git clone https://github.com/AmedeeBulle/octoprint-containers.git
$ cd octoprint-containers/
```

## Get the containers
You have 2 options here: download the pre-build containers or re-build them.

### Option 1: Download the containers
This is the easiest and fastest way. The `pull` command will download the containers from the Docker Hub:
```
$ docker-compose pull
```

### Option 2: Re-Build the containers
If for whatever reason you want to re-build the containers on your Pi, run:
```
$ docker-compose build
```

## Configure and run the OctoPrint server
To customise your setup, create a file named `.env` with the environment variables described in the [resin.io](https://resin.io/) section. You can use the file `.env-distr` as template.

__Important__: in `docker-compose.yml` uncomment the following line:
```
      - /run/dbus:/host/run/dbus
```
If you don't do that, you won't be able to restart or shut down you Pi from the [OctoPrint](https://octoprint.org/) user interface.

Run the [OctoPrint](https://octoprint.org/) server:
```
$ docker-compose up
```
This will start the containers and remain attached to your terminal. If everything looks good, you can cancel it and restart the service in detached mode:
```
$ docker-compose up -d
```
This will keep he containers running, even after a reboot.

## Updates
To update your setup with a newer version, get the latest code and containers and restart the service:
```
$ docker-compose down
$ git pull origin master
$ docker-compose pull # or build
$ docker-compose up
```

# First run
For a _Plain Docker_ setup, you know the IP address of your Pi; if you run [resin.io](https://resin.io/), you will find the address in the application console.

Point your browser to the IP address of your Raspberry Pi and enjoy [OctoPrint](https://octoprint.org/)!

At first run, the `haproxy` container will generate a self-signed SSL certificate, so the service will be available on both http and https ports. If you want to share your printer with the world, only expose the https port...

Enjoy!
