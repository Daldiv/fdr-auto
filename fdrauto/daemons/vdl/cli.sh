#!/bin/bash
# usage ./start.sh <n> where n is a number. example: ./start.sh
./vidulum-cli -datadir=/home/fdr/.vidulum$1 ${@:2}
sleep 1
