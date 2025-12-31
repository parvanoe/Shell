# RKE2 Cluster Creation Scripts

Automated scripts for deploying and managing RKE2 (Rancher Kubernetes Engine 2) clusters.

## Overview

This repository contains shell scripts to simplify and automate the deployment of RKE2 Kubernetes clusters. RKE2, also known as RKE Government, is Rancher's next-generation Kubernetes distribution focused on security and compliance.

## Features

- 🚀 Automated cluster deployment
- 🔒 Security-focused configuration
- 🏗️ Support for both single-node and high-availability setups
- 📦 Modular and customizable scripts
- 🔧 Easy cluster management and operations

## Prerequisites

### System Requirements

- **OS**: Ubuntu 20.04/22.04, Rocky Linux 8/9, or RHEL 8/9
- **CPU**: 2+ cores (4+ recommended for control plane nodes)
- **RAM**: 4GB minimum (8GB+ recommended)
- **Disk**: 40GB+ available storage
- **Network**: Static IP addresses recommended

### Required Tools

- `bash` 4.0+
- `curl` or `wget`
- `ssh` access to target nodes (for multi-node deployments)
- Root or sudo privileges

## Quick Start

### Single Server Installation

```bash
# Clone the repository
git clone https://github.com/parvanoe/Shell.git
cd Shell/RKE2_Cluster_Creation_scripts

# Make scripts executable
chmod +x *.sh

# Run the server installation script
sudo ./install-rke2-server.sh
```

### High Availability Cluster

For HA deployments with multiple control plane nodes:

```bash
# On the first server node
sudo ./install-rke2-server.sh --ha --first-server

# On additional server nodes
sudo ./install-rke2-server.sh --ha --join-server <FIRST_SERVER_IP>

# On agent nodes
sudo ./install-rke2-agent.sh --server <SERVER_IP>
```

## Configuration

### Environment Variables

Configure your deployment by setting these environment variables:

```bash
# Server Configuration
export RKE2_VERSION="v1.28.5+rke2r1"        # RKE2 version to install
export RKE2_CHANNEL="stable"                # Release channel (stable, latest, testing)
export INSTALL_RKE2_TYPE="server"           # Installation type (server or agent)

# Network Configuration
export RKE2_TOKEN="my-secure-token"         # Cluster join token
export RKE2_SERVER="https://server-ip:9345" # Server URL for agents

# CNI Configuration
export RKE2_CNI="cilium"                    # CNI plugin (calico, cilium, canal)
```

### Config File

Alternatively, create a configuration file at `/etc/rancher/rke2/config.yaml`:

```yaml
# /etc/rancher/rke2/config.yaml
write-kubeconfig-mode: "0644"
tls-san:
  - "your-cluster.example.com"
  - "192.168.1.100"
node-label:
  - "node-type=server"
cluster-cidr: "10.42.0.0/16"
service-cidr: "10.43.0.0/16"
```

## Architecture

### Cluster Components

- **Control Plane Nodes** (Server): Run the Kubernetes control plane components
- **Worker Nodes** (Agent): Run application workloads
- **High Availability**: Requires odd number of server nodes (3, 5, 7)

### Network Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 6443 | TCP | Kubernetes API |
| 9345 | TCP | RKE2 supervisor API |
| 10250 | TCP | Kubelet metrics |
| 2379-2380 | TCP | etcd client/peer |
| 30000-32767 | TCP | NodePort Services |

## Usage Examples

### Deploy a 3-Node HA Cluster

```bash
# Server 1 (First control plane node)
./install-rke2-server.sh --ha --first-server

# Server 2 (Additional control plane)
./install-rke2-server.sh --ha --join-server 192.168.1.101

# Server 3 (Additional control plane)
./install-rke2-server.sh --ha --join-server 192.168.1.101

# Agent nodes
./install-rke2-agent.sh --server 192.168.1.101
```

### Add Worker Nodes

