#!/bin/sh

set -eux

echo "root:$root_password" | chpasswd

yum install epel-release -y && yum clean expire-cache
yum install ansible pyOpenSSL python-cryptography python-lxml wget git vim NetworkManager -y
systemctl start NetworkManager && systemctl enable NetworkManager
echo "$master_ip  $master_hostname" >> /etc/hosts
echo "$slave_ip  $slave_hostname" >> /etc/hosts

ssh-keygen -t rsa -C "" -P "" -f "/root/.ssh/id_rsa" -q
sshpass -p "$root_password" ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub root@nested-master
sshpass -p "$root_password" ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub root@nested-slave

git clone https://github.com/savithruml/nested-k8s
wget http://10.84.5.120/github-build/R4.0/20/ubuntu-14-04/mitaka/artifacts_extra/contrail-ansible-4.0.0.0-20.tar.gz

mkdir contrail-ansible && cd contrail-ansible
cp /root/contrail-ansible-4.0.0.0-20.tar.gz . && tar -xvzf contrail-ansible-4.0.0.0-20.tar.gz
cd /root/contrail-ansible/playbooks
yes | cp /root/nested-k8s/contrail/all.yml inventory/my-inventory/group_vars
yes | cp /root/nested-k8s/contrail/hosts inventory/my-inventory
