output "control_plane_ips" {
  description = "IP addresses of the control plane nodes"
  value       = [for i in range(local.control_plane_nodes) : proxmox_vm_qemu.control_plane[i].ipconfig0]
}

output "worker_ips" {
  description = "IP addresses of the worker nodes"
  value       = [for i in range(local.worker_nodes) : proxmox_vm_qemu.worker[i].ipconfig0]
}

output "all_node_ips" {
  description = "All node IP addresses"
  value       = concat(
    [for i in range(local.control_plane_nodes) : proxmox_vm_qemu.control_plane[i].ipconfig0],
    [for i in range(local.worker_nodes) : proxmox_vm_qemu.worker[i].ipconfig0]
  )
}