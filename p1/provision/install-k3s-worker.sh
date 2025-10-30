#!/bin/sh
set -eux

echo "[INFO] Installing K3s (worker)..."
#apk add --no-cache curl

# Wait for server token to exist
while [ ! -f /vagrant/node-token ]; do
	echo "Waiting for K3s token from server..."
	sleep 3
done

K3S_TOKEN=$(cat /vagrant/node-token)
K3S_URL="https://192.168.56.110:6443"

# Install K3s agent
curl -sfL https://get.k3s.io | K3S_URL="$K3S_URL" K3S_TOKEN="$K3S_TOKEN" sh -

echo "[INFO] K3s worker joined cluster succesfully!"
