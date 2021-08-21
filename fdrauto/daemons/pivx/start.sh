#!/bin/bash
# usage ./start.sh <n> where n is a number. example: ./start.sh
./pivxd -daemon -datadir=/home/fdr/.pivx$1 ${@:2}
sleep 1
