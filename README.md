This repo is designed to create a Talos cluster using a Turing Pi setup with RK1s.

```
Talos/
├── README.md
├── gen-configs.sh
├── create-registry.sh
├── Patches/
│   └── Tmpl/
│       ├── airgap.yaml
│       ├── control-plane.yaml
│       └── worker.yaml
└── Manifests/
    ├── Core/
    │   ├── MetalLB/
    │   │   ├── manifest.yaml
    │   │   └── config.yaml
    │   ├── Nginx-Ingress
    │   ├── Cert-Manager
    │   ├── Longhorn/
    │   │   ├── manifest.yaml
    │   │   └── config.yaml
    │   └── Fleet/
    │       ├── manifest.yaml
    │       └── config.yaml
    ├── Media/
    │   ├── {Rad,Son,Wiz,Jellysee}arr
    │   ├── Plex / Jellyfin
    │   └── Usenet
    └── Cloud/
        ├── Nextcloud (Filestash w/ NFS) / Immich
        ├── Vault
        ├── Git
        ├── Bin
        ├── Infisical?
        └── DNS (HA)

k create deploy <name> --image=<image> --port <port> --namespace <namespace> --dry-run -o yaml > manifests/<name>/deployment.yaml

k create service clusterip <name> -n <namespace> --tcp=5678:8080 --dry-run -o yaml > manifests/<name>/service.yaml
```
### Helm vs Kustomize

Helm allows for templating, Kustomize is more for "patching" similar creations (like prod / dev environments)

I can use Helm to auto-template things like an ingress endpoint name for services based off the service name. But is this ~~neccessary~~ worthwhile? I could simply pin those values because the service name is often not used for exposure.

BUT I could use Kustomize for the _similar_ services like Radarr and Sonarr, though, those may be the only two...

### Todos

- [ ] Ingress for local only services
    - Internal DNS
    - Public DNS but only accessible from internal
- [ ] Create / get manifests for services
    - Deployments
    - Services / Ingress
    - Configmaps
    - Secrets
    - PV/Cs
      - Storage used for AppData
        - Nextcloud / Immich and Vaultwarden data is the biggest concern
      - Longhorn S3 backup to BackBlaze
- [ ] ~~RK1 hardware transcoding for Plex~~
- [ ] KubeVirt
- [ ] Rebuild using repo
- [ ] Automate (Fleet)
- [ ] Migrate