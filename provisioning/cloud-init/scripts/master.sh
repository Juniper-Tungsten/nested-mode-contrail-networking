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

cd /root
wget http://10.84.5.120/github-build/R4.0/20/ubuntu-14-04/mitaka/artifacts_extra/contrail-ansible-4.0.0.0-20.tar.gz

mkdir contrail-ansible && cd contrail-ansible
cp /root/contrail-ansible-4.0.0.0-20.tar.gz . && tar -xvzf contrail-ansible-4.0.0.0-20.tar.gz
cd /root/contrail-ansible/playbooks
> /root/contrail-ansible/playbooks/inventory/my-inventory/hosts
> /root/contrail-ansible/playbooks/inventory/my-inventory/group_vars/all.yml

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
