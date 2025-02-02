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

variable "machine_name" {
  type        = string
}