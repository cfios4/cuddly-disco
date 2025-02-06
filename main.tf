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

  cpu {
    cores = 2
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }
  
  cdrom {
    enabled   = true
    file_id   = "local:iso/talos-nocloud-amd64.iso"
    interface = "ide2"
  }

  disk {
    interface = "scsi0"
    size = 16
    file_format = "raw"
  }

  network_device {
    bridge = "vmbr0"
    firewall = true
    model = "virtio"
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