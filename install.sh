#!/bin/bash

### pass in name of lxc lxc_container ###

# updating apt
sudo apt-get -y update

# determining if a name was passed in
if [ -z "$1" ]
then
    lxc_container='django-server'
else
    lxc_container=$1
fi


echo -e '\nBegin LXD/LXC creation\n'
# initializing lxd using minimal setup
sudo lxd init --minimal

# creating debain instance
lxc launch images:debian/11 $lxc_container

# installing needed packages
lxc exec $lxc_container -- apt-get -y install build-essential python
lxc exec $lxc_container -- apt-get -y install python-dev
lxc exec $lxc_container -- apt-get -y install python3-dev
lxc exec $lxc_container -- apt -y install virtualenv

echo -e '\nEnd LXD/LXC creation\n'

echo -e '\nBegin Docker creation\n'
# installing docker
sudo apt-get -y install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# creating docker group if it doesnt exist and adding current user
if [ ! $(getent group docker) ]; then
  sudo groupadd docker
fi

if ! id -nG "$USER" | grep -qw "docker"; then
    echo 'test'
    sudo usermod -aG docker $USER
    newgrp docker
fi

echo -e '\nEnd Docker creation\n'

echo -e '\nBegin Django creation\n'
# creating/moving django project
lxc file push server.tar.gz $lxc_container/root/ # archive also contains run_server.sh
lxc exec $lxc_container -- tar -xzf server.tar.gz

# creating virtual env
lxc exec $lxc_container -- virtualenv server-env # webservers virtual env

echo -e '\nEnd Django creation\n'

echo -e '\nBegin Docker setup\n'
# gettimg servers ip
address=$(lxc exec $lxc_container -- ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

# setting up docker and reverse proxy
docker run -d --name nginx-base -p 80:80 nginx:latest # staring docker

mkdir ~/temp_server # creating temporty director
docker cp nginx-base:/etc/nginx/conf.d/default.conf ~/temp_server/default.conf # copying confif file to be edited
# adding server ip as reverse proxy
sed -i '$ d' ~/temp_server/default.conf # removing last line of file
sed -i '$ d' ~/temp_server/default.conf # removing last line of file again to get rid of closing brace
echo -e "    location /status {\n        proxy_pass http://$address:8000/status;\n    }\n}"  >>  ~/temp_server/default.conf

docker cp ~/temp_server/default.conf nginx-base:/etc/nginx/conf.d/ # moving config file back to docker
rm -rf ~/temp_server # removing temp directory
# validating and relaoding docker container
docker exec nginx-base nginx -t
docker exec nginx-base nginx -s reload

echo -e '\nEnd Docker setup\n'

# starting django server
lxc exec $lxc_container -- bash run_server.sh
