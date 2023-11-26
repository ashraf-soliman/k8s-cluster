#!/bin/bash

echo "create ansible user script"

useradd ansible
echo "1234" | passwd --stdin ansible
sudo sh -c "echo 'ansible        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers.d/ansible"

sudo yum install python3* -y