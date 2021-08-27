#!/bin/bash
# Script done by Fdr Team
# https://www.fdreserve.com

CONFIG_FILE='fdreserve.conf'
CONFIGFOLDER='/root/.fdreserve'
COIN_PATH='/usr/local/bin'
#64 bit only
COIN_TGZ='https://github.com/fdreserve/fdr-blockchain/releases/download/V2.3.0/2021-03-15_FDReserve_V230_Linux64.zip'
BOOTSTRAP_TGZ='https://fdreserve.com/downloads/snapshot.zip'
COIN_DAEMON="fdreserved"
COIN_CLI="fdreserve-cli"
COIN_TX="fdreserve-tx"
COIN_NAME='FDReserve'
COIN_PORT=12474

NODEIP=$(curl -4 icanhazip.com)

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

progressfilt () {
  local flag=false c count cr=$'\r' nl=$'\n'
  while IFS='' read -d '' -rn 1 c
  do
    if $flag
    then
      printf '%c' "$c"
    else
      if [[ $c != $cr && $c != $nl ]]
      then
        count=0
      else
        ((count++))
        if ((count > 1))
        then
          flag=true
        fi
      fi
    fi
  done
}

function download_node() {
figlet -f slant "FDReserve"
  echo -e "Prepare to download $COIN_NAME"
  TMP_FOLDER=$(mktemp -d)
  cd $TMP_FOLDER
  wget --progress=bar:force $COIN_TGZ 2>&1 | progressfilt
  compile_error
  COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
  unzip $COIN_ZIP >/dev/null 2>&1
  compile_error
  chmod +x $COIN_DAEMON $COIN_CLI $COIN_TX
  cp -p $COIN_DAEMON $COIN_CLI $COIN_TX $COIN_PATH/
  compile_error
  rm -f $COIN_ZIP fdreserve-qt >/dev/null 2>&1
  cd ~ >/dev/null
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}

function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target
[Service]
User=root
Group=root
Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid
ExecStart=$COIN_PATH/$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH/$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF

  sleep 3
  systemctl start $COIN_NAME
  systemctl enable $COIN_NAME
  chkconfig $COIN_NAME on >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}service $COIN_NAME start"
    echo -e "service $COIN_NAME status"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}

function create_config() {
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
listen=1
server=1
txindex=1
daemon=1
port=$COIN_PORT
EOF
}

function create_key() {
#  echo -e "Enter your ${RED}$COIN_NAME Masternode Private Key${NC}.\nLeave it blank to generate a new ${RED}$COIN_NAME Masternode Private Key${NC} for you:"
#  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
    $COIN_PATH/$COIN_DAEMON -daemon
    sleep 30
    if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
      echo -e "${RED}$COIN_NAME server couldn't not start. Check /var/log/syslog for errors.{$NC}"
      exit 1
    fi
    COINKEY=$($COIN_PATH/$COIN_CLI masternode genkey)
    if [ "$?" -gt "0" ];
      then
      echo -e "${RED}Wallet not fully loaded. Let us wait for 30s and try again to generate the Private Key${NC}"
      sleep 30
      COINKEY=$($COIN_PATH/$COIN_CLI masternode genkey)
      if [ "$?" -gt "0" ];
      then
        echo -e "${RED}Wallet not fully loaded. Let us wait for another 30s and try again to generate the Private Key${NC}"
        sleep 30
        COINKEY=$($COIN_PATH/$COIN_CLI masternode genkey)
      fi
    fi
  $COIN_PATH/$COIN_CLI stop
  sleep 10
fi
clear
}

function update_config() {
  sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
logintimestamps=1
maxconnections=512
#bind=$NODEIP
staking=0
masternode=1
externalip=$NODEIP
masternodeaddr=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY

# Seed Nodes
addnode=161.97.167.197
addnode=161.97.167.201
addnode=144.91.95.43
addnode=144.91.95.44
addnode=167.86.119.223
addnode=164.68.96.160
addnode=167.86.124.134
addnode=[2a02:c207:2027:2245::1]
addnode=[2a02:c207:2027:5644::1]
addnode=[2a02:c207:2027:9123::1]
addnode=[2a02:c207:2051:9094::1]
addnode=[2a02:c207:2051:9093::1]
addnode=[2a02:c206:2051:9083::1]
addnode=[2a02:c206:2051:9077::1]

EOF
}

function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow ssh >/dev/null 2>&1
  ufw allow $COIN_PORT >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}

function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      #read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}

function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}

function checks() {
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi
}

function create_swap() {
 echo -e "Checking if swap space is needed."
 PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
 SWAP=$(swapon -s)
 if [[ "$PHYMEM" -lt "2"  &&  -z "$SWAP" ]]
  then
    echo -e "${GREEN}Server is running with less than 2G of RAM without SWAP, creating 6G swap file.${NC}"
    SWAPFILE=$(mktemp)
    dd if=/dev/zero of=$SWAPFILE bs=1024 count=6M
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon -a $SWAPFILE
 else
  echo -e "${GREEN}The server running with at least 2G of RAM, or a SWAP file is already in place.${NC}"
 fi
 clear
}


function important_information() {
 echo
 echo -e "================================================================================"
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME ${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME ${NC}"
 echo -e "Status: ${RED}systemctl status$COIN_NAME ${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEY${NC}"
 echo -e "Check if $COIN_NAME is running by using the following command:\n${RED}ps -ef | grep $COIN_DAEMON | grep -v grep${NC}"
 echo -e "================================================================================"
}

function setup_node() {
  get_ip
  create_config
  echo -e "${YELLOW}"
  figlet -f slant "FDReserve"
  create_key
  echo -e "${YELLOW}"
  figlet -f slant "FDReserve"
  update_config
  enable_firewall
  important_information
  configure_systemd
}


##### Main #####
clear

checks
create_swap
download_node
setup_node
