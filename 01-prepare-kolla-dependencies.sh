#!/bin/bash

# Update repository
sudo apt update

# Install dependencies
sudo apt-get install python3-dev libffi-dev gcc libssl-dev python3-selinux python3-setuptools python3-venv -y

# Create venv
python3 -m venv ~/kolla-venv
source ~/kolla-venv/bin/activate

# Install ansible and kolla-ansible
pip install -U pip
pip install 'ansible>=8,<9'
pip install kolla-ansible
kolla-ansible install-deps