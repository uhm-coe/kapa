#!/bin/bash -x
#This script sets up Ruby, Apache/Passenger, and MariaDB on Ubuntu 14.04LT
echo "cd /vagrant" >> .bashrc

echo "Updating repository..."
sudo apt-get update

echo "Installing Essential Tools..."
sudo apt-get install -y build-essential vim git-core

echo "Installing Ruby..."
sudo apt-get install -y ruby2.0 ruby2.0-dev
sudo rm /usr/bin/ruby && sudo ln -s /usr/bin/ruby2.0 /usr/bin/ruby
sudo rm -fr /usr/bin/gem && sudo ln -s /usr/bin/gem2.0 /usr/bin/gem

echo "Installing Apache/Passenger..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo apt-get install apt-transport-https ca-certificates
sudo cp /vagrant/provision/passenger.list /etc/apt/sources.list.d/
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list
sudo apt-get update
sudo apt-get install -y apache2 libapache2-mod-passenger
sudo rm /etc/apache2/sites-available/000-default.conf
sudo cp /vagrant/provision/000-default.conf /etc/apache2/sites-available/
sudo service apache2 restart

#echo "Installing MySQL..."
export DEBIAN_FRONTEND=noninteractive
echo "mysql-server-5.5 mysql-server/root_password password password" | sudo debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password password" | sudo debconf-set-selections
sudo apt-get -y install mysql-server-5.5 libmysqlclient-dev
mysql --user=root --password=password -e "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION;"
sudo sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf
sudo service mysql restart

#echo "Installing PostgresSQL..."
#sudo apt-get install -y postgresql postgresql-contrib libpq-dev
#sudo su postgres
#psql -c "CREATE USER vagrant WITH PASSWORD 'vagrant';"
#psql -c "GRANT ALL PRIVILEGES to vagrant;"
#exit
#sudo service postgres restart

echo "Installing Rails..."
cd /vagrant/
sudo gem install bundler --no-rdoc --no-ri
bundle install

echo "Installation was completed."
