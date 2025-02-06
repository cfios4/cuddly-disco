variable "endpoint" {
  type        = string
}

variable "pm_api_token_id" {
  type        = string
}

variable "pm_api_token_secret" {
  type        = string
  sensitive   = true
}

variable "total_nodes" {
  description = "Total number of nodes in the cluster"
  type        = number
  default     = 4
}