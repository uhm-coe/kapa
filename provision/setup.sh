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

echo "Installing MySQL..."
echo "mysql-server-5.5 mysql-server/root_password password password" | sudo debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password password" | sudo debconf-set-selections
sudo apt-get -y install mysql-server-5.5 libmysqlclient-dev
sudo service mysql restart

echo "Installing Rails..."
cd /vagrant/
sudo gem update
sudo gem install bundler --no-rdoc --no-ri
bundle install

echo "Installation was completed."

