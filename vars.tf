variable "endpoint" {
  type        = string
}

variable "api_id" {
  type        = string
}

variable "api_secret" {
  type        = string
  sensitive   = true
}

variable "total_nodes" {
  description = "Total number of nodes in the cluster"
  type        = number
  default     = 4
}

variable "BW_CLIENT" {
  type = string
}

variable "BW_SECRET" {
  type = string
}