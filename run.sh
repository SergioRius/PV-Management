#!/usr/bin/env bash
#
# Linux recipes install script
# Version: MASTER branch
# Author:  Sergio Rius
#

if [[ `whoami` != 'root' ]]; then
  echo "This script requires root privileges."
  echo "Please run this script as root."
  exit 1
fi

echo; echo "Checking Docker installation"
if docker -v >/dev/null 2>&1; then
    echo "Docker is already installed in this system."
else
  echo "Not found. Installing Docker..."

  wget "https://get.docker.com" -O DockerInstall.sh
  chmod +x DockerInstall.sh
  ./DockerInstall.sh
  rm DockerInstall.sh

  # Configuration #############################
  echo "Configuring Docker"

  # Set docker service to 'simple': https://github.com/MichaIng/DietPi/issues/2238#issuecomment-439474766
  mkdir -p /lib/systemd/system/docker.service.d
  echo -e '[Service]\nType=simple' > simple.conf
  mv -f simple.conf /lib/systemd/system/docker.service.d/simple.conf

# Uncomment if you want to setup an external docker data folder
# # Setup Docker data service folder
# if [[ ! -e "/mnt/docker-data" ]]; then
#   if [[ $l_dir_dockerdata != "/mnt/docker-data" ]]; then
#     mkdir -p $l_dir_dockerdata
#     chmod 0775 $l_dir_dockerdata
#     ln -s $l_dir_dockerdata "/mnt/docker-data"
#   else
#     mkdir -p "/mnt/docker-data"
#     chmod 0775 "/mnt/docker-data"
#   fi
# fi

# mkdir -p /etc/docker
# echo -e "{\n    \"data-root\": \"/mnt/docker-data\"\n}" > /etc/docker/daemon.json

  systemctl daemon-reload
  systemctl restart docker.service

  read -p " - Press any key to continue..."
fi

echo; echo "Checking Docker-Compose installation"
if docker-compose -v >/dev/null 2>&1; then
    echo "Docker-Compose already installed in this system."
else
  echo "Not found. Installing Docker-Compose"
  case $(uname -m) in
    x86_64)
      platform="amd64"
      ;;
    aarch64_be | aarch64 |armv8b | armv8l)
      platform="arm64"
      ;;
    arm)
      platform="armhf"
      ;;
    *)
      echo "Platform not supported"
      return
      ;;
  esac

  curl -L "https://github.com/linuxserver/docker-docker-compose/releases/latest/download/docker-compose-$(platform)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose

  echo; read -p " - Press any key to continue..."
fi

echo;
read -p "Do you wish to activate and open the required ports for docker remote management? (y/n) " yn
case $yn in
  [Yy]* )
    echo "Activating docker remote management..."
    [[ ! -d /etc/systemd/system/docker.service.d ]] && mkdir -p /etc/systemd/system/docker.service.d
    cat <<EOT > /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376
EOT

    systemctl daemon-reload
    systemctl restart docker.service

    echo "Opening the requiered ports"
    iptables -I INPUT -p tcp -m tcp --dport 2376 -j ACCEPT -m comment --comment "DOCKER_API_INSECURE"

    #tdnf install iptables-persistent
    apt install --qqy iptables-persistent

    [[ -d /etc/systemd/scripts ]] || mkdir -p /etc/systemd/scripts

    iptables-save >/etc/systemd/scripts/ip4save

    read -p " - Press any key to continue..."
  break;;
  * ) echo "OK!";;
esac

echo; echo "Setting docker persistence folder if not exists"
[ ! -z "$1" ] && persistence="$1" || persistence="/mnt/docker-persistence"
[ ! -d $persistence ] && mkdir -p "$persistence"
chmod 0775 "$persistence"

echo; echo "Getting correct timezone"
[ ! -z "$2" ] && TZ="$2" || TZ=$(timedatectl show --va -p Timezone)

echo;
read -p "Do you wish to install a portainer container for local management? (y/n) " yn
case $yn in
  [Yy]* )
    echo "Installing portainer..."
    docker run --name portainer --restart=unless-stopped \
      -p 9000:9000 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v $persistence/portainer:/data \
      -v /etc/localtime:/etc/localtime:ro \
      -d portainer/portainer
    read -p " - Press any key to continue..."
  ;;
  * )
    echo "OK!"
  ;;
esac

echo; echo "I will now create the container stack."
read -p "Do you want to continue? (y/n) " yn
case $yn in
  [Yy]* )
    echo "Installing management stack..."
    [ ! -d "$persistence/mqtt/config" ] && mkdir -p "$persistence/mqtt/config"
    chown -R 1883:1883 "$persistence/mqtt"
    [ ! -d "$persistence/grafana" ] && mkdir -p "$persistence/grafana"
    chown -R 472:472 "$persistence/grafana"
    [ ! -d "$persistence/nodered" ] && mkdir -p "$persistence/nodered"
    chown -R 1000:1000 "$persistence/nodered"

    if [ ! -f "$persistence/mqtt/config/mosquitto.conf" ]; then
      cp mqtt/mosquitto.conf "$persistence/mqtt/config/mosquitto.conf"
      chown -R 1883:1883 "$persistence/mqtt"
    fi

    # Having so much version compatibilty problems upon creating a new config
    # I opted for just copying a working one.
    echo; echo "Creating influxdb initial config if it doesn't exist"
    [ ! -d "$persistence/influxdb" ] && mkdir -p "$persistence/influxdb"
    if [ ! -f "$persistence/influxdb/influxdb.conf" ]; then
      cp influxdb/influxdb.conf "$persistence/influxdb/influxdb.conf"
    #   docker run --rm \
    #     -e INFLUXDB_REPORTING_DISABLED=true \
    #     influxdb:latest \
    #     influxd config > "$persistence/influxdb/influxdb.conf"
    fi

    echo; echo "Setting up env variables"
    cd pv-management
    cat <<EOF > .env
# Docker stack environment variables
PERSISTENCE_PATH=$persistence
TZ=$TZ
EOF
    docker-compose up -d
  ;;
  * )
    echo "OK!"
  ;;
esac
echo; echo "All jobs done!"
read -p " - Press any key to continue..."
