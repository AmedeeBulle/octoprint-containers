#!/bin/bash
# Restart OctoPrint
# We just kill OctoPrint, container will restart

echo "*** Restarting OctoPrint"
pkill octoprint
