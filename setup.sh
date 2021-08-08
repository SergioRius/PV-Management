#!/usr/bin/env bash
#
# PV management content install script
# Version: MASTER branch
# Author:  Sergio Rius
#

echo "Installed required node modules..."
docker exec -it nodered /bin/bash -c "cd /data && npm install node-red-dashboard node-red-contrib-uibuilder node-red-contrib-influxdb node-red-contrib-victron node-red-contrib-buffer-parser node-red-contrib-modbus node-red-contrib-socketio"
docker restart nodered

echo "Importing node-red flows..."
for f in nodered/autoimport/*.json; do
  echo "$f"
  curl -X POST http://localhost:1880/flow -H 'content-type: application/json' --data "@$f"
done
