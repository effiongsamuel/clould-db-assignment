variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into (must already exist)."
  default     = "rg-cosmosdb-dev"
}

variable "location" {
  type        = string
  description = "Primary Azure region for the Cosmos DB account."
  default     = "eastus"
}

variable "secondary_location" {
  type        = string
  description = "Optional secondary region for geo-redundancy. Leave empty string to disable."
  default     = ""
}

variable "account_name" {
  type        = string
  description = "Cosmos DB account name (globally unique, lowercase letters and hyphens only, 3-44 chars)."
}

variable "database_name" {
  type        = string
  description = "Name of the Cosmos DB SQL database."
  default     = "AppDatabase"
}

variable "container_name" {
  type        = string
  description = "Name of the Cosmos DB SQL container."
  default     = "Items"
}

variable "partition_key_path" {
  type        = string
  description = "Partition key path for the container (must start with '/')."
  default     = "/partitionKey"
}

variable "default_consistency_level" {
  type        = string
  description = "Cosmos DB consistency model."
  default     = "Session"
  validation {
    condition     = contains(["Eventual", "ConsistentPrefix", "Session", "BoundedStaleness", "Strong"], var.default_consistency_level)
    error_message = "default_consistency_level must be one of: Eventual, ConsistentPrefix, Session, BoundedStaleness, Strong."
  }
}

variable "max_staleness_prefix" {
  type        = number
  description = "Max stale requests (applies only to BoundedStaleness)."
  default     = 100000
  validation {
    condition     = var.max_staleness_prefix >= 10 && var.max_staleness_prefix <= 2147483647
    error_message = "max_staleness_prefix must be between 10 and 2147483647."
  }
}

variable "max_interval_in_seconds" {
  type        = number
  description = "Max lag time in seconds (applies only to BoundedStaleness)."
  default     = 300
  validation {
    condition     = var.max_interval_in_seconds >= 5 && var.max_interval_in_seconds <= 86400
    error_message = "max_interval_in_seconds must be between 5 and 86400."
  }
}

variable "enable_automatic_failover" {
  type        = bool
  description = "Enable automatic failover for multi-region accounts."
  default     = false
}

variable "enable_multiple_write_locations" {
  type        = bool
  description = "Enable multi-region writes (active-active). Requires secondary_location."
  default     = false
}

variable "enable_serverless" {
  type        = bool
  description = "Set to true for serverless capacity mode. When true, throughput settings are ignored."
  default     = false
}

variable "throughput_type" {
  type        = string
  description = "Throughput allocation mode (manual RU/s or autoscale). Ignored in serverless mode."
  default     = "manual"
  validation {
    condition     = contains(["manual", "autoscale"], var.throughput_type)
    error_message = "throughput_type must be one of: manual, autoscale."
  }
}

variable "manual_throughput" {
  type        = number
  description = "Provisioned RU/s for manual throughput. Ignored when throughput_type=autoscale or enable_serverless=true."
  default     = 400
  validation {
    condition     = var.manual_throughput >= 100 && var.manual_throughput <= 1000000
    error_message = "manual_throughput must be between 100 and 1000000."
  }
}

variable "autoscale_max_throughput" {
  type        = number
  description = "Max RU/s ceiling for autoscale throughput. Ignored when throughput_type=manual or enable_serverless=true."
  default     = 4000
  validation {
    condition     = var.autoscale_max_throughput >= 1000 && var.autoscale_max_throughput <= 1000000
    error_message = "autoscale_max_throughput must be between 1000 and 1000000."
  }
}

variable "enable_free_tier" {
  type        = bool
  description = "Apply the free tier discount (only one account per subscription can use free tier)."
  default     = false
}

variable "enable_public_network_access" {
  type        = bool
  description = "Allow public network access to the Cosmos DB account."
  default     = true
}

variable "enable_analytical_storage" {
  type        = bool
  description = "Enable Synapse Link / analytical store on the container."
  default     = false
}

variable "default_ttl_seconds" {
  type        = number
  description = "Default TTL in seconds for container items. -1 = TTL enabled but no default expiry. 0 = TTL disabled."
  default     = -1
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to all deployed resources."
  default = {
    environment = "dev"
    project     = "cosmosdb-setup"
    managedBy   = "Terraform"
  }
}
