#!/bin/bash
# usage ./start.sh <n> where n is a number. example: ./start.sh
./delion-cli -datadir=/home/fdr/.delion$1 ${@:2}
sleep 1
