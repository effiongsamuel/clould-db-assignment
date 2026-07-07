output "cosmosdb_account_name" {
  description = "Deployed Cosmos DB account name."
  value       = azurerm_cosmosdb_account.this.name
}

output "cosmosdb_account_id" {
  description = "Full Azure Resource ID."
  value       = azurerm_cosmosdb_account.this.id
}

output "document_endpoint" {
  description = "Cosmos DB HTTPS endpoint."
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "primary_connection_string" {
  description = "Primary SQL API connection string. Sensitive — store securely."
  value       = azurerm_cosmosdb_account.this.primary_sql_connection_string
  sensitive   = true
}

output "primary_readonly_key" {
  description = "Primary read-only master key. Sensitive."
  value       = azurerm_cosmosdb_account.this.primary_readonly_key
  sensitive   = true
}

output "database_name" {
  description = "SQL database name."
  value       = azurerm_cosmosdb_sql_database.this.name
}

output "container_name" {
  description = "Container name."
  value       = azurerm_cosmosdb_sql_container.this.name
}
