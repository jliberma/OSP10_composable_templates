#!/usr/bin/env bash

# Prepare multiple tenants for aggregate tests

# prepare the overcloud
source ~/overcloudrc

openstack stack create -t /home/stack/templates/test/perf_stack.yaml perf_stack
openstack stack create -t /home/stack/templates/test/dev_stack.yaml dev_stack

openstack quota set --instances 24 perf_tenant
openstack quota set --cores 48 perf_tenant
openstack quota set --instances 24 dev_tenant
openstack quota set --cores 48 dev_tenant

openstack aggregate set --property filter_tenant_id=perf_tenant performance
openstack aggregate set --property filter_tenant_id=dev_tenant development
openstack aggregate set --property cpu_allocation_ratio='2' performance
openstack aggregate set --property cpu_allocation_ratio='16' development
openstack aggregate set --property ram_allocation_ratio='1' performance
openstack aggregate set --property ram_allocation_ratio='1.5' development

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
