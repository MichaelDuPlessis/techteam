#!/bin/bash

tar -czvf server.tar.gz techteam/ run_server.sh
scp -i mike-ssh-key.pem server.tar.gz ubuntu@ec2-63-33-206-130.eu-west-1.compute.amazonaws.com:~
scp -i mike-ssh-key.pem install.sh ubuntu@ec2-63-33-206-130.eu-west-1.compute.amazonaws.com:~   