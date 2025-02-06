output "control_plane_ips" {
  description = "IP addresses of the control plane nodes"
  value       = element(compact(flatten([for ip_list in proxmox_virtual_environment_vm.control_plane[*].ipv4_addresses : ip_list])), 1)
}

output "worker_ips" {
  description = "IP addresses of the worker nodes"
  value       = element(compact(flatten([for ip_list in proxmox_virtual_environment_vm.worker[*].ipv4_addresses : ip_list])), 1)
}

output "all_node_ips" {
  description = "All node IP addresses"
  value       = concat(
    element(compact(flatten([for ip_list in proxmox_virtual_environment_vm.control_plane[*].ipv4_addresses : ip_list])), 1),
    element(compact(flatten([for ip_list in proxmox_virtual_environment_vm.worker[*].ipv4_addresses : ip_list])), 1)
  )
}