variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into (must already exist)."
  default     = "rg-redis-dev"
}

variable "location" {
  type        = string
  description = "Azure region for the Redis cache."
  default     = "eastus"
}

variable "redis_cache_name" {
  type        = string
  description = "Globally unique name of the Azure Cache for Redis instance."
}

variable "sku_name" {
  type        = string
  description = "The pricing tier of the Azure Cache for Redis instance."
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "sku_name must be one of: Basic, Standard, Premium."
  }
}

variable "sku_family" {
  type        = string
  description = "The family for the sku: C (Basic/Standard) or P (Premium)."
  default     = "C"
  validation {
    condition     = contains(["C", "P"], var.sku_family)
    error_message = "sku_family must be one of: C, P."
  }
}

variable "capacity" {
  type        = number
  description = "The size of the Redis cache instance (0-6)."
  default     = 0
  validation {
    condition     = contains([0, 1, 2, 3, 4, 5, 6], var.capacity)
    error_message = "capacity must be one of: 0, 1, 2, 3, 4, 5, 6."
  }
}

variable "enable_non_ssl_port" {
  type        = bool
  description = "Allow access via non-SSL port (6379)."
  default     = false
}

variable "minimum_tls_version" {
  type        = string
  description = "Requires clients to use a specified TLS version (or higher)."
  default     = "1.2"
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be one of: 1.0, 1.1, 1.2."
  }
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to all deployed resources."
  default = {
    environment = "dev"
    project     = "redis-setup"
    managedBy   = "Terraform"
  }
}
