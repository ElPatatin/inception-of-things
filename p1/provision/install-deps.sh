#!/bin/sh
set -eux

echo "[INFO] Updating Alpine and installing required packages.."
apk update
apk add --no-cache bash curl iptables iptables-openrc openrc eudev cgroup-tools #virtiofsd

echo "[INFO] Enabling cgroups..."
# Enable cgroups in boot configurration
if ! grep -q "cgroup_enable=cpuset" /etc/update-etxlinux.conf; then
	sed -i 's|^default_kernel_opts=.*|default_kernel_opts="cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1"|' /etc/update-extlinux.conf
	update-extlinux
fi

echo "[INFO] Enabling and starting required services..."
rc-update add cgroups default
rc-update add udev default
rc-update add udev-trigger default
rc-service cgroups start
rc-service udev start
rc-service udev-trigger start

echo "[INFO] Kernel modules setup..."
modprobe  br_netfilter || true
echo "br_netfilter" >> /etc/modules

echo "[INFO] Configuration sysctl for Kubernetes networking..."
cat <<EOF >> /etc/sysctl.conf

# Kubernetes networking
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p || true

echo "[INFO] Alpine is now ready for K3s installation!"
