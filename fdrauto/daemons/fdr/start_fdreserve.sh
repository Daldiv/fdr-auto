#!/bin/bash

SEC=$1
if [ -z $SEC ]; then
	SEC=5
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

pushd ~
ls -a|grep "\.fdreserve[1-30]"|sort|while read DIR; do
    ND=${DIR: -2}

    if [ $(ps -efH|grep fdreserved|grep "fdreserve${ND}"|wc -l) -eq 0 ]; then
        echo -e "${RED}`date +%Y-%m-%d_%H:%M:%S` ${GREEN}Starting node ${ND} ...${NC}"
        cd /home/fdr/daemons/fdr/
        ./fdreserved -daemon -datadir=/home/fdr/.fdreserve${ND}
	sleep ${SEC}s
    fi
done


