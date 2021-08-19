#!/usr/bin/env bash
#
# PV management content install script
# Version: MASTER branch
# Author:  Sergio Rius
#

echo; echo "Installing required node modules..."; echo;
docker exec -t nodered /bin/bash -c "cd /data && npm i node-red-dashboard vue@"2.*" bootstrap-vue@"2.*" node-red-contrib-uibuilder node-red-contrib-influxdb node-red-contrib-buffer-parser node-red-contrib-modbus node-red-contrib-socketio node-red-contrib-watt2kwh"

echo;
read -p "Do you wish to install the victron nodes? (y/n) " yn
case $yn in
  [Yy]* )
    echo;
    docker exec -t nodered /bin/bash -c "cd /data && npm i @victronenergy/node-red-contrib-victron"
  ;;
esac

echo; echo "Importing node-red flows..."; echo;
for f in nodered/autoimport/*.json; do
  echo "$f"
  curl -X POST http://localhost:1880/flow -H 'content-type: application/json' --data "@$f"
done

echo; echo;
docker restart nodered
