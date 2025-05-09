#!/bin/bash

apt update -y
apt install -y docker.io git

sudo usermod -aG docker ubuntu
newgrp docker

git clone https://github.com/alexandermoroz01/test-docker-nginx.git

sudo systemctl enable docker
sudo systemctl start docker

cd test-docker-nginx
docker build -t test-app .
docker run -d -p 80:80 --name test-app --restart unless-stopped test-app