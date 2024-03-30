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
terraform -chdir=terraform/ destroy -auto-approve
