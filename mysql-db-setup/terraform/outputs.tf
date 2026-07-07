output "mysql_server_name" {
  description = "Deployed server name."
  value       = azurerm_mysql_flexible_server.this.name
}

output "mysql_server_id" {
  description = "Full Azure Resource ID."
  value       = azurerm_mysql_flexible_server.this.id
}

output "mysql_server_endpoint" {
  description = "MySQL connection endpoint (FQDN)."
  value       = azurerm_mysql_flexible_server.this.fqdn
}

output "database_name" {
  description = "Database name."
  value       = azurerm_mysql_flexible_database.this.name
}

output "administrator_login" {
  description = "Administrator login name."
  value       = azurerm_mysql_flexible_server.this.administrator_login
}
