# OctoPrint containers  [![Build Status](https://travis-ci.com/AmedeeBulle/octoprint-containers.svg?branch=master)](https://travis-ci.com/AmedeeBulle/octoprint-containers)

# Contents

<!-- TOC START min:1 max:3 link:true update:false -->
- [Introduction](#introduction)
- [Balena.io setup](#balenaio-setup)
  - [Install BalenaOS on your Pi](#install-balenaos-on-your-pi)
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
- [Note about persistence](#note-about-persistence)
- [Multiple printers](#multiple-printers)

<!-- TOC END -->
# Introduction

This is a Docker setup for [OctoPrint](https://octoprint.org/) on Raspberry Pi.  
It can be run with [balena.io](https://balena.io/) or as _Plain Docker_ on Raspbian.

The setup is made of 3 containers:

- `octoprint`: runs the main [OctoPrint](https://octoprint.org/) application
- `webcam`: runs the webcam streaming service (`mjpg-streamer`)
- `haproxy`: exposes the above containers on http and https ports

The build will use by default the latest [OctoPrint](https://octoprint.org/) release, this can be overridden by changing the `release` argument in the `docker-compose.yml` file.

This setup will run on any Raspberry Pi, however [OctoPrint](https://octoprint.org/) recommends a Raspberry Pi 3 or 3+.

# Balena.io setup

Although it may seem complex at first, [balena.io](https://balena.io/) allows you to install and configure [OctoPrint](https://octoprint.org/) on a Pi in a few clicks.  
Also if you have multiple [OctoPrint](https://octoprint.org/) servers, they will be managed from a central place.

For additional help and nice screenshots of the [balena.io](https://balena.io/) interface look at [Get started with Raspberry Pi 3 and Python](https://docs.balena.io/learn/getting-started/raspberrypi3/python/) on the [balena.io](https://balena.io/) site.

## Install BalenaOS on your Pi

1. Create an account at [balena.io](https://balena.io/) and sign in
1. Add your public SSH key to your [balena.io](https://balena.io/) profile
1. On [balena.io](https://balena.io/), create an "Application" for managing your Pi.  
Choose "Raspberry Pi 3" as Device Type.
1. Add a Device to your Application.
   - Configure WiFi here if your Pi is wireless.
   - Download the BalenaOS image for your Pi.
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

The device is now ready, we need to push the containers through [balena.io](https://balena.io/).  
The following commands need to be executed from the terminal on your local machine -- __not__ on the Raspberry Pi!  
(On Windows, use [Git BASH](https://gitforwindows.org/) or something similar).

Clone this repository:

```shell
git clone https://github.com/AmedeeBulle/octoprint-containers.git
cd octoprint-containers/
```

Add the address of your [balena.io](https://balena.io/) repository. This command is displayed in the top-left corner of your application dashboard on the web site and looks like:

```shell
git remote add balena <USERNAME>@git.balena.io:<USERNAME>/<APPNAME>.git
```

Push the code to [balena.io](https://balena.io/):

```shell
git push balena master
```

This will trigger a build on the [balena.io](https://balena.io/) servers. If all goes well it will finish with a nice unicorn &#x1f984; ASCII art.  
Your Raspberry Pi will download and run the containers automatically; after that your [OctoPrint](https://octoprint.org/) server will be ready to go!

For future updates, you simply need to pull the new code and push it back to [balena.io](https://balena.io/) and your device will be updated!

```shell
git pull origin master
git push balena master
```

# Docker setup

If you do not want to use the [balena.io](https://balena.io/) services, you can run the exact same configuration directly on your Raspberry Pi.

## Prepare the Raspberry Pi

Download and install [Raspbian Buster Lite](https://www.raspberrypi.org/downloads/raspbian/) to your Pi (Follow the instructions from the Foundation).  
Although it will work with the full _Desktop_ environment, I strongly recommend the _Lite_ version.

As root, install `git`, `docker` and `docker-compose`:

```shell
apt-get update
apt-get install git curl python-pip
curl -sSL https://get.docker.com | sh
pip install docker-compose
```

Ensure your linux user (`pi` or whatever you choose) is in the `docker` group:

```shell
usermod -a -G docker <YourLinuxUser>
```

At this point you need to completely logout and re-login to activate the new group.

From here, __you don't need root access anymore__.

Clone this repository:

```shell
git clone https://github.com/AmedeeBulle/octoprint-containers.git
cd octoprint-containers/
```

## Get the containers

You have 2 options here: download the pre-build containers or re-build them.

### Option 1: Download the containers

This is the easiest and fastest way. The `pull` command will download the containers from the Docker Hub:

```shell
docker-compose pull
```

__If you are not using a Raspberry Pi 3__: _multiarch_ build does not work properly on ARM variants (See Moby issue [34875](https://github.com/moby/moby/issues/34875)).  
For older Raspberry Pi you need to amend the _docker-compose_ files to pull the correct images:

```shell
sed -e 's/\(image:.*\)/\1:arm32v6-latest/' -i.orig docker-compose.yml
```

### Option 2: Re-Build the containers

If for whatever reason you want to re-build the containers on your Pi, run:

```shell
docker-compose build
```

__If you are not using a Raspberry Pi 3__: copy the `.env-distr` to `.env` and select you Raspberry Pi version.

## Configure and run the OctoPrint server

To customize your setup, create a file named `.env` with the environment variables described in the [balena.io](https://balena.io/) section. You can use the file `.env-distr` as template.

__Important__: in `docker-compose.yml` uncomment the following line:

```yaml
      - /run/dbus:/host/run/dbus
```

If you don't do that, you won't be able to restart or shut down you Pi from the [OctoPrint](https://octoprint.org/) user interface.

Run the [OctoPrint](https://octoprint.org/) server:

```shell
docker-compose up
```

This will start the containers and remain attached to your terminal. If everything looks good, you can cancel it and restart the service in detached mode:

```shell
docker-compose up -d
```

This will keep he containers running, even after a reboot.

## Updates

To update your setup with a newer version, get the latest code and containers and restart the service:

```shell
docker-compose down
git pull origin master
docker-compose pull # or build
docker-compose up -d
```

# First run

For a _Plain Docker_ setup, you know the IP address of your Pi; if you run [balena.io](https://balena.io/), you will find the address in the application console.

Point your browser to the IP address of your Raspberry Pi and enjoy [OctoPrint](https://octoprint.org/)!

At first run, the `haproxy` container will generate a self-signed SSL certificate, so the service will be available on both http and https ports. If you want to share your printer with the world, only expose the https port...

Enjoy!

# Note about persistence

All working files (configuration, G-Code, time-lapses, ...) are stored in the `octoprint_vol` Docker volume, so they won't disappear unless you explicitly destroy the volume.  
If you really need/want to destroy the volume and re-start from scratch:

- [balena.io](https://balena.io/): select 'Purge Data' in the Device Menu
- _Plain Docker_: run

```shell
docker-compose down -v
```

The same applies to the containers themselves: they won't be destroyed by default even if you reboot the Pi. To remove existing container and re-create them:

- [balena.io](https://balena.io/): click on the 'Restart' icon in the Device Dashboard
- _Plain Docker_: run

```shell
docker-compose down
docker-compose up -d
```

By doing this, you will loose any change made to the code, in particular if you installed plugins you will have to re-install them (but their configuration will be preserved).

# Multiple printers

Although driving multiple printers from the same Raspberry Pi is possible, it might lead to performance issues. 
This setup is nevertheless easy to achieve with the _plain Docker_ setup.  
It is a good solution if:

- You have a powerful Raspberry Pi
- You have multiple printers but use only one at a time

You can run any number of instances of this _container stack_ by using a different _project name_ and a different `.env` file.  
The `docker-compose-multi.sh` convenience script is provided to simplify operations.

Assuming you already have a running instance, to add a new one simply copy the `.env-extra-distr` sample file to `.env-<printer name>`,
review the configuration parameters and start the instance with `./docker-compose-multi.sh <printer name> up -d`.

Main points of attention:

- Do not configure more than one Raspberry Pi camera!  
  (There is no limitation on the number of USB cameras)
- Ensure all instances have their own unique HTTP and HTTPS ports.

Sample session:

```shell
# Start the main instance
$ docker-compose up -d
Creating network "octoprint_default" with the default driver
Creating octoprint_octoprint_1 ... done
Creating octoprint_webcam_1    ... done
Creating octoprint_haproxy_1   ... done
$ docker-compose ps
        Name                       Command               State                    Ports
---------------------------------------------------------------------------------------------------------
octoprint_haproxy_1     /usr/bin/entry.sh /opt/hap ...   Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp
octoprint_octoprint_1   /usr/bin/entry.sh /opt/oct ...   Up      5000/tcp
octoprint_webcam_1      /usr/bin/entry.sh /opt/web ...   Up      5200/tcp, 8080/tcp

# Start an additional instance for the "extra" printer:
$ cp .env-extra-distr .env-extra
$ vi .env-extra
$ ./docker-compose-multi.sh extra up -d
Creating network "extra_default" with the default driver
Creating volume "extra_octoprint_vol" with default driver
Creating extra_webcam_1    ... done
Creating extra_octoprint_1 ... done
Creating extra_haproxy_1   ... done
$ ./docker-compose-multi.sh extra ps
      Name                     Command               State                      Ports
--------------------------------------------------------------------------------------------------------
extra_haproxy_1     /usr/bin/entry.sh /opt/hap ...   Up      0.0.0.0:8443->443/tcp, 0.0.0.0:8080->80/tcp
extra_octoprint_1   /usr/bin/entry.sh /opt/oct ...   Up      5000/tcp
extra_webcam_1      /usr/bin/entry.sh /opt/web ...   Up      5200/tcp, 8080/tcp
```

Notes:

- As you can see in the above output, instances use a different network namespace as well as a different volume for storing data,
  so they are completely separated and independent.
- Depending on when your printers / cameras are detected they might get different device names on your Raspberry Pi...
  Always check that you are driving the right printer!
