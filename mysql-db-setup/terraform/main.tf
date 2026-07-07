data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_mysql_flexible_server" "this" {
  name                   = lower(var.server_name)
  resource_group_name    = data.azurerm_resource_group.this.name
  location               = coalesce(var.location, data.azurerm_resource_group.this.location)
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_login_password
  version                = var.mysql_version
  sku_name               = var.sku_name

  storage {
    size_gb = var.storage_size_gb
    iops    = var.storage_iops
  }

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  dynamic "high_availability" {
    for_each = var.high_availability_mode == "Disabled" ? [] : [1]
    content {
      mode = var.high_availability_mode
    }
  }

  tags = var.tags
}

resource "azurerm_mysql_flexible_database" "this" {
  name                = var.database_name
  resource_group_name = data.azurerm_resource_group.this.name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_all" {
  count               = var.allow_all_ips ? 1 : 0
  name                = "AllowAll"
  resource_group_name = data.azurerm_resource_group.this.name
  server_name         = azurerm_mysql_flexible_server.this.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
