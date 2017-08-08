# Nested Mode (Contrail Networking)

## Overview

* Run Kubernetes/OpenShift container orchestration platforms on OpenStack
* One SDN controller to manage Container/VM/BareMetal workloads
* Simplified install through Heat orchestration engine

## Architecture

![Architecture](https://github.com/savithruml/nested-mode-contrail-networking/blob/master/screenshots/nested-k8s-contrail.png)

## Getting started

### Pre-requisites

* [Contrail-Cloud 4.X](https://www.juniper.net/support/downloads/?p=contrail#sw)

* [CentOS 7.3 Minimal with Kernel-Devel/Headers](http://10.84.5.120/cs-shared//images/centos-nested-image.img)

### Install

* Download the CentOS image & upload it to glance

      (openstack-controller)# wget http://10.84.5.120/cs-shared//images/centos-nested-image.img
      (openstack-controller)# glance image-create --name centos-nested-image --visibility=public --container-format ovf --disk-format qcow2 --file centos.img
      
* Clone this [repo](https://github.com/savithruml/nested-mode-contrail-networking)

      (openstack-controller)# git clone https://github.com/savithruml/nested-mode-contrail-networking

* Populate the environment file

      (openstack-controller)# vi /root/nested-mode-contrail-networking/provisioning/heat/k8s/deploy-nested-k8s.env
      
  Refer to [example-file](https://github.com/savithruml/nested-mode-contrail-networking/blob/master/examples/example-nested-k8s.env)
  
* Create the heat stack

      (openstack-controller)# cd nested-mode-contrail-networking/provisioning/heat/k8s
      (openstack-controller)# heat stack-create nested-k8s -f deploy-nested-k8s.yaml -e deploy-nested-k8s.env
      
* Monitor the status

      (openstack-controller)# heat stack-list
      (openstack-controller)# heat stack-show nested-k8s
  
  Login to nova-instances & tail on init logs for status
  
      (overcloud-nested-nodes)# tail -f /var/log/cloud-init-output.log -f /var/log/cloud-init.log -f /var/log/messages
      
      
