#!/usr/bin/env bash

# Single tenant for aggregate tests

# prepare the overcloud
source ~/overcloudrc

# create the perf and dev tenants
openstack stack create -t /home/stack/templates/test/multi/perf_stack.yaml perf_stack
openstack stack create -t /home/stack/templates/test/multi/dev_stack.yaml dev_stack

# set tenant quotas
openstack quota set --instances 24 perf_tenant
openstack quota set --cores 48 perf_tenant
openstack quota set --instances 24 dev_tenant
openstack quota set --cores 48 dev_tenant

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
