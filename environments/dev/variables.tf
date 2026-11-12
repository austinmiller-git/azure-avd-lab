variable "workload" {
  description = "Short workload name used in resource names."
  type        = string
  default     = "avdlab"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,9}$", var.workload))
    error_message = "workload must be 2-10 lowercase letters/digits, starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "location" {
  description = "Azure region to deploy all resources."
  type        = string
  default     = "eastus"
}
