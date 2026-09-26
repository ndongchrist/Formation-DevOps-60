#!/bin/bash
set -euo pipefail

# Change directory to example
cd ../../production

# Create the resources
terraform init
terraform apply -auto-approve -var dbpassword=123456

# Wait while the instance boots up
# (Could also use a provisioner in the TF config to do this)
sleep 60 

# Query the output, extract the IP and make a request
terraform output -json |\
jq -r '.instance_ip_addr.value' |\
xargs -I {} curl http://{}:8080 -m 10

# If request succeeds, destroy the resources
terraform destroy -auto-approve