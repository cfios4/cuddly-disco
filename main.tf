terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
    }
  }
}


provider "proxmox" {
  endpoint = "${var.pm_api_url}"
  api_token = "${var.api_id}=${var.api_secret}"

  insecure = true
}


resource "proxmox_vm_qemu" "create-talos" {
  name        = "talos-${var.seq}"
  node_name = "prox"
  
  clone {
    vm_id = "107"
  }
  
}