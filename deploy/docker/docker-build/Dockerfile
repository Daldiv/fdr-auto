# syntax=docker/dockerfile:1
# Sets of container base and variables.
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
LABEL version="0.2" \
	maintainer="FDReserve Team" \
	website="https://www.fdreserve.com/" \
	author="Daldiv@github"

# Copies essential data from build area to container.
COPY ./mn-docker-install.sh /root
COPY ./systemctl3.py /usr/bin/systemctl

# Updates base ubuntu image and installs tools for mn install.
RUN apt update && apt upgrade -y && apt install -y \
	curl \
	figlet \
	sed \
	ufw \
	vim \
	wget \
	unzip \
	net-tools && \
	apt auto-remove && apt clean && \
	rm -rf /var/lib/apt/lists/* && \
	chmod +x /root/mn-docker-install.sh

# Exposes network ports for blockchain.
EXPOSE 12474

# Sets proper PID 1 running command and copies essential data.
ENTRYPOINT [ "/usr/bin/systemctl"]


