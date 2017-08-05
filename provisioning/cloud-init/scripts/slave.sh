#!/bin/sh

set -eux

echo "root:$root_password" | chpasswd

yum install epel-release -y && yum update -y
yum install wget git vim NetworkManager -y
systemctl start NetworkManager && systemctl enable NetworkManager
echo "$master_ip  $master_hostname" >> /etc/hosts
echo "$slave_ip  $slave_hostname" >> /etc/hosts
