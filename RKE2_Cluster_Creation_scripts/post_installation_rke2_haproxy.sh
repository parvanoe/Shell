#!/bin/bash

number_of_masters={number_of_masters}
node_names={node_names}
node_ips={node_ips}

#Installation of HAProxy for RKE2
sudo apt update
sudo apt upgrade -y
sudo apt install haproxy -y
#Adding cofiguration file for HAProxy
cat <<EOF | sudo tee -a /etc/haproxy/haproxy.cfg > /dev/null

frontend k8s_api_front
  mode tcp
  bind *:6443
  default_backend k8s_api_back

backend k8s_api_back
  mode tcp
  balance roundrobin
  option tcp-check
EOF
#Adding master nodes to HAProxy configuration
for i in {1..number_of_masters}; do
  echo "  server $node_names $node_ips:6443 check" | sudo tee -a /etc/haproxy/haproxy.cfg > /dev/null
done
# For this it should look like this
#  server kube3-dv-master-1 10.0.163.118:6443 check
#  server kube3-dv-master-2 10.0.163.119:6443 check
#  server kube3-dv-master-3 10.0.163.120:6443 check
#  server kube3-dv-master-4 10.0.163.130:6443 check
#  server kube3-dv-master-5 10.0.163.132:6443 check
#Starting HAProxy service
sudo systemctl enable haproxy
sudo systemctl start haproxy
#In all master nodes add interl and external IPs of haproxy
#tls-san:
#  - 10.0.163.118 # Internal IP of main master node
#  - 10.0.163.133 # Internal IP of HAProxy
#  - 79.124.42.117 # External IP of HAProxy
