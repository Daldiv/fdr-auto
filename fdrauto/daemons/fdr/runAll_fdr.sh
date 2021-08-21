#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

pushd ~ >/dev/null
ls -a|grep "\.fdreserve_[0-30]"|sort|while read DIR; do
    ND=${DIR: -2}

    if [ $(ps -efH|grep fdreserved|grep "fdreserve_${ND}"|wc -l) -gt 0 ]; then
        echo -e "${RED}`date +%Y-%m-%d_%H:%M:%S` ${GREEN}Running on ${ND}${NC}: `fdreserve-cli -conf=/root/.fdreserve_${ND}/fdreserve.conf $@`"
    fi
done

popd >/dev/null

