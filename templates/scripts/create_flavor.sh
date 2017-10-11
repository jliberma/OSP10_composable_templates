#!/usr/bin/env bash

source /home/stack/stackrc
ironic node-update overcloud-$i add properties/capabilities='profile:computeb,boot_option:local'
openstack flavor create --id auto --ram 8192 --disk 40 --vcpus 8 computeb
openstack flavor set  --property "capabilities:boot_option"="local" --property "capabilities:profile"="computeb" computeb
