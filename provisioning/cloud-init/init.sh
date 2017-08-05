#!/bin/sh

set -eux

echo "root:$root_password" | chpasswd

yum install epel-release -y && yum update -y
yum install sshpass git vim NetworkManager -y >> /var/log/contrail-installer.log
systemctl start NetworkManager && systemctl enable NetworkManager >> /var/log/contrail-installer.log
echo "$master_ip  $master_hostname" >> /etc/hosts
echo "$slave_ip  $slave_hostname" >> /etc/hosts

ssh-keygen -t rsa -C "" -P "" -f "/root/.ssh/id_rsa" -q
sshpass -p "$root_password" ssh-copy-id -o StrictHostKeyChecking=no root@nested-master
sshpass -p "$root_password" ssh-copy-id -o StrictHostKeyChecking=no root@nested-slave
