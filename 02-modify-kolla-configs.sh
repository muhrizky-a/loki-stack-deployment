#!/bin/bash

# Create the /etc/kolla directory
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla

#Copy globals.yml and passwords.yml to /etc/kolla directory
cp -r ~/kolla-venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla

# Copy all-in-one and multinode inventory files to the current directory
cp ~/kolla-venv/share/kolla-ansible/ansible/inventory/* .

# Configure ansible
sudo mkdir -p /etc/ansible

echo "
[defaults]
host_key_checking=False
pipelining=True
forks=100
" | sudo tee /etc/ansible/ansible.cfg

# Generate kolla password
kolla-genpwd
cat /etc/kolla/passwords.yml

#Test ansible connectivity using ping module.
ansible -i all-in-one all -m ping
ansible -i multinode all -m ping

# Configure your openstack cluster on kolla globals.yml
sudo cp /etc/kolla/globals.yml /etc/kolla/globals.yml.backup

echo "
kolla_base_distro: "ubuntu"
openstack_release: "2024.1"
network_interface: "eth0.10"
neutron_external_interface: "eth0"
kolla_internal_vip_address: "10.10.10.100"
neutron_plugin_agent: "openvswitch"
enable_keystone: "yes"
enable_horizon: "no"
enable_neutron_provider_networks: "yes"
enable_cinder: "yes"
enable_cinder_backend_lvm: "yes"
" | sudo tee -a /etc/kolla/globals.yml

# Verify kolla globals config
cat /etc/kolla/globals.yml | grep -v "#" |  tr -s [:space:]