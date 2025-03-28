This repo is designed to create a Talos cluster using a Turing Pi setup with RK1s.

```
Talos/
├── gen-configs.sh
├── create-registry.sh
├── Patches/
│   └── Tmpl/
│       ├── airgap.yaml
│       ├── control-plane.yaml
│       └── worker.yaml
├── Helm/
│   ├── Fleet
│   ├── Nginx-Ingress
│   ├── Cert-Manager
│   ├── Longhorn
│   └── Kube-Vip / MetalLB
└── Manifests/
    ├── Media/
    │   ├── {Rad,Son,Wiz,Request}arr
    │   ├── Plex / Jellyfin
    │   └── Usenet
    └── Cloud/
        ├── Nextcloud
        ├── Git
        ├── Bin
        ├── Vault
        └── VPN infrastructure?
```


Usage:
1. Head to Semaphore and run the task
2. Enter the desired cluster size
  1. Math will be applied to make the cluster HA
3. Enter your key from `https://wush.dev/receive#`
4. Build
5. When build is complete, a file should be downloaded in your `wush` tab


To change environments, be sure to update the variable groups in Semaphore

Required Variables:
- endpoint
  - Proxmox endpoint
  - <example>
- api_id
  - Proxmox API
- api_secret
  - Proxmox API
- total_nodes
  - Cluster size
- WUSH_AUTH_KEY
  - From https://wush.dev/receive#

```bash
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