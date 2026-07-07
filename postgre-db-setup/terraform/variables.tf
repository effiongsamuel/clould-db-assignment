variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into (must already exist)."
  default     = "rg-postgresdb-dev"
}

variable "location" {
  type        = string
  description = "Azure region for the PostgreSQL Flexible Server."
  default     = "eastus"
}

variable "server_name" {
  type        = string
  description = "Globally unique PostgreSQL Flexible Server name."
}

variable "administrator_login" {
  type        = string
  description = "Administrator login name for the PostgreSQL server."
  default     = "pgadmin"
}

variable "administrator_login_password" {
  type        = string
  description = "Administrator password for the PostgreSQL server."
  sensitive   = true
}

variable "postgres_version" {
  type        = string
  description = "PostgreSQL major version."
  default     = "16"
  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16"], var.postgres_version)
    error_message = "postgres_version must be one of: 11, 12, 13, 14, 15, 16."
  }
}

variable "sku_name" {
  type        = string
  description = "Compute SKU, e.g. B_Standard_B1ms, GP_Standard_D2ds_v4, MO_Standard_E2ds_v4."
  default     = "B_Standard_B1ms"
}

variable "storage_size_gb" {
  type        = number
  description = "Max storage allowed for the server, in GB."
  default     = 32
  validation {
    condition     = var.storage_size_gb >= 32 && var.storage_size_gb <= 16384
    error_message = "storage_size_gb must be between 32 and 16384."
  }
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention days for the server."
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 7 and 35."
  }
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  description = "Enable geo-redundant backup."
  default     = false
}

variable "high_availability_mode" {
  type        = string
  description = "High availability mode: Disabled, ZoneRedundant, or SameZone."
  default     = "Disabled"
  validation {
    condition     = contains(["Disabled", "ZoneRedundant", "SameZone"], var.high_availability_mode)
    error_message = "high_availability_mode must be one of: Disabled, ZoneRedundant, SameZone."
  }
}

variable "database_name" {
  type        = string
  description = "Name of the initial PostgreSQL database."
  default     = "appdatabase"
}

variable "allow_all_ips" {
  type        = bool
  description = "Create a firewall rule allowing all public IPs (dev/test only)."
  default     = true
}

variable "allow_azure_services" {
  type        = bool
  description = "Create the special 0.0.0.0-0.0.0.0 firewall rule allowing Azure services to connect."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to all deployed resources."
  default = {
    environment = "dev"
    project     = "postgresdb-setup"
    managedBy   = "Terraform"
  }
}
