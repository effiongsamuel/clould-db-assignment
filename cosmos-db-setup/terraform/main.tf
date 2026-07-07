data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

locals {
  account_name          = lower(var.account_name)
  has_secondary         = var.secondary_location != ""
  container_throughput  = (!var.enable_serverless && var.throughput_type == "manual") ? var.manual_throughput : null
}

resource "azurerm_cosmosdb_account" "this" {
  name                = local.account_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = coalesce(var.location, data.azurerm_resource_group.this.location)
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  free_tier_enabled                = var.enable_free_tier
  public_network_access_enabled    = var.enable_public_network_access
  analytical_storage_enabled       = var.enable_analytical_storage
  automatic_failover_enabled       = var.enable_automatic_failover
  multiple_write_locations_enabled = var.enable_multiple_write_locations

  consistency_policy {
    consistency_level       = var.default_consistency_level
    max_interval_in_seconds = var.default_consistency_level == "BoundedStaleness" ? var.max_interval_in_seconds : null
    max_staleness_prefix    = var.default_consistency_level == "BoundedStaleness" ? var.max_staleness_prefix : null
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = false
  }

  dynamic "geo_location" {
    for_each = local.has_secondary ? [1] : []
    content {
      location          = var.secondary_location
      failover_priority = 1
      zone_redundant    = false
    }
  }

  dynamic "capabilities" {
    for_each = var.enable_serverless ? [1] : []
    content {
      name = "EnableServerless"
    }
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 8
    storage_redundancy  = "Geo"
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "this" {
  name                = var.database_name
  resource_group_name = data.azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
}

resource "azurerm_cosmosdb_sql_container" "this" {
  name                  = var.container_name
  resource_group_name   = data.azurerm_resource_group.this.name
  account_name          = azurerm_cosmosdb_account.this.name
  database_name         = azurerm_cosmosdb_sql_database.this.name
  partition_key_paths   = [var.partition_key_path]
  partition_key_version = 1
  default_ttl           = var.default_ttl_seconds
  throughput            = local.container_throughput

  dynamic "autoscale_settings" {
    for_each = (!var.enable_serverless && var.throughput_type == "autoscale") ? [1] : []
    content {
      max_throughput = var.autoscale_max_throughput
    }
  }

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path { 
      path = "/_etag/?"
    }
  }
}