```bash
# Get the token from the server
sudo cat /var/lib/rancher/rke2/server/node-token

# On worker node
export RKE2_TOKEN="<token-from-server>"
export RKE2_URL="https://<server-ip>:9345"
./install-rke2-agent.sh
```

### Access the Cluster

```bash
# Set kubeconfig
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

# Add RKE2 binaries to PATH
export PATH=$PATH:/var/lib/rancher/rke2/bin

# Verify cluster
kubectl get nodes
kubectl cluster-info
```

## Cluster Operations

### Start/Stop Services

```bash
# Server node
sudo systemctl start rke2-server
sudo systemctl stop rke2-server
sudo systemctl restart rke2-server

# Agent node
sudo systemctl start rke2-agent
sudo systemctl stop rke2-agent
sudo systemctl restart rke2-agent
```

### View Logs

```bash
# Server logs
sudo journalctl -u rke2-server -f

# Agent logs
sudo journalctl -u rke2-agent -f
```

### Upgrade Cluster

```bash
# Update RKE2 version
export RKE2_VERSION="v1.29.0+rke2r1"
./upgrade-rke2.sh
```

## Troubleshooting

### Common Issues

**1. Node not joining cluster**
```bash
# Check server connectivity
curl -k https://<server-ip>:9345/ping

# Verify token
sudo cat /var/lib/rancher/rke2/server/node-token

# Check firewall rules
sudo firewall-cmd --list-all
```

**2. Pods not starting**
```bash
# Check CNI status
kubectl get pods -n kube-system

# Restart containerd
sudo systemctl restart rke2-server
```

**3. High memory usage**
```bash
# Check resource usage
kubectl top nodes
kubectl top pods -A

# Adjust reserved resources in config.yaml
```

### Debug Mode

Enable debug logging in `/etc/rancher/rke2/config.yaml`:

```yaml
debug: true
```

## Uninstall

```bash
# Uninstall RKE2 and remove all data
sudo ./uninstall-rke2.sh

# Or use the built-in uninstall script
sudo /usr/local/bin/rke2-uninstall.sh
```

**Warning**: This will delete all cluster data and configurations.

## Security Considerations

- 🔐 Use strong, unique tokens for cluster join operations
- 🔒 Enable SELinux or AppArmor for additional security
- 🛡️ Configure network policies for pod-to-pod communication
- 🔑 Regularly rotate certificates and credentials
- 📊 Enable audit logging for compliance
- 🚫 Restrict API server access with firewall rules

## Performance Tuning

### For Control Plane Nodes

```yaml
# /etc/rancher/rke2/config.yaml
kube-apiserver-arg:
  - "max-requests-inflight=400"
  - "max-mutating-requests-inflight=200"
etcd-arg:
  - "heartbeat-interval=250"
  - "election-timeout=2500"
```

### For Worker Nodes

```yaml
kubelet-arg:
  - "max-pods=110"
  - "kube-reserved=cpu=200m,memory=512Mi"
  - "system-reserved=cpu=200m,memory=512Mi"
```

## Directory Structure

```
RKE2_Cluster_Creation_scripts/
├── README.md
├── install-rke2-server.sh    # Server installation script
├── install-rke2-agent.sh     # Agent installation script
├── upgrade-rke2.sh           # Upgrade script
├── uninstall-rke2.sh         # Cleanup script
├── configs/
│   ├── server-config.yaml    # Sample server config
│   └── agent-config.yaml     # Sample agent config
└── utils/
    ├── check-prereqs.sh      # Prerequisites checker
    └── cluster-health.sh     # Health check script
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Resources

- [Official RKE2 Documentation](https://docs.rke2.io/)
- [RKE2 GitHub Repository](https://github.com/rancher/rke2)
- [Rancher Documentation](https://rancher.com/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**parvanoe**
- GitHub: [@parvanoe](https://github.com/parvanoe)

## Acknowledgments

- Rancher Labs for developing RKE2
- The Kubernetes community
- Contributors to this project

---

**Note**: Always test scripts in a non-production environment before deploying to production clusters.
