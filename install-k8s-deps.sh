#!/bin/bash
# =====================================================================
# Debian 13 - Virtualization + Kubernetes Dependencies Setup Script
# Installs QEMU, libvirt, Vagrant, and core Kubernetes dependencies.
# Designed for nested virtualization inside a Debian VM.
# =====================================================================

set -e

GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

echo -e "${GREEN}[*] Updating system and installing prerequisites...${RESET}"
sudo apt update -y && sudo apt upgrade -y

# -------------------------------------------------------------------
# 1. Install QEMU, libvirt, and virtualization tooling
# -------------------------------------------------------------------
echo -e "${GREEN}[*] Installing QEMU, libvirt, and dependencies...${RESET}"
sudo apt install -y \
    qemu-kvm \
    qemu-utils \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virt-manager \
    dnsmasq-base \
    ebtables \
    libosinfo-bin \
    qemu-system-x86 \
    virtinst \
    vagrant-libvirt

# Add current user to libvirt and kvm groups for non-root access
echo -e "${GREEN}[*] Adding $(whoami) to libvirt and kvm groups...${RESET}"
sudo usermod -aG libvirt "$(whoami)"
sudo usermod -aG kvm "$(whoami)"

# Enable and start libvirt service
echo -e "${GREEN}[*] Enabling and starting libvirt service...${RESET}"
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# -------------------------------------------------------------------
# 2. Install Vagrant and plugins
# -------------------------------------------------------------------
echo -e "${GREEN}[*] Installing Vagrant...${RESET}"
sudo apt install -y vagrant

# Recommended plugins for libvirt provider
echo -e "${GREEN}[*] Installing useful Vagrant plugins...${RESET}"
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-reload
vagrant plugin install vagrant-disksize

# -------------------------------------------------------------------
# 3. Install Kubernetes CLI tools (kubectl, kubeadm, kubelet)
# -------------------------------------------------------------------
echo -e "${GREEN}[*] Installing Kubernetes CLI tools (kubectl, kubeadm, kubelet)...${RESET}"

# Add Kubernetes APT repo
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# -------------------------------------------------------------------
# 4. Install container runtime (containerd)
# -------------------------------------------------------------------
echo -e "${GREEN}[*] Installing containerd runtime...${RESET}"
sudo apt install -y containerd

# Default containerd configuration
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null

# Make containerd use systemd cgroup driver (Kubernetes requirement)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl enable containerd
sudo systemctl restart containerd

# -------------------------------------------------------------------
# 5. Enable kernel modules for Kubernetes and networking
# -------------------------------------------------------------------
echo -e "${GREEN}[*] Enabling kernel modules and sysctl settings...${RESET}"

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# -------------------------------------------------------------------
# 6. Optional utilities for virtualization and networking diagnostics
# -------------------------------------------------------------------
echo -e "${GREEN}[*] Installing optional utilities (virt tools, net tools)...${RESET}"
sudo apt install -y virt-top virt-viewer nmap tcpdump iproute2 iputils-ping

# -------------------------------------------------------------------
# Final message
# -------------------------------------------------------------------
echo -e "${GREEN}=====================================================================${RESET}"
echo -e "${GREEN}[*] Virtualization + Kubernetes dependencies successfully installed.${RESET}"
echo -e "${YELLOW}[*] IMPORTANT: Log out and log back in (or reboot) for group changes to take effect.${RESET}"
echo -e "${GREEN}=====================================================================${RESET}"

