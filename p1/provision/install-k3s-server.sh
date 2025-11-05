#!/bin/sh
set -eux

echo "[INFO] Installing K3s (server)..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san 192.168.56.110 --node-ip 192.168.56.110 --node-external-ip 192.168.56.110 --disable traefik --disable metrics-server --disable local-storage --write-kubeconfig-mode 644" sh -

# Get join token for worker nodes
echo "[INFO] Saving K3s join token..."
sleep 20
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token

echo "[INFO] K3s server installed successully!"
kubectl get nodes || true
