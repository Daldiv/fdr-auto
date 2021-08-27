#! /bin/bash/

# MN number ID or name plus image from docker repo.
NAME="$1"
REPO='daldiv/fdr-mn'
MNPATH='/root/.fdreserve'

# Downloads and starts container. Copies blochain data to unique volume.
docker volume create --name "$NAME"
docker run -dit \
	--name "$NAME" \
	--stop-timeout 20 \
	-v "$NAME":/root \
	"$REPO"

docker cp "$MNPATH"/blocks "$NAME":"$MNPATH"
docker cp "$MNPATH"/chainstate "$NAME":"$MNPATH"
docker exec -dit "$NAME" "bash /root/mn-docker-install.sh"

# Gets and displays blockchain status.
#docker exec -it "$NAME" "fdreserve-cli getblockchaininfo && \
#	fdreserve-cli get networkinfo \

# Displays mn conf
docker exec -it "$NAME" "cat "$MNPATH"/masternode.conf"
