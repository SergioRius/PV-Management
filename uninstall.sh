#!/usr/bin/env bash
#
# PV management uninstall script
# Version: MASTER branch
# Author:  Sergio Rius
#

if [[ `whoami` != 'root' ]]; then
  echo "This script requires root privileges."
  echo "Please run this script as root."
  exit 1
fi

echo; echo "This will remove the PV management stack."
read -p "Do you want to continue? (y/n) " yn
case $yn in
  [Yy]* )
    echo "Uninstalling management stack..."
    cd pv-management
    docker-compose down
    cd ..
  ;;
  * )
    echo "Stack removed!"
  ;;
esac

echo; echo "Do you want to also remove the persistence location?"
read -p "WARNING! This will wipe all your data (y/n) " yn
case $yn in
  [Yy]* )
    rm -r /mnt/docker-persistence/venus
    rm -r /mnt/docker-persistence/influxdb
    rm -r /mnt/docker-persistence/telegraf
    rm -r /mnt/docker-persistence/grafana
    rm -r /mnt/docker-persistence/mqtt
    rm -r /mnt/docker-persistence/nodered
    rm -r /mnt/docker-persistence/homeassistant
    rm -r /mnt/docker-persistence/shared
  ;;
  * )
    echo "Persistence removed!"
  ;;
esac

echo; echo "All done."
