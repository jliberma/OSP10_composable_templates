#!/usr/bin/env bash

# check filter setting on controllers
source ~/stackrc
echo "Nova scheduler filters:"
C1IP=$(openstack server list | awk ' /controller-0/ { print $8 }' | cut -f2 -d=)
ssh -l heat-admin -o StrictHostKeyChecking=no $C1IP "sudo hiera nova::scheduler::filter::scheduler_default_filters | tr '\n' ' '"
echo -e "\n"

# gather compute host settings
echo "Host settings:"
for i in $(openstack server list | awk ' /compute/ { print $8 } ' | cut -f2 -d=)
do
	HOST=$(ssh -l heat-admin -o StrictHostKeyChecking=no $i sudo facter hostname)
	CPU=$(ssh -l heat-admin -o StrictHostKeyChecking=no $i sudo hiera nova::cpu_allocation_ratio)
	RAM=$(ssh -l heat-admin -o StrictHostKeyChecking=no $i sudo hiera nova::ram_allocation_ratio)
	echo "$HOST: $CPU $RAM"
done

# delete existing vms
source ~/overcloudrc
for i in $(openstack server list -f value -c ID --all-projects)
do
	openstack server delete $i
done

# find subnet IDs
USER_NET=$(openstack network list | awk ' /test_net/ { print $2 } ')

# create perf vms
source ~/test_user.rc
for i in $(seq 1 11)
do 
        openstack server create  --flavor perf.small --image cirros-0.3.4-x86_64 --key-name test \
            --nic net-id=$USER_NET perf.small.$i > /dev/null
done

# create devel vms
for i in $(seq 12 22)
do 
        openstack server create  --flavor devel.small --image cirros-0.3.4-x86_64 --key-name test \
            --nic net-id=$USER_NET devel.small.$i > /dev/null
done

# create generic vms
for i in $(seq 23 24)
do 
        openstack server create  --flavor m1.small --image cirros-0.3.4-x86_64 --key-name test \
            --nic net-id=$USER_NET m1.small.$i > /dev/null
done

# output results
source ~/overcloudrc

# show aggregate members
echo "Aggregate members:"
for i in $(openstack aggregate list -f value -c Name)
do 
	openstack aggregate show $i -f json | jq -c '[.name, .properties, .hosts]'
done

# show flavors
openstack flavor list --all

# view resource usage by host
echo "Resource usage by host:"
for i in $(openstack host list | awk ' /compute/ { print $2 } ')
do 
	openstack host show $i -f value -c Host -c CPU -c "Memory MB"| sed -n '1p;$p'
done

# view vm placement
echo "Instance placement:"
openstack server list --all-projects --long -c Name -c Host -f value | sed 's/.localdomain//'

