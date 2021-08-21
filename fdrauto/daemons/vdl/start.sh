#!/bin/bash
# usage ./start.sh <n> where n is a number. example: ./start.sh
./vidulumd -daemon -datadir=/home/fdr/.vidulum$1 ${@:2}
sleep 1
