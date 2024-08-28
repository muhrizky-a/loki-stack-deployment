#!/bin/bash

# Bootstrap Servers
kolla-ansible -i ./all-in-one bootstrap-servers

# Prechecks
kolla-ansible -i ./all-in-one prechecks

# Deployment
sudo kill -HUP $(cat /run/openvswitch/ovsdb-server.pid)
kolla-ansible -i ./all-in-one deploy

# Post Deploy
kolla-ansible -i ./all-in-one post-deploy

# Configure ansible
sudo mkdir -p /etc/ansible
