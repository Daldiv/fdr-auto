#!/bin/bash
# usage ./start.sh <n> where n is a number. example: ./start.sh
./pivx-cli -datadir=/home/fdr/.pivx$1 ${@:2}
sleep 1
