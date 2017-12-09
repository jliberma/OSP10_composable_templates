#!/usr/bin/env bash

# Prepare admin tenant for Heat tests

# prepare the overcloud
source ~/overcloudrc
curl http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img | openstack image create --disk-format qcow2 --container-format bare  --public cirros-0.3.4-x86_64

# deploy the admin stack (creates project, user, networks)
openstack stack create -t templates/test/admin_test.yaml admin_test

# deploy the project stack (launches instances)
sed -e 's/OS_USERNAME=admin/OS_USERNAME=user1/' -e 's/OS_PROJECT_NAME=admin/OS_PROJECT_NAME=tenant1/' -e 's/OS_PASSWORD=.*/OS_PASSWORD=redhat/' ~/overcloudrc > ~/user1.rc
source ~/user1.rc
openstack keypair create stack > ~/stack.pem
chmod 600 ~/stack.pem
openstack stack create -t templates/test/user_test.yaml user_test

# perform admin tasks
source ~/overcloudrc

# set tenant quotas
# TODO -- move this to Heat
openstack quota set --instances 24 tenant1
openstack quota set --cores 48 tenant1

# create the host aggregates
openstack aggregate create --property performance=high performance
openstack aggregate create --property performance=low development

# configure the aggregates
openstack aggregate set --property cpu_allocation_ratio='2' performance
openstack aggregate set --property cpu_allocation_ratio='16' development
openstack aggregate set --property ram_allocation_ratio='1' performance
openstack aggregate set --property ram_allocation_ratio='1.5' development

# add hosts to the aggregates
openstack aggregate add host performance overcloud-computeb-0.localdomain
openstack aggregate add host performance overcloud-computeb-1.localdomain
openstack aggregate add host development overcloud-compute-0.localdomain
openstack aggregate add host development overcloud-compute-1.localdomain

# create flavors
openstack flavor create perf.tiny --ram 512 --vcpu 1 --ephemeral 10 --public
openstack flavor create perf.small --ram 512 --vcpu 2 --ephemeral 20 --public
openstack flavor create devel.small --ram 512 --vcpu 2 --ephemeral 20 --public
openstack flavor create devel.tiny --ram 512 --vcpu 1 --ephemeral 10 --public
openstack flavor create m1.small --ram 512 --vcpu 2 --ephemeral 20 --public

# tag flavors with aggregate keys
openstack flavor set --property performance=high perf.tiny
openstack flavor set --property performance=high perf.small
openstack flavor set --property performance=low devel.tiny
openstack flavor set --property performance=low devel.small