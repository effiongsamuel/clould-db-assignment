data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_redis_cache" "this" {
  name                = lower(var.redis_cache_name)
  resource_group_name = data.azurerm_resource_group.this.name
  location            = coalesce(var.location, data.azurerm_resource_group.this.location)

  sku_name = var.sku_name
  family   = var.sku_family
  capacity = var.capacity

  non_ssl_port_enabled = var.enable_non_ssl_port
  minimum_tls_version = var.minimum_tls_version

  tags = var.tags
}
