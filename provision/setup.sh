#!/bin/bash -x
#This script sets up Ruby, Apache/Passenger, and MariaDB on Ubuntu 14.04LT

echo "Updating repository..."
echo "cd /vagrant" >> .bashrc
sudo apt-get update

echo "Installing Essential Tools..."
sudo apt-get install -y build-essential apt-transport-https vim git-core

echo "Installing Ruby..."
sudo apt-get install -y ruby2.0 ruby2.0-dev
sudo rm /usr/bin/ruby && sudo ln -s /usr/bin/ruby2.0 /usr/bin/ruby
sudo rm -fr /usr/bin/gem && sudo ln -s /usr/bin/gem2.0 /usr/bin/gem

echo "Installing Apache/Passenger..."
sudo apt-get install -y apache2 libapache2-mod-passenger
sudo rm /etc/apache2/sites-available/000-default.conf
sudo cp /vagrant/provision/000-default.conf /etc/apache2/sites-available/
sudo service apache2 restart

echo "Installing MariaDB..."
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password password'
sudo debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password password'
sudo apt-get -y install mariadb-server libmariadbd-dev
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
