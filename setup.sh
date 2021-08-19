#!/usr/bin/env bash
#
# PV management content install script
# Version: MASTER branch
# Author:  Sergio Rius
#

echo "Installing required node modules..."
docker exec nodered /bin/bash -c "cd /data && npm i node-red-dashboard node-red-contrib-uibuilder node-red-contrib-influxdb node-red-contrib-buffer-parser node-red-contrib-modbus node-red-contrib-socketio node-red-contrib-watt2kwh"

echo;
read -p "Do you wish to install the victron nodes? (y/n) " yn
case $yn in
  [Yy]* )
    docker exec nodered /bin/bash -c "cd /data && npm i @victronenergy/node-red-contrib-victron"
  ;;
esac

echo "Importing node-red flows..."
for f in nodered/autoimport/*.json; do
  echo "$f"
  curl -X POST http://localhost:1880/flow -H 'content-type: application/json' --data "@$f"
done

docker restart nodered
