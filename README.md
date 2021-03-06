# OSP 10 Composable templates


This repository contains example scripts and templates for:
- deploying OSP 10 with composable compute roles
- configuring and testing various Nova scheduler filters


Example output from AggregateMultiTenancy filter:

```
Nova scheduler filters:
["AvailabilityZoneFilter",
 "AggregateMultiTenancyIsolation",
 "AggregateCoreFilter",
 "AggregateRamFilter",
 "ComputeFilter",
 "ComputeCapabilitiesFilter",
 "ImagePropertiesFilter",
 "AggregateInstanceExtraSpecsFilter"]
Host settings:
overcloud-compute-0: 16 1.5
overcloud-compute-1: 16 1.5
overcloud-computeb-0: 2 1
overcloud-computeb-1: 2 1
Aggregate members:
["performance","cpu_allocation_ratio='2', filter_tenant_id='6746e42827394f5786c1aaace8ccbd33', ram_allocation_ratio='1'",["overcloud-computeb-0.localdomain","overcloud-computeb-1.localdomain"]]
["development","cpu_allocation_ratio='16', filter_tenant_id='1fd4ab239e904a4f9dbc317d9139c794', ram_allocation_ratio='1.5'",["overcloud-compute-0.localdomain","overcloud-compute-1.localdomain"]]
Resource usage by host:
overcloud-computeb-1.localdomain 8 8191
overcloud-computeb-1.localdomain 10 2560
overcloud-compute-1.localdomain 4 4095
overcloud-compute-1.localdomain 12 3072
overcloud-compute-0.localdomain 4 4095
overcloud-compute-0.localdomain 10 2560
overcloud-computeb-0.localdomain 8 8191
overcloud-computeb-0.localdomain 12 3072
Instance placement:
m1.small.24 None
m1.small.23 None
devel.small.22 overcloud-compute-1
devel.small.21 overcloud-compute-0
devel.small.20 overcloud-compute-0
devel.small.19 overcloud-compute-1
devel.small.18 overcloud-compute-1
devel.small.17 overcloud-compute-0
devel.small.16 overcloud-compute-1
devel.small.15 overcloud-compute-0
devel.small.14 overcloud-compute-1
devel.small.13 overcloud-compute-1
devel.small.12 overcloud-compute-0
perf.small.11 overcloud-computeb-0
perf.small.10 overcloud-computeb-1
perf.small.9 overcloud-computeb-0
perf.small.8 overcloud-computeb-1
perf.small.7 overcloud-computeb-0
perf.small.6 overcloud-computeb-1
perf.small.5 overcloud-computeb-0
perf.small.4 overcloud-computeb-1
perf.small.3 overcloud-computeb-0
perf.small.2 overcloud-computeb-1
perf.small.1 overcloud-computeb-0
```
