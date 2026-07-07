output "postgres_server_name" {
  description = "Deployed server name."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "postgres_server_id" {
  description = "Full Azure Resource ID."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "postgres_server_endpoint" {
  description = "PostgreSQL connection endpoint (FQDN)."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_name" {
  description = "Database name."
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "administrator_login" {
  description = "Administrator login name."
  value       = azurerm_postgresql_flexible_server.this.administrator_login
}
