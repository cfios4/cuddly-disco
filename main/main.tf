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

locals {
  control_plane_nodes = (var.total_nodes / 2) + 1
  worker_nodes        = var.total_nodes - local.control_plane_nodes
}

resource "proxmox_virtual_environment_vm" "control_plane" {
  count = local.control_plane_nodes
  name        = "talos-control-${count.index + 1}"
  node_name = "prox"
  
  clone {
    vm_id = "107"
  }

}

resource "proxmox_virtual_environment_vm" "worker" {
  count = local.worker_nodes
  name        = "talos-worker-${count.index + 1}"
  node_name = "prox"
  
  clone {
    vm_id = "107"
  }

}