terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.
}

resource "proxmox_vm_qemu" "create-talos" {
  name        = "talos-${var.seq}"
  target_node = "prox"
  clone = "talos"
  vm_state = "running"
  
  ipconfig0 = '[gw=var.gw] [,ip=var.network]'
  skip_ipv6 = "true"
}