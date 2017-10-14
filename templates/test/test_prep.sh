#!/usr/bin/env bash

# Prepare admin tenant for Heat tests

# prepare the overcloud
source ~/overcloudrc
curl http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img | openstack image create --disk-format qcow2 --container-format bare  --public cirros-0.3.4-x86_64

openstack aggregate create --property cpu_allocation_ratio=8.0 performance
openstack aggregate create --property cpu_allocation_ratio=16.0 development

openstack aggregate add host performance overcloud-computeb-0.localdomain 
openstack aggregate add host performance overcloud-computeb-1.localdomain 
openstack aggregate add host development overcloud-compute-0.localdomain 
openstack aggregate add host development overcloud-compute-1.localdomain 

openstack flavor create perf.tiny --ram 512 --vcpu 1 --ephemeral 10
openstack flavor create devel.tiny --ram 512 --vcpu 1 --ephemeral 10
openstack flavor create perf.small --ram 512 --vcpu 2 --ephemeral 20
openstack flavor create devel.small --ram 512 --vcpu 2 --ephemeral 20
openstack flavor set --property aggregate_instance_extra_specs:cpu_allocation_ratio=8.0 perf.tiny
openstack flavor set --property aggregate_instance_extra_specs:cpu_allocation_ratio=8.0 perf.small
openstack flavor set --property aggregate_instance_extra_specs:cpu_allocation_ratio=16.0 devel.small
openstack flavor set --property aggregate_instance_extra_specs:cpu_allocation_ratio=16.0 devel.tiny

openstack quota set --instances 16 tenant1

# deploy the admin stack (creates project, user, networks)
openstack stack create -t templates/test/admin_test.yaml admin_test

# deploy the project stack (launches instances)
sed -e 's/OS_USERNAME=admin/OS_USERNAME=user1/' -e 's/OS_PROJECT_NAME=admin/OS_PROJECT_NAME=tenant1/' -e 's/OS_PASSWORD=.*/OS_PASSWORD=redhat/' ~/overcloudrc > ~/user1.rc
source ~/user1.rc
openstack keypair create stack > ~/stack.pem
chmod 600 ~/stack.pem
openstack stack create -t templates/test/user_test.yaml user_test

