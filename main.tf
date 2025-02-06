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
  control_plane_nodes = ceil(var.total_nodes / 2) + (var.total_nodes % 2 == 0 ? 1 : 0)
  worker_nodes        = var.total_nodes - local.control_plane_nodes
}

resource "proxmox_virtual_environment_vm" "control_plane" {
  count = local.control_plane_nodes
  name        = "talos-control-${count.index + 1}"
  node_name = "prox"

  agent {
    enabled = true
  }
  
  clone {
    vm_id = "107"
  }

}

resource "proxmox_virtual_environment_vm" "worker" {
  count = local.worker_nodes
  name        = "talos-worker-${count.index + 1}"
  node_name = "prox"

  agent {
    enabled = true
  }
  
  clone {
    vm_id = "107"
  }

}

resource "null_resource" "script" {
  provisioner "local-exec" {
    command = "/bin/bash -c 'curl https://git.cafio.co/casey/talos/raw/branch/main/cluster.sh | bash'"

    environment = {
      CNODES = join(" ", compact(flatten([for ip in proxmox_virtual_environment_vm.control_plane[*].ipv4_addresses : ip]))) 
      WNODES = join(" ", compact(flatten([for ip in proxmox_virtual_environment_vm.worker[*].ipv4_addresses : ip])))
      WUSH_AUTH_KEY = var.WUSH_AUTH_KEY
    }
  }
}