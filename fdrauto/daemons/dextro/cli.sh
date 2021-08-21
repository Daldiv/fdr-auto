#!/bin/bash
# usage ./start.sh <n> where n is a number. example: ./start.sh
./dextro-cli -datadir=/home/fdr/.dextrocore$1 ${@:2}
sleep 1
