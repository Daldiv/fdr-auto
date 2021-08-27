#! /bin/bash/

# MN number ID or name plus image from docker repo.
NAME="$1"
REPO='fdreserve/fdr-master:0.4'
MNPATH='/root/.fdreserve'

# Downloads and starts container. Copies blochain data to unique volume.
docker volume create --name "$NAME"
docker run -dit \
	--name "$NAME" \
	--stop-timeout 20 \
	-v "$NAME":"$MNPATH" \
	"$REPO"

docker cp "$MNPATH"/blocks "$NAME":"$MNPATH"
docker cp "$MNPATH"/chainstate "$NAME":"$MNPATH"
docker exec -it "$NAME" bash /root/mn-docker-install.sh
