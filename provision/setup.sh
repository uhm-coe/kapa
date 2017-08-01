#!/usr/bin/env bash

export PYTHONUNBUFFERED=1
export ANSIBLE_FORCE_COLOR=1

if ! [ `which ansible` ]; then
  if [ -f /etc/redhat-release ]; then
    sudo yum install -y epel-release yum-utils > /dev/null
    sudo yum-config-manager --enable epel > /dev/null
    sudo yum install -y ansible > /dev/null
  fi

  if [ -f /etc/lsb-release ]; then
    sudo apt-get update -y
    sudo apt-get -y install python3-pip python-dev libssl-dev libffi-dev
    sudo -H pip3 install markupsafe
    sudo -H pip3 install ansible
  fi
fi

ansible-playbook -i "localhost," -c local /vagrant/provision/setup-vagrant.yml
