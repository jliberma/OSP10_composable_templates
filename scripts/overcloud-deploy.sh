#!/usr/bin/env bash

exec openstack overcloud deploy --timeout=90 \
	  --templates  \
          --ntp-server 10.16.255.1 \
	  -e /home/stack/templates/node-info.yaml \
	  -r /home/stack/templates/roles_data.yaml \
	  -e /home/stack/templates/network-isolation.yaml \
	  -e /home/stack/templates/environments/20-network-environment.yaml \
	  -e /home/stack/templates/environments/25-filter-environment.yaml \
	  -e /home/stack/templates/environments/30-compute-settings.yaml
