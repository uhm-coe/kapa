#!/bin/bash -x
#This script sets up Ruby 1.9, MySQL, and Apache/Passenger on Ubuntu 12.04LT

echo "Adding a Repository..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo cp /vagrant/provision/passenger.list /etc/apt/sources.list.d/
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list
sudo apt-get update

echo "Installing Essential Tools..."
sudo apt-get install -y build-essential apt-transport-https vim git-core

echo "Installing Ruby..."
sudo apt-get remove -y ruby1.8
sudo apt-get install -y ruby1.9.3 ruby1.9.1-dev

echo "Installing Apache/Passenger..."
sudo apt-get install -y libapache2-mod-passenger
sudo rm /etc/apache2/sites-available/default
sudo cp /vagrant/provision/default /etc/apache2/sites-available/
sudo service apache2 restart

echo "Installing MariaDB..."
sudo apt-get install python-software-properties
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
sudo add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu precise main'
sudo apt-get update
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password password'
sudo debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password password'
sudo apt-get -y install mariadb-server libmariadbd-dev
sudo service mysql restart

#sudo apt-get install -y postgresql postgresql-contrib libpq-dev

echo "Installing Rails..."
cd /vagrant/
sudo gem update
sudo gem install bundler --no-rdoc --no-ri
bundle install

echo "Installation was completed."

