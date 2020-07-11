#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "=============================minikube latest============================================================="

sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update -qq
sudo apt-get install -qqy oracle-java8-installer

sudo apt-get update -qq
sudo apt-get upgrade

sudo apt-get install -qqy \
              build-essential libreadline-dev libssl-dev libpq5 \
              libpq-dev libreadline5 libsqlite3-dev libpcap-dev \
              git-core autoconf postgresql pgadmin3 curl zlib1g-dev \
              libxml2-dev libxslt1-dev libyaml-dev curl zlib1g-dev \
              gawk bison libffi-dev libgdbm-dev libncurses5-dev \
              libtool sqlite3 libgmp-dev gnupg2 dirmngr

gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
source ~/.bashrc
RUBYVERSION=$(wget https://raw.githubusercontent.com/rapid7/metasploit-framework/master/.ruby-version -q -O - )
rvm install $RUBYVERSION
rvm use $RUBYVERSION --default
ruby -v

cd ~ && git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc

# sudo plugin so we can run Metasploit as root with "rbenv sudo msfconsole"
git clone git://github.com/dcarley/rbenv-sudo.git ~/.rbenv/plugins/rbenv-sudo
exec $SHELL

RUBYVERSION=$(wget https://raw.githubusercontent.com/rapid7/metasploit-framework/master/.ruby-version -q -O - )
rbenv install $RUBYVERSION
rbenv global $RUBYVERSION
ruby -v

mkdir ~/Development && cd ~/Development
git clone https://github.com/nmap/nmap.git
cd nmap
./configure
make
sudo make install
make clean

cd /opt && sudo git clone https://github.com/rapid7/metasploit-framework.git
sudo chown -R `whoami` /opt/metasploit-framework
cd metasploit-framework

# If using RVM set the default gem set that is create when you navigate in to the folder
rvm --default use ruby-${RUBYVERSION}@metasploit-framework
gem install bundler
bundle install

sudo bash -c 'for MSF in $(ls msf*); do ln -s /opt/metasploit-framework/$MSF /usr/local/bin/$MSF;done'

echo "export PATH=$PATH:/usr/lib/postgresql/10/bin" >> ~/.bashrc
. ~/.bashrc

sudo usermod -a -G postgres `whoami`
sudo su - `whoami`
cd /opt/metasploit-framework/
./msfdb init

msfconsole
