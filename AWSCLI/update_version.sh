#!/bin/bash
#Getting information
echo "Please enter cluster name: "
read cluster
echo "Please enter Node group name: "
read node_group
echo "Please enter region name: "
read region
echo "Please enter EKS desired version: "
read version
# Updating control plane
aws eks update-cluster-version --name $cluster --region $region --kubernetes-version $version
# Fetch the status of the control plane
status=$(aws eks describe-cluster --name $cluster --region $region --query "cluster.status" --output text)

# Loop until the status is no longer "UPDATING"
while [[ "$status" == "UPDATING" ]]; do
    echo "Control plane is still updating..."
    sleep 5
    status=$(aws eks describe-cluster --name $cluster --region $region --query "cluster.status" --output text)
done

echo "Control plane update completed with status: $status"

aws eks update-nodegroup-version --cluster-name $cluster --region $region --nodegroup-name $node_group --kubernetes-version $version

# Fetch the status of the nodegroup
status=$(aws eks describe-nodegroup --cluster-name $cluster --region $region --nodegroup-name $node_group --query "nodegroup.status" --output text)

# Loop until the status is no longer "UPDATING"
while [[ "$status" == "UPDATING" ]]; do
    echo "Nodegroup is still updating..."
    sleep 5
    status=$(aws eks describe-nodegroup --cluster-name $cluster --region $region --nodegroup-name $nodegroup --query "nodegroup.status" --output text)
done

echo "Nodegroup update completed with status: $status"

echo "Full update is done to $version"
