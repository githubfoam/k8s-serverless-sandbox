#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://clouding.io/hc/en-us/articles/360010634560-How-to-Install-PowerDNS-on-Ubuntu-18-04
echo "=============================minikube latest============================================================="
apt-get update -qqy
apt-get upgrade -y
apt-get install mariadb-server mariadb-client -yqq
