// output "control_plane_ips" {
//   description = "IP addresses of the control plane nodes"
//   value       = [for i in range(local.control_plane_nodes) : default_ipv4_address.control_plane[i].ipv4_addresses]
// }

// output "worker_ips" {
//   description = "IP addresses of the worker nodes"
//   value       = [for i in range(local.worker_nodes) : default_ipv4_address.worker[i].ipv4_addresses]
// }

// output "all_node_ips" {
//   description = "All node IP addresses"
//   value       = concat(
//     [for i in range(local.control_plane_nodes) : default_ipv4_address.control_plane[i].ipv4_addresses],
//     [for i in range(local.worker_nodes) : default_ipv4_address.worker[i].ipv4_addresses]
//   )
// }