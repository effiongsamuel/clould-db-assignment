output "redis_cache_name" {
  description = "Deployed cache name."
  value       = azurerm_redis_cache.this.name
}

output "redis_cache_id" {
  description = "Full Azure Resource ID."
  value       = azurerm_redis_cache.this.id
}

output "host_name" {
  description = "Redis connection endpoint (hostname)."
  value       = azurerm_redis_cache.this.hostname
}

output "ssl_port" {
  description = "SSL port (usually 6380)."
  value       = azurerm_redis_cache.this.ssl_port
}

output "primary_access_key" {
  description = "Primary access key. Sensitive — store securely."
  value       = azurerm_redis_cache.this.primary_access_key
  sensitive   = true
}
