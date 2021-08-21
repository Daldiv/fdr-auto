#! /bin/bash

# Updates and installs linux components.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function prepare_system_for_download() {
echo -e "Preparing the system to install a ${GREEN}$COIN_NAME${NC} master node."
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update 
apt-get upgrade
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" wget curl figlet unzip net-tools ufw
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed. Try installing them manually by running the following commands:${NC}\n"
    echo "apt-get  update"
    echo "apt-get install -y wget curl figlet unzip net-tools ufw"
 exit 1
fi
}

##### Main #####
prepare_system_for_download


