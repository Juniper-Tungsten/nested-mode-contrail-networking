# Nested Mode (Contrail Networking)

## Overview

* Run Kubernetes/OpenShift container orchestration platforms on OpenStack
* One SDN controller to manage Container/VM/BareMetal workloads
* Simplified install through Heat orchestration engine

## Architecture

![Architecture](screenshots/nested-k8s-contrail.png)

## Getting started

### Prerequisites

* [Contrail-Cloud 4.X](https://www.juniper.net/support/downloads/?p=contrail#sw)

* [Contrail-Server-Manager](https://www.juniper.net/support/downloads/?p=contrail#sw)

* [CentOS-7.3-minimal with kernel-devel/headers](http://10.84.5.120/cs-shared//images/centos-nested-image.img)

* TWO x86 servers

      CPUs:     32 (2 threads/core)
      RAM:      > 64 GB
      DISK:     > 500 GB

* Gateway (Juniper MX)


### Install

#### CONTRAIL CLOUD

* Install Contrail-Cloud (Liberty/Mitaka/Newton) using Contrail-Server-Manager

      (openstack-controller)# > /etc/apt/sources.list
      (openstack-controller)# dpkg –i <contrail-server-manager-installer_4.0.0.0-<build-number><sku>_all.deb>
      
* Populate the testbed. Refer to [example-file](https://github.com/savithruml/nested-mode-contrail-networking/tree/master/examples/testbed.py) & provision the cluster

      (openstack-controller)# /opt/contrail/contrail_server_manager/provision_containers.sh -t <testbed.py path> -c <contrail-cloud-docker.tgz> --cluster-id <user-defined-cluster-name> -d <domain-name> --no-sm-webui
      
* Monitor status

      (openstack-controller)# /opt/contrail/contrail_server_manager/provision_status.sh
      
* After provision completes, check if all services are up & running

      (all-nodes)# contrail-status

#### NESTED KUBERNETES      

* Download the CentOS image & upload it to glance

      (openstack-controller)# wget http://10.84.5.120/cs-shared//images/centos-nested-image.img
      (openstack-controller)# glance image-create --name centos-nested-image --visibility=public --container-format ovf --disk-format qcow2 --file centos-nested-image.img
      
* Clone this [repo](https://github.com/savithruml/nested-mode-contrail-networking)

      (openstack-controller)# git clone https://github.com/savithruml/nested-mode-contrail-networking

* Populate the environment file

      (openstack-controller)# vi /root/nested-mode-contrail-networking/provisioning/heat/deploy-nested.env
      
  Refer to [example-file](https://github.com/savithruml/nested-mode-contrail-networking/blob/master/examples/example-nested-k8s.env)
  
* Create the heat stack

      (openstack-controller)# cd nested-mode-contrail-networking/provisioning/heat/
      (openstack-controller)# heat stack-create nested -f deploy-nested.yaml -e deploy-nested.env
      
* Monitor the status

      (openstack-controller)# heat stack-list
      (openstack-controller)# heat stack-show nested
  
  Login to nova-instances & tail on init logs for status
  
      (overcloud-nested-nodes)# tail -f /var/log/cloud-init-output.log -f /var/log/cloud-init.log -f /var/log/messages
      
## Contributors
  
* Savithru Lokanath
