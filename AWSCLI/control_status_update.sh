#!/bin/bash

# Fetch the status of the nodegroup
status=$(aws eks describe-cluster --name <cluster> --region <region> --query "cluster.status" --output text)

# Loop until the status is no longer "UPDATING"
while [[ "$status" == "UPDATING" ]]; do
    echo "Nodegroup is still updating..."
    sleep 5
    status=$(aws eks describe-cluster --name <cluster> --region <region> --query "cluster.status" --output text)
done

echo "Nodegroup update completed with status: $status"
