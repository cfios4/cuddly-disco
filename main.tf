terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  endpoint = "${var.endpoint}"
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