terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.
  pm_api_url = "${var.pm_api_url}"
  pm_api_token_id = "${var.pm_api_token_id}"
  pm_api_token_secret = "${var.pm_api_token_secret}"
}

resource "proxmox_vm_qemu" "create-talos" {
  name        = "talos-${var.seq}"
  target_node = "prox"
  clone = "talos"
}