#!/bin/bash

# Bootstrap Servers
kolla-ansible -i ./multinode bootstrap-servers

# Prechecks
kolla-ansible -i ./multinode prechecks

# Deployment
sudo kill -HUP $(cat /run/openvswitch/ovsdb-server.pid)
kolla-ansible -i ./multinode deploy

# Post Deploy
kolla-ansible -i ./multinode post-deploy

# Configure ansible
sudo mkdir -p /etc/ansible
