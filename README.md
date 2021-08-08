# PV-Management
## _Solar management system_

This repo contains a collection of tools and recipes for managing a solar system.
Made ideally for being used in a small computer system like a Raspberry Pi or NUC.

## Features

- Scripts for system buildup.
- Auto-installs Docker platform.
- A full set of integrated IoT tools: Node-red, HomeAssistant, InfluxDb, etc..
- Integration with Victron GX/Venus devices.
- Compatible with DIYBMS
- An essesntial set of Node-red flows and Grafana dashboards.

## Installation

First you'll need  a blank SBC or VM system, ready to use. Remember that **is important to previously configure the device and networking but also regional and timezone settigns**. If those are not properly configured, the data points will not be correctly stored in the DBs and therefore you'll not get any data.
You'll also need to have already installed git.

I recommend using DietPi system either on a Raspberry or a VM, as it has integrated tools for reducing disk writes and thus increasing SD card/SSD lifetime.

First ssh'd in the target system and execute the following commands, at your user home directory, to download PV-Management:
```sh
git clone https://github.com/SergioRius/PV-Management.git && cd PV-Management && chmod a+x *.sh
```
Then, you would be able to execute the main script, as the root user or by using sudo:
```sh
sudo ./install.sh
```

The script will check for Docker and Docker-compose and if not present will try to install them.
The It will ask you how you want to be able to manage this machine. The first option opens the docker remote management ports and lets you connect from your Pc by using Portainer, for exmaple.
The second question allows you to locally install Portainer.
Then I't will ask you to install the container stack. You'll definitely want to.

After the jobs are completed, you'll have a running setup.
If you need to reinstall or upgrade the docker stack, you'll only need to re-run this command but answering no to the first two questions.

Then you have the option to continue preparing the system and importing sample flows and dashboards by running:
```sh
sudo ./setup.sh
```
*I expect the exmaples and dashboards to be growing with future updates, so check this repo periodically.

The sample flows and dashboards can be independently isntalled by using the import features on Node-Red and Grafana. Also could be that some files are not installing after the setup. If you prefer, you can run the setup script to configure the tooling but answer no to the import section. Then you'll find the json files on the project sub-folders.

## Usage

After the installation you'll find the following tools (remember to replace `0.0.0.0` with the IP of your target machine:
| Tool | Address |
|------|---------|
| Portainer (if chosen to install) | http://0.0.0.0:9000 |
| Node-Red | http://0.0.0.0:1880 |
| HomeAssistant | http://0.0.0.0:8123 |
| Grafana | http://0.0.0.0:3000 |
| Victron venus connector | http://0.0.0.0:8088 |

This setup includes the Victron GX/Venus connector containers to allow directly dumping Victron data into InfluxDb. You'll have to configure it at the adress above to start logging.

## Contribution

Feel free to contribute and send your flows and dashboards for them to be available to the other users. Just remember that they need to be related to the topic and that they need to be previously processed for them to be automatically installed.

Thanks for your contributions.

And if that repo become useful to you, remember that you can make a donation or drop me a beer:
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/donate?business=JRX9JK6SSY25N&no_recurring=0&item_name=Open+source+donations&currency_code=EUR)