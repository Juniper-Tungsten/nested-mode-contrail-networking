#!/bin/sh

#Set SSH password, keyless SSH, stat hosts & install base packages

set -eux

echo "root:$root_password" | chpasswd
sed -i -e 's/#PermitRootLogin yes/PermitRootLogin yes/g' -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service sshd restart

yum install epel-release -y && yum clean expire-cache 
yum install wget git vim -y
echo "$master_ip  $master_hostname" >> /etc/hosts
echo "$slave_ip  $slave_hostname" >> /etc/hosts
echo "nameserver $external_dns_server" >> /etc/resolv.conf

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

# Echo status

ERR=1
MAX_TRIES=10
COUNT=0
while [  $COUNT -lt $MAX_TRIES ]; do
   kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes | grep -w "Ready"
   if [ $? -eq 0 ];then
      echo "Sucess installing k8s" > /tmp/install-status
      exit 0
   fi
   let COUNT=COUNT+1
   sleep 2
done
echo "Too many non-successful tries" > /tmp/install-status
