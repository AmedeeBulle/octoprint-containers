#!/bin/bash
# Check for certificates and start haproxy

BaseDir=/opt/octoprint/data/octoprint

if [ ! -f ${BaseDir}/config.yaml ]
then
  echo "*** Copying initial config file"
  mkdir -p ${BaseDir}
  cp etc/config.yaml ${BaseDir}
fi

echo "*** Starting octoprint"
exec /opt/octoprint/OctoPrint/venv/bin/octoprint --basedir ${BaseDir} serve --iknowwhatimdoing
