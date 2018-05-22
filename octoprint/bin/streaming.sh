#!/bin/bash
# Start / Stop the stream

Command="$1"
Url="http://webcam:5200"

case "${Command}" in
  start)
    curl "${Url}/on"
    ;;
  stop)
    curl "${Url}/off"
    ;;
  *)
    echo "$0: Invalid action"
	exit 1
    ;;
esac

echo ""
exit 0
