#!/bin/bash

echo "
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: yes
  vlans:
    vlan10:
      id: 10
      link: eth0
      addresses: [10.10.10.10]
" | sudo tee /etc/netplan/50-cloud-init.yaml

sudo netplan apply

# Create VLAN interface with VLAN ID 10

#ip link add link eth0 name eth0.10 type vlan id 10



# Assign a static IP address to the VLAN interface

#ip addr add 10.10.10.10/24 dev eth0.10



# Bring up the VLAN interface

#ip link set up eth0.10

# Make all files executable
chmod +x *.sh