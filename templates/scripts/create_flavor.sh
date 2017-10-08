#!/usr/bin/env bash

source /home/stack/stackrc
openstack flavor list
openstack flavor create --id auto --ram 4096 --disk 40 --vcpus 1 compute-b
openstack flavor set  --property "capabilities:boot_option"="local" --property "capabilities:profile"="compute-b" compute-b
openstack flavor show compute-b
