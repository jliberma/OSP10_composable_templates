#!/usr/bin/env bash

# in this example we have perf flavors only available to the perf tenant
# they are tagged to run on perf machines
# the perf machines have more ram and lower cpu/ram overcommit ratios
# the advantage is tagged flavors will only run on tagged machines
# the disadvantage is that untagged flavors can run anywhere
# enforced by flavors and aggregates, there is no physical separation of compute hosts
# if we put everyone in the same tenant, everyone can run flavors tagged as perf or dev
# no protection on the perf flavors
# here we see dev flavors launched by perf tenant running on dev, and perf flavors launched
# by perf tenant running on perf, and dev flavors launched by dev tenant running on dev,
# but we also see untagged flavors running on the perf aggregate due to ram availability filters
# in all cases we tag the aggregate and flavors, then add hosts and attributes to the aggregate
# aggegate settings override local host settings.

# check filter setting on controllers
source ~/stackrc
echo "Nova scheduler filters:"
C1IP=$(openstack server list | awk ' /controller-0/ { print $8 }' | cut -f2 -d=)
ssh -l heat-admin -o StrictHostKeyChecking=no $C1IP "sudo hiera nova::scheduler::filter::scheduler_default_filters | tr '\n' ' '"

echo -e

# display aggregate values
for i in $(openstack aggregate list -f value | awk ' { print $2 } ')
do 
	echo "$i aggregate" && openstack aggregate show $i | awk ' BEGIN { FS = "," } /hosts/ || /properties/ { print }'
done

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
source ~/perf_user.rc
for i in $(openstack server list -f value -c ID)
do
	openstack server delete $i
done

source ~/dev_user.rc
for i in $(openstack server list -f value -c ID)
do
	openstack server delete $i
done

source ~/user1.rc
for i in $(openstack server list -f value -c ID)
do
	openstack server delete $i
done

# find subnet IDs
source ~/overcloudrc
PERF_NET=$(openstack network list | awk ' /perf_net/ { print $2 } ')
DEV_NET=$(openstack network list | awk ' /dev_net/ { print $2 } ')
USER_NET=$(openstack network list | awk ' /internal_net/ { print $2 } ')

# create perf vms
# 20 cores total, should only run on perf nodes
source ~/perf_user.rc
for i in $(seq 1 10)
do 
	openstack server create  --flavor perf.small --image cirros-0.3.4-x86_64 --key-name perf \
            --nic net-id=$PERF_NET perf.small.$i > /dev/null
done

# create devel vms
# 20 cores total, should only run on devel nodes
source ~/dev_user.rc
for i in $(seq 11 20)
do 
	openstack server create  --flavor devel.small --image cirros-0.3.4-x86_64 --key-name dev \
            --nic net-id=$DEV_NET devel.small.$i > /dev/null
done

# create devel vms as perf user -- should schedule to devel hosts
source ~/perf_user.rc
for i in $(seq 21 22)
do 
	openstack server create  --flavor devel.small --image cirros-0.3.4-x86_64 --key-name perf \
            --nic net-id=$PERF_NET devel.small.$i > /dev/null
done

# create generic vms as dev user
source ~/user1.rc
for i in $(seq 23 24)
do 
	openstack server create  --flavor m1.small --image cirros-0.3.4-x86_64 --key-name stack \
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
openstack flavor list --all -f value -c Name -c RAM -c VCPUs

# view resource usage by host
echo "Resource usage by host:"
for i in $(openstack host list | awk ' /compute/ { print $2 } ')
do 
	openstack host show $i -f value -c Host -c Project -c CPU -c "Memory MB"| sed -n '1p;$p'
done

# view vm placement
echo "Instance placement:"
openstack server list --all-projects --long -c Name -c Host -f value | sed 's/.localdomain//'
