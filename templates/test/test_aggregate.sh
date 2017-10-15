#!/usr/bin/env bash


# check filter setting
source ~/stackrc
echo "Nova scheduler filters:"
C1IP=$(openstack server list | awk ' /controller-0/ { print $8 }' | cut -f2 -d=)
ssh -l heat-admin -o StrictHostKeyChecking=no $C1IP sudo hiera nova::scheduler::filter::scheduler_default_filters

# delete existing vms
source ~/user1.rc
for i in $(openstack server list -f value -c ID)
do
	openstack server delete $i
done

# create perf vms
for i in $(seq 1 8)
do 
	openstack server create  --flavor perf.small --image cirros-0.3.4-x86_64 --key-name stack \
            --security-group internal_sg --nic net-id=8bfa60ce-9b58-43e6-b3f7-253ebceb51f4 vm$i > /dev/null
done

# create devel vms
for i in $(seq 9 16)
do 
	openstack server create  --flavor devel.small --image cirros-0.3.4-x86_64 --key-name stack \
            --security-group internal_sg --nic net-id=8bfa60ce-9b58-43e6-b3f7-253ebceb51f4 vm$i > /dev/null
done


# output results
source ~/overcloudrc

# show aggregate members
echo "Aggregate members:"
for i in $(openstack aggregate list -f value -c Name)
do 
	openstack aggregate show $i -f json | jq -c '[.name, .properties, .hosts]'
done

# view resource usage by host
echo "Resource usage by host:"
for i in $(openstack host list | awk ' /compute/ { print $2 } ')
do 
	openstack host show $i -f value -c Host -c CPU -c "Memory MB"| sed -n '1p;$p'
done

# view vm placement
echo "Instance placement:"
openstack server list --all-projects --long -c Name -c Host -f value

