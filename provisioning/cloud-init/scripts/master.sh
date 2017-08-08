#!/bin/sh

#Set SSH password, keyless SSH, stat hosts & install base packages

set -eux

echo "root:$root_password" | chpasswd
sed -i -e 's/#PermitRootLogin yes/PermitRootLogin yes/g' -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service sshd restart

yum install epel-release -y && yum clean expire-cache
yum install -y "@Development Tools" python2-pip openssl-devel python-devel wget git vim -y
pip install -Iv ansible==2.2.0.0
echo "$master_ip  $master_hostname" >> /etc/hosts
echo "$slave_ip  $slave_hostname" >> /etc/hosts
echo "$contrail_cfgm_ip  $contrail_node_hostname" >> /etc/hosts
echo "nameserver $external_dns_server" >> /etc/resolv.conf

ssh-keygen -t rsa -C "" -P "" -f "/root/.ssh/id_rsa" -q
sshpass -p "$root_password" ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub root@$master_hostname
sshpass -p "$root_password" ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub root@$slave_hostname
sshpass -p "$root_password" ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub root@$contrail_node_hostname

#Get Contrail-Ansible

cd /root
wget http://10.84.5.120/github-build/R4.0/20/ubuntu-14-04/mitaka/artifacts_extra/contrail-ansible-4.0.0.0-20.tar.gz

mkdir contrail-ansible && cd contrail-ansible
cp /root/contrail-ansible-4.0.0.0-20.tar.gz . && tar -xvzf contrail-ansible-4.0.0.0-20.tar.gz
cd /root/contrail-ansible/playbooks
> /root/contrail-ansible/playbooks/inventory/my-inventory/hosts
> /root/contrail-ansible/playbooks/inventory/my-inventory/group_vars/all.yml

#Populate hosts file

cat << 'EOF' >> /root/contrail-ansible/playbooks/inventory/my-inventory/hosts
# Kubernetes Master-Node
[contrail-repo]
$master_ip

# Contrail-Cloud Controller
[kubernetes-contrail-controllers]
$contrail_cfgm_ip

# Contrail-Cloud Analytics
[kubernetes-contrail-analytics]
$contrail_analytics_ip

# Kubernetes Master-Node
[contrail-kubernetes]
$master_ip

# Kubernetes Slave-Node
[contrail-compute]
$slave_ip
EOF

vrouter_physical_interface=$(route | grep '^default' | grep -o '[^ ]*$')

#Populate inventory file

cat << 'EOF' >> /root/contrail-ansible/playbooks/inventory/my-inventory/group_vars/all.yml
docker_registry: $docker_registry:5000
docker_registry_insecure: True
docker_install_method: package
docker_py_pkg_install_method: pip
ansible_user: root
ansible_become: true
contrail_compute_mode: container
os_release: $container_os
contrail_version: $contrail_version
cloud_orchestrator: $container_orchestrator
webui_config: {http_listen_port: 8085}
keystone_config: {ip: $openstack_keystone_ip, admin_password: $openstack_admin_password, admin_user: admin, admin_tenant: admin}
nested_cluster_private_network: "10.10.10.0/24"
kubernetes_cluster_name: nested-k8
nested_cluster_network: {domain: $openstack_domain, project: $openstack_project, name: $openstack_public_network}
nested_mode: true
kubernetes_api_server: $master_ip
EOF

echo "vrouter_physical_interface: $(route | grep '^default' | grep -o '[^ ]*$')" >> /root/contrail-ansible/playbooks/inventory/my-inventory/group_vars/all.yml 

#Populate k8s repo

cat << 'EOF' >> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#Install Kubernetes

setenforce 0
yum install -y kubelet kubeadm
systemctl enable kubelet && systemctl start kubelet
#kubeadm init
