#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-drone-on-ubuntu-16-04
echo "=============================minikube latest============================================================="
sudo apt-get update -qq && sudo apt-get install nginx -qqy

sudo ufw app list
sudo ufw allow 'Nginx HTTP'
sudo ufw status
systemctl status nginx

ip addr show eth0 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'

sudo apt-get install curl -qqy
curl -4 icanhazip.com

sudo add-apt-repository -y ppa:certbot/certbot

sudo apt-get update -qq
sudo apt-get install python-certbot-nginx -qqy

sudo cat /etc/nginx/sites-available/default
sudo nginx -t

sudo systemctl reload nginx
sudo ufw status

sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP
sudo ufw status

# sudo certbot --nginx -d example.com -d www.example.com
# sudo certbot renew --dry-run

docker pull drone/drone:0.7
