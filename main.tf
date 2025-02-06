terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
    }
  }
}

provider "proxmox" {
  pm_api_url  = "${var.endpoint}"
  pm_api_token_id = "${var.api_id}"
  pm_api_token_secret = "${var.api_secret}"

  pm_tls_insecure = true
}

locals {
  control_plane_nodes = ceil(var.total_nodes / 2) + (var.total_nodes % 2 == 0 ? 1 : 0)
  worker_nodes        = var.total_nodes - local.control_plane_nodes
}

// resource "proxmox_virtual_environment_vm" "control_plane" {
//   count = local.control_plane_nodes
//   name        = "talos-control-${count.index + 1}"
//   node_name = "prox"

//   // agent {
//   //   enabled = true
//   // }
  
//   clone {
//     vm_id = "107"
//   }

// }

// resource "proxmox_virtual_environment_vm" "worker" {
//   count = local.worker_nodes
//   name        = "talos-worker-${count.index + 1}"
//   node_name = "prox"

//   // agent {
//   //   enabled = true
//   // }
  
//   clone {
//     vm_id = "107"
//   }

// }

// provisioner "file" {
//   source      = "./cluster.sh"
//   destination = "/tmp/cluster.sh"
// }

// provisioner "local-exec" {
//   command = "/bin/bash -c /tmp/cluster.sh"

//   environment = {
//     CNODES = ${output.control_plane_ips}
//     WNODES = ${output.worker_ips}
//   }
// }

resource "proxmox_vm_qemu" "control_plane" {
  count = local.control_plane_nodes
  name        = "talos-control-${count.index + 1}"
  target_node = "prox"

  clone_id = 107
}

resource "proxmox_vm_qemu" "worker" {
  count = local.worker_nodes
  name        = "talos-worker-${count.index + 1}"
  target_node = "prox"

  clone_id = 107
}