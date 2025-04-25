# This repo is designed to create a Talos cluster ~~using a Turing Pi setup with RK1s~~ in a completely agnostic fashion. 
Maybe this should be converted into a generic repo for services and Talos creation in a seperate repo?


## Prerequisites:
- Airgap (optional)
  - Zarf (with PiHole package)
    - [x] Registry
    - [x] DNS
    - [x] NTP
    - [x] Images
- Cluster Plan (Talos)
  - Two disks installed per node
    - Install disk
    - Longhorn storage
  - Nodes built / in Talos maintenance mode
    - Control plane range
    - Worker range
    - Cluster API VIP
      - +1 of last Worker range
    - Cluster Service VIP
      - +2 of last Worker range

I would like better logic for the `Cluster Plan`
```
Talos/
├── README.md
├── gen-configs.sh
├── airgap.sh
└── patches/
    └── tmpl/
        ├── airgap.yaml
        ├── control-plane.yaml
        └── worker.yaml
Stack/
├── README.md
└── manifests/
    ├── core/
    │   ├── kube-vip/
    │   │   └── install.yaml
    │   ├── longhorn/
    │   │   ├── install.yaml
    │   │   └── pvc.yaml
    │   ├── nginx-ingress/
    │   │   └── install.yaml
    │   ├── cert-manager/
    │   └── fleet/
    ├── media/
    │   ├── {rad,son,wiz,oversee}arr/
    │   ├── plex/
    │   └── usenet/
    └── cloud/
        ├── nextcloud/
        ├── vault/
        ├── git/
        ├── gist/
        ├── pihole/
        └── kubevirt/

k create deploy <name> --image=<image> --port <port> --namespace <namespace> --dry-run -o yaml > manifests/<name>/deployment.yaml

k create service clusterip <name> -n <namespace> --tcp=5678:8080 --dry-run -o yaml > manifests/<name>/service.yaml
```
### Helm vs Kustomize

Helm allows for templating, Kustomize is more for "patching" similar creations (like prod / dev environments)

I can use Helm to auto-template things like an ingress endpoint name for services based off the service name. But is this ~~neccessary~~ worthwhile? Probably (definitely) worth learning.

BUT I could use Kustomize as a base and unique patches for services off of the base? Not saving much work if each service needs it though...

### Todos:

- [x] Create / get manifests for services
    - Deployments
    - Services
    - Ingress
    - Configmaps
    - Secrets
      -  SOPS
    - PV/Cs
      - Nextcloud / Immich and Vaultwarden data is the biggest concern
        - Seperate backup policies
      - Longhorn S3 backup to BackBlaze
      - Longhorn NFS backup to UNAS
- [x] Ingress for local only services
    - Public DNS but only accessible from internal?
      - `<hostname>.lan.<domain>`
- [ ] ~~RK1 hardware transcoding for Plex~~
- [ ] KubeVirt
- [x] Agnosticize 
- [ ] Rebuild using repo
- [ ] Automate (GitOps)
- [ ] Migrate