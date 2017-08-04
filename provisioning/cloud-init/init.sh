# INIT SCRIPT 

# Author: SAVITHRU LOKANATH
# Contact: SAVITHRU AT JUNIPER.NET
# Copyright (c) 2017 Juniper Networks, Inc. All rights reserved.

sudo yum install epel-release vim NetworkManager -y
sudo touch /tmp/hello-world
sudo systemctl start NetworkManager && sudo systemctl enable NetworkManager
#sudo yum update -y
#sudo yum install ansible pyOpenSSL python-cryptography python-lxml git -y
