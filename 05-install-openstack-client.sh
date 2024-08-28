#!/bin/bash

# Install openstack client and verify openstack cluster
## Install openstack client 
pip install openstackclient munch
source /etc/kolla/admin-openrc.sh

## Verify openstack cluster.
openstack service list 
docker ps