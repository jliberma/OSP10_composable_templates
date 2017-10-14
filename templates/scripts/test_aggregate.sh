#!/usr/bin/env bash

source ~/user1.rc

for i in $(seq 1 8)
do
	openstack server delete vm$i
done

for i in $(seq 1 8)
do 
	openstack server create  --flavor m1.tiny --image cirros-0.3.4-x86_64 --key-name stack \
            --security-group internal_sg --nic net-id=8bfa60ce-9b58-43e6-b3f7-253ebceb51f4 vm$i > /dev/null
done

source ~/overcloudrc

openstack server list --all-projects --long -c Name -c Host

for i in $(openstack host list | awk ' /compute/ { print $2 } ')
do 
	openstack host show $i -f value -c Host -c CPU -c "Memory MB"| sed -n '1p;$p'
done
