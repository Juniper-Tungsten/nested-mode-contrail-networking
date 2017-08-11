# EXAMPLE TESTBED WITH 1 CONTROLLER & 2 COMPUTES

# Author: SAVITHRU LOKANATH
# Contact: SAVITHRU AT JUNIPER.NET
# Copyright (c) 2017 Juniper Networks, Inc. All rights reserved.

from fabric.api import env

controller = 'root@10.84.18.11'
compute1 = 'root@10.84.18.12'
compute2 = 'root@10.84.18.13'
compute3 = 'root@10.84.18.14'

ext_routers = []

router_asn = 64512

host_build = 'root@10.84.18.11'

env.roledefs = {
    'all': [controller,compute1,compute2,compute3],
    'contrail-controller': [controller],
    'openstack': [controller],
    'contrail-compute': [compute1,compute2,compute3],
    'contrail-analytics': [controller],
    'contrail-analyticsdb': [controller],
    'build': [host_build]
}

env.hostnames = {
    'all': ['a4s16','a4s17','a4s18', 'a4s19']
}

env.passwords = {
    controller: 'c0ntrail123',
    compute1: 'c0ntrail123',
    compute2: 'c0ntrail123',
    compute3: 'c0ntrail123',
    host_build: 'c0ntrail123',
}

env.kernel_upgrade=False

env.openstack = {
    'manage_amqp': "true"
}

env.keystone = {
     'admin_password': 'c0ntrail123'
}
