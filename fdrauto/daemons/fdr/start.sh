#!/bin/bash
# usage ./start.sh <n> where n is a number. example: ./start.sh
./fdreserved -daemon -datadir=/home/fdr/.fdreserve$1 ${@:2}
sleep 1
