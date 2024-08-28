#!/bin/bash

# Create cinder-volumes VG
sudo pvcreate /dev/vdb 
sudo vgcreate cinder-volumes /dev/vdb 
sudo vgs
