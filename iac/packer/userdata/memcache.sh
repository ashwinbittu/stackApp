#!/bin/bash

sudo yum install epel-release -y > /tmp/user-data.log
sudo yum install memcached -y >>  /tmp/user-data.log
sudo systemctl start memcached >>  /tmp/user-data.log
sudo systemctl enable memcached >>  /tmp/user-data.log
sudo systemctl status memcached >>  /tmp/user-data.log
sudo memcached -p 11211 -U 11111 -u memcached -d >>  /tmp/user-data.log
