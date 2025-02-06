output "control_plane_ips" {
  description = "IP addresses of the control plane nodes"
  value       = [
    compact(
      flatten(
        [
          for ip_list in proxmox_virtual_environment_vm.control_plane[*].ipv4_addresses : [for ip in ip_list : ip if ip != "127.0.0.1"]
        ]
      )
    )
  ]
}

output "worker_ips" {
  description = "IP addresses of the worker nodes"
  value       = compact(flatten([for ip_list in proxmox_virtual_environment_vm.worker[*].ipv4_addresses : ip_list]))
}

output "all_node_ips" {
  description = "All node IP addresses"
  value       = [
    compact(flatten([for ip_list in proxmox_virtual_environment_vm.control_plane[*].ipv4_addresses : ip_list])),
    compact(flatten([for ip_list in proxmox_virtual_environment_vm.worker[*].ipv4_addresses : ip_list]))
  ]
}