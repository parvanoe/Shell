#!/bin/bash

# Fetch the status of the nodegroup
status=$(aws eks describe-nodegroup --cluster-name <clustername> --region <region> --nodegroup-name <nodegroup> --query "nodegroup.status" --output text)

# Loop until the status is no longer "UPDATING"
while [[ "$status" == "UPDATING" ]]; do
    echo "Nodegroup is still updating..."
    sleep 5
    status=$(aws eks describe-nodegroup --cluster-name EKS-SOF-01-test --region eu-central-1 --nodegroup-name EKS-SOF-01-Nodegroup --query "nodegroup.status" --output text)
done

echo "Nodegroup update completed with status: $status"
