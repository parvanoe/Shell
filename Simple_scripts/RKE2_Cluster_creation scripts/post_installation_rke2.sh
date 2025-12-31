#!/bin/bash

kube_node_type={kube_node_type}
main_master={main_master}
kube_version={kube_version}

config_file={config_file}

#Prerequisites
#kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
#Download RKE2 installer
curl -sfL https://get.rke2.io --output install.sh

if [[ -z $kube_version ]]; then
  kube_version="latest"
fi

if [[ -z $config_file ]]; then
  config_file="/etc/rancher/rke2/config.yaml"
fi

chmod +x install.sh
#Checking fro which role needs to be run
if [ "$kube_node_type" = "Master" ]; then
    #Run RKE2 installation
    INSTALL_RKE2_CHANNEL=v$kube_version ./install.sh
    #Enable system service
    systemctl enable rke2-server.service

    if [ "$main_master" = "1" ]; then
      #Start service
      systemctl start rke2-server.service
      #Log files for errors
      LOGFILE="rke2-errors.log"
      journalctl -u rke2-server | grep -i "error" > "$LOGFILE"
      #Check if the service is active for rke2-server
      if systemctl is-failed --quiet rke2-server.service; then
          echo "rke2-server.service is not active. Exiting."
          exit 1
      fi
      systemctl stop rke2-server.service
      mkdir -p "$(dirname "$config_file")"
      cp {host_tmp_path}/config_main_master.yaml $config_file
      token=$(cat /var/lib/rancher/rke2/server/node-token)
      sed -i "s/{token}/$token/g" $config_file
      systemctl start rke2-server.service
    else
      mkdir -p "$(dirname "$config_file")"
      cp {host_tmp_path}/config_master.yaml $config_file
      #Start service
      systemctl start rke2-server.service
      #Log files for errors
      LOGFILE="rke2-errors.log"
      journalctl -u rke2-server | grep -i "error" > "$LOGFILE"
      #Check if the service is active for rke2-server
      if systemctl is-failed --quiet rke2-server.service; then
          echo "rke2-server.service is not active. Exiting."
          exit 1
      fi
    fi
    #Use kubectl on the master node
    mkdir ~/.kube && sudo cp /etc/rancher/rke2/rke2.yaml ~/.kube/config
elif [ "$kube_node_type" = "Worker" ]; then
    #Run RKE2 installation
    INSTALL_RKE2_CHANNEL=v$kube_version INSTALL_RKE2_TYPE="agent" ./install.sh
    #Enable system service
    systemctl enable rke2-agent.service
    mkdir -p "$(dirname "$config_file")"
    cp {host_tmp_path}/config_worker.yaml $config_file
    #Start service
    systemctl start rke2-agent.service
    #Log files for errors
    LOGFILE="rke2-errors.log"
    journalctl -u rke2-agent | grep -i "error" > "$LOGFILE"
    #Check if the service is active for rke2-agent
    if systemctl is-failed --quiet rke2-agent.service; then
        echo "rke2-agent.service is not active. Exiting."
        exit 1
    fi
fi
#Final clean up
rm install.sh
rm get_helm.sh
