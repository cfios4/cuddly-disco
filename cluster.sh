#!/bin/bash

alias t=talosctl
curl -sL https://talos.dev/install | sh

t gen config t3s https://${CNODES[0]} --install-image factory.talos.dev/installer/6bd594353a7860f79cc0910931af93ffd6890ef32aaa01db81eb90c1de2e55e6:v1.9.3 --config-patch-control-plane '{"cluster": {"allowSchedulingOnControlPlanes": true}}'

for controller in ${CNODES[@]} ; do
    t apply-config -f controlplane.yaml -n $controller -e $controller --insecure
done

for worker in ${WNODES[@]} ; do
    t apply-config -f worker.yaml -n $worker -e $worker --insecure
done

until t bootstrap -n ${CNODES[0]} -e ${CNODES[0]} --talosconfig ./talosconfig ; do
    echo "Node rebooting..."
    sleep 2
done

t kubeconfig -n ${CNODES[0]} -e ${CNODES[0]} --talosconfig ./talosconfig

# cat ./.kube/config ; echo "----------------------------" ; cat ./talosconfig