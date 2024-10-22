ADD NOTES HERE

```
#!/bin/bash

TALOS_NODES(192.168.x.1 192.168.x.2 192.168.x.3 192.168.x.4)

for node in 1 2 3 4 ; do tpi --host turingpi.lan --user <turing-user> --password <turing-pass> flash --image-path talos-arm64-turing-rk1_v1.6.3.raw -n $node ; done
tpi --host turingpi.lan --user <turing-user> --password <turing-pass> power on

talosctl gen config turing https://${TALOS_NODES[1]}:6443 --install-disk /dev/mmcblk0
for node in ${TALOS_NODES[@]} ; do talosctl apply-config -f controlplane.yaml -n ${TALOS_NODES[@]} -e ${TALOS_NODES[@]} --insecure ; done

talosctl kubeconfig -n ${TALOS_NODES[0]}

kubectl get nodes

<!-- talosctl dashboard -n ${TALOS_NODES[@]} -->
<!-- talosctl reset -n ${TALOS_NODES[@]} -->
```