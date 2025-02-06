output "control_plane_ips" {
  description = "IP addresses of the control plane nodes"
  value       = compact(flatten([for ip in proxmox_virtual_environment_vm.control_plane[*].ipv4_addresses : ip]))
}

output "worker_ips" {
  description = "IP addresses of the worker nodes"
  value       = compact(flatten([for ip in proxmox_virtual_environment_vm.worker[*].ipv4_addresses : ip]))
}

output "all_node_ips" {
  description = "All node IP addresses"
  value       = [
    compact(flatten([for ip in proxmox_virtual_environment_vm.control_plane[*].ipv4_addresses : ip])),
    compact(flatten([for ip in proxmox_virtual_environment_vm.worker[*].ipv4_addresses : ip]))
  ]
}