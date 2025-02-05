#!/bin/bash
set -x

curl -o /usr/local/bin/talosctl -L $(curl -s https://api.github.com/repos/siderolabs/talos/releases/latest | grep "browser_download_url.*linux-amd64" | cut -d '"' -f 4)
chmod +x /usr/local/bin/talosctl

talosctl gen config t3s https://${CNODES[0]} --install-image factory.talos.dev/installer/6bd594353a7860f79cc0910931af93ffd6890ef32aaa01db81eb90c1de2e55e6:v1.9.3 --config-patch-control-plane '{"cluster": {"allowSchedulingOnControlPlanes": true}}'

for controller in ${CNODES[@]} ; do
    talosctl apply-config -f controlplane.yaml -n $controller -e $controller --insecure
done

for worker in ${WNODES[@]} ; do
    talosctl apply-config -f worker.yaml -n $worker -e $worker --insecure
done

until talosctl bootstrap -n ${CNODES[0]} -e ${CNODES[0]} --talosconfig ./talosconfig ; do
    echo "Node rebooting..."
    sleep 2
done

talosctl kubeconfig -n ${CNODES[0]} -e ${CNODES[0]} --talosconfig ./talosconfig

# cat ./.kube/config ; echo "----------------------------" ; cat ./talosconfig