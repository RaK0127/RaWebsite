#!/bin/bash

#Installing Docker
sudo apt-get remove docker docker-engine docker.io
sudo apt-get update
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
sudo apt-get update
sudo apt-get install docker-ce -y
sudo usermod -a -G docker $USER
sudo systemctl enable docker
sudo systemctl restart docker

# start the nginx container
sudo docker run -d --name docker-nginx -p 80:80 nginx:latest

# override the html file with an html file that displays a random number
container_id=$(sudo docker ps -aqf "name=nginx")
sudo docker exec $container_id bash -c 'cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
$(shuf -i 0-1000 -n 1)
</html>
EOF'
sudo docker exec $container_id bash -c 'nginx -s reload'
