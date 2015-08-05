#!/usr/bin/env bash

export PYTHONUNBUFFERED=1
export ANSIBLE_FORCE_COLOR=1

if ! [ `which ansible` ]; then
    sudo apt-get update -y > /dev/null
    sudo apt-get install -y ansible > /dev/null
    echo "cd /vagrant" >> .bashrc
fi

ansible-playbook -i "localhost," -c local /vagrant/provision/rails-devserver.yml

