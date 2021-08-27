#! /bin/bash

# Variables. Change as needed.
MNUMBER='502'
MNPATH='/root/.fdreserve'
MNSCRIPT='https://raw.githubusercontent.com/fdreserve/fdr-mn-guide/master/fdr-mn-install.sh'

# Get newest MasterNode install script for Docker.
cd /root/	
curl -s "$MNSCRIPT" -o mn-docker-install.sh

# Creates and runs base docker environment.
docker volume create --name "$MNUMBER"
docker run -dit \
	--name "$MNUMBER" \
	-v "$MNUMBER":/root/ \
	ubuntu:latest bash \


# Uses Docker to copy the main host MasterNode blockchain data folders to the container.
docker cp "$MNPATH"/blocks "$MNUMBER":"$MNPATH"
docker cp "$MNPATH"/chainstate "$MNUMBER":"$MNPATH"
docker cp /root/mn-docker-install.sh "$MNUMBER":/root/

# Creates a terminal and runs the MasterNode install script. 
docker exec -it "$MNUMBER" /bin/bash 
#docker exec -d "$MNUMBER" bash /root/mn-docker-install.sh


