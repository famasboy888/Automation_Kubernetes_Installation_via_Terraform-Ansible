#!/bin/bash

######################################
# Author: Kyle Yap
# Description: Automate Kubernetes
# deployment using Terraform+Ansible
# Date: March 30, 2024
#####################################

# Global Vars
var_ret_err=false


#############################################################################
# Function Declarations
check_connection(){

max_attempts=25

attempt_num=1

success=false

        while [ $success = false ] && [ $attempt_num -le $max_attempts ]; do
                ping -c1 $1 > /dev/null && success=true
                echo "Attempting to connect to ("$1")..................Retry("$attempt_num")"
                attempt_num=$(( attempt_num + 1 ))
        done

        if [ $success = true ]; then
                echo "Connection to "$1" was successfull."
        else
                echo "The connection failed after maximum "$max_attempts" attempts."
                return true
        fi
}

###############################################################################
# Steps
# Run Terraform and deploy instances

terraform -chdir=terraform/ init
terraform -chdir=terraform/ plan
terraform -chdir=terraform/ apply -auto-approve

# Get generated inventory file
cp terraform/output/inventory ansible/inventory
echo "Done copying Inventory file"

# Wait for connection to come online
echo "Waiting for instances to be online"
#cat ansible/inventory | while read ip; do
#        if [[ ! $ip =~ ^\[ ]] && [ ! $ip = "" ]; then
#                check_connection $ip
#        fi
#done

if [ $var_ret_err == false ]; then

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
fi
