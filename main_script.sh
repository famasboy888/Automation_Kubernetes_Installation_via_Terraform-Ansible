#!/bin/bash

######################################
# Author: Kyle Yap
# Description: Automate Kubernetes
# deployment using Terraform+Ansible
# Date: March 30, 2024
#####################################

# Run Terraform and deploy instances

terraform -chdir=terraform/ init
terraform -chdir=terraform/ plan
terraform -chdir=terraform/ apply -auto-approve

# Get generated inventory file
cp terraform/output/inventory ansible/inventory
echo "Done copying Inventory file"

echo "Waiting for instances to be online"
sleep 15

echo "Executing ansible"
cd ansible/
ansible-playbook automate.yaml
cd ..

echo "Modifying Join token"
sed -e 's/$/ --cri-socket \/run\/cri-dockerd.sock/g' ansible/roles/worker/files/join_kube.sh | tee ansible/roles/worker/files/join_kube_1.sh
sed -e 's/^/sudo /g' ansible/roles/worker/files/join_kube_1.sh | tee ansible/roles/worker/files/join_kube_2.sh

echo "Executing ansible for WORKER NODE"
cd ansible/
ansible-playbook automate_part_2.yaml
cd ..

echo "Executed successfully!"

