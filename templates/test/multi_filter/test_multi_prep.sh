#!/usr/bin/env bash

# Prepare multiple tenants for aggregate tests

# prepare the overcloud
source ~/overcloudrc

# create the projects
openstack stack create -t /home/stack/templates/test/multitenant/perf_stack.yaml perf_stack
openstack stack create -t /home/stack/templates/test/multitenant/dev_stack.yaml dev_stack
openstack stack create -t /home/stack/templates/test/multitenant/user_test.yaml user_stack

# set project quotas
openstack quota set --instances 24 perf_tenant
openstack quota set --cores 48 perf_tenant
openstack quota set --instances 24 dev_tenant
openstack quota set --cores 48 dev_tenant

# create the aggregates
openstack aggregate create performance
openstack aggregate create development
PERF_ID=$(openstack project list | awk ' /perf/ { print $2 } ')
DEV_ID=$(openstack project list | awk ' /dev/ { print $2 } ')
openstack aggregate set --property filter_tenant_id=$PERF_ID performance
openstack aggregate set --property filter_tenant_id=$DEV_ID development
openstack aggregate set --property cpu_allocation_ratio='2' performance
openstack aggregate set --property cpu_allocation_ratio='16' development
openstack aggregate set --property ram_allocation_ratio='1' performance
openstack aggregate set --property ram_allocation_ratio='1.5' development

# add hosts to aggregate
openstack aggregate add host performance overcloud-computeb-0.localdomain
openstack aggregate add host performance overcloud-computeb-1.localdomain
openstack aggregate add host development overcloud-compute-0.localdomain
openstack aggregate add host development overcloud-compute-1.localdomain

# create flavors
openstack flavor create perf.tiny --ram 512 --vcpu 1 --ephemeral 10 --private
openstack flavor create perf.small --ram 512 --vcpu 2 --ephemeral 20 --private
openstack flavor create devel.small --ram 512 --vcpu 2 --ephemeral 20 --public
openstack flavor create devel.tiny --ram 512 --vcpu 1 --ephemeral 10 --public

# set flavor project
openstack flavor set perf.tiny --project $PERF_ID
openstack flavor set perf.small --project $PERF_ID

# tag flavors with aggregate keys
openstack flavor set --property performance=high perf.tiny
openstack flavor set --property performance=high perf.small
openstack flavor set --property performance=low devel.tiny
openstack flavor set --property performance=low devel.small

# configure the perf stack environment
sed -e 's/OS_USERNAME=admin/OS_USERNAME=perf_user/' -e 's/OS_PROJECT_NAME=admin/OS_PROJECT_NAME=perf_tenant/' -e 's/OS_PASSWORD=.*/OS_PASSWORD=redhat/' ~/overcloudrc > ~/perf_user.rc
source ~/perf_user.rc
openstack keypair create perf > ~/perf.pem
chmod 600 ~/perf.pem

# deploy the dev stack environment
sed -e 's/OS_USERNAME=admin/OS_USERNAME=dev_user/' -e 's/OS_PROJECT_NAME=admin/OS_PROJECT_NAME=dev_tenant/' -e 's/OS_PASSWORD=.*/OS_PASSWORD=redhat/' ~/overcloudrc > ~/dev_user.rc
source ~/dev_user.rc
openstack keypair create dev > ~/dev.pem
chmod 600 ~/dev.pem

# deploy the project stack (launches instances)
sed -e 's/OS_USERNAME=admin/OS_USERNAME=user1/' -e 's/OS_PROJECT_NAME=admin/OS_PROJECT_NAME=tenant1/' -e 's/OS_PASSWORD=.*/OS_PASSWORD=redhat/' ~/overcloudrc > ~/user1.rc
source ~/user1.rc
openstack keypair create stack > ~/stack.pem
chmod 600 ~/stack.pem
