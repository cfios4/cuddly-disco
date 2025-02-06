#!/bin/bash
set -x

# Convert CNODES and WNODES into arrays from space-separated strings
IFS=' ' read -r -a CNODES <<< "$CNODES"
IFS=' ' read -r -a WNODES <<< "$WNODES"

# Function to filter out loopback addresses
filter_loopbacks() {
  local ip_list=("$@")
  local filtered_ips=()

  for ip in "${ip_list[@]}"; do
    if [[ "$ip" != "127.0.0.1" ]]; then
      filtered_ips+=("$ip")
    fi
  done

  echo "${filtered_ips[@]}"
}

# Filter out loopback IPs from CNODES and WNODES
CNODES=$(filter_loopbacks "${CNODES[@]}")
WNODES=$(filter_loopbacks "${WNODES[@]}")
IFS=' ' read -r -a CONTROL <<< "$CNODES"
IFS=' ' read -r -a WORK <<< "$WNODES"

echo "Downloading `talosctl` to /tmp..."
curl -o /tmp/talosctl -sL $(curl -s https://api.github.com/repos/siderolabs/talos/releases/latest | grep "browser_download_url.*linux-amd64" | cut -d '"' -f 4)
chmod +x /tmp/talosctl

echo "Creating Talos config files..."
rm ~/.kube/config *
/tmp/talosctl gen config t3s https://${CONTROL[0]} --install-image factory.talos.dev/installer/6bd594353a7860f79cc0910931af93ffd6890ef32aaa01db81eb90c1de2e55e6:v1.9.3 --config-patch-control-plane '{"cluster": {"allowSchedulingOnControlPlanes": true}}' --force

echo "Applying config to Control Planes..."
for controller in ${CONTROL[@]} ; do
    /tmp/talosctl apply-config -f controlplane.yaml -n $controller -e $controller --insecure
done

echo "Applying config to Workers..."
for worker in ${WORK[@]} ; do
    /tmp/talosctl apply-config -f worker.yaml -n $worker -e $worker --insecure
done

echo "Waiting for Control Plane..."
until /tmp/talosctl bootstrap -n ${CONTROL[0]} -e ${CONTROL[0]} --talosconfig ./talosconfig ; do
    echo "Node rebooting..."
    sleep 2
done

echo "Outputting Kubeconfig and Talosconfig..."
/tmp/talosctl kubeconfig -n ${CONTROL[0]} -e ${CONTROL[0]} --talosconfig ./talosconfig
(cat .kube/config ; echo "----------------------------" ; cat ./talosconfig) > /tmp/ktconfig

echo "Installing Bitwarden Client for Send..."
curl -sL "https://vault.bitwarden.com/download/?app=cli&platform=linux" | tar -xzvf - -C /tmp
chmod +x /tmp/bw

echo "Waiting to send..."
/tmp/bw config server "$VAULT_URL"
/tmp/bw send -f /tmp/ktconfig -d 1 -a 1