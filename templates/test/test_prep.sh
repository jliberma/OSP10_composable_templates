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
