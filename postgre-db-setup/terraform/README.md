# Azure Database for PostgreSQL Flexible Server — Terraform Setup

Terraform equivalent of the `postgres-db-setup` ARM template. Uses the `azurerm` provider.

| File | Purpose |
| ---- | ------- |
| `providers.tf` | Terraform + azurerm provider version pins |
| `variables.tf` | Input variable definitions |
| `main.tf` | Resource definitions (server, database, firewall rules) |
| `outputs.tf` | Output values |
| `terraform.tfvars.example` | Example variable values — copy to `terraform.tfvars` and edit |

## Architecture Overview

```
Azure Resource Group (existing, referenced by data source)
└── azurerm_postgresql_flexible_server
    ├── azurerm_postgresql_flexible_server_firewall_rule.allow_all (0.0.0.0 - 255.255.255.255)
    ├── azurerm_postgresql_flexible_server_firewall_rule.allow_azure_services (0.0.0.0 - 0.0.0.0)
    └── azurerm_postgresql_flexible_server_database.this (appdatabase)
```

## Prerequisites

- Terraform ≥ 1.5.0
- Azure CLI, logged in (`az login`) — the azurerm provider uses your CLI session by default
- An existing Resource Group (this module reads it via `data "azurerm_resource_group"`, it does not create one)

## Usage

### Step 1 — Create the resource group (if it doesn't exist yet)

```bash
az group create --name rg-postgresdb-dev --location eastus
```

### Step 2 — Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set at minimum:

```hcl
server_name                  = "YOUR-UNIQUE-SERVER-NAME"
administrator_login_password = "YOUR-SECURE-PASSWORD"
```

### Step 3 — Init, plan, apply

```bash
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Step 4 — Review outputs

```bash
terraform output
terraform output postgres_server_endpoint
```

### Step 5 — Clean up

```bash
terraform destroy -var-file="terraform.tfvars"
```

## Notes vs. the ARM template

- `sku_name` uses the azurerm provider's combined format `<Tier>_<VmSize>`, e.g. `B_Standard_B1ms`, `GP_Standard_D2ds_v4`, `MO_Standard_E2ds_v4` — instead of separate `skuName`/`skuTier` parameters.
- Storage is set via `storage_mb` on this resource (not `storage_size_gb` directly), so `main.tf` converts `storage_size_gb * 1024` for you — keep entering GB in your tfvars.
- `administrator_login_password` is marked `sensitive = true`; it will still be stored in plaintext in the Terraform state file. Use a remote backend with encryption (e.g. Azure Storage with `-backend-config`) and/or pull the password from Azure Key Vault via `data "azurerm_key_vault_secret"` in production.
- High availability is only set when `high_availability_mode != "Disabled"`, matching the ARM template's `condition`/`Disabled` default behavior.
- Two firewall rules are created by default, mirroring the ARM template: `AllowAll` (public dev/test access) and `AllowAzureServices` (the special `0.0.0.0`–`0.0.0.0` rule Postgres Flexible Server uses to permit other Azure services).
- The resource group is looked up with a `data` source rather than created by this module, so you (or a separate module) own its lifecycle.

## Security Best Practices

- Do **NOT** commit `terraform.tfvars` with real passwords to source control — add it to `.gitignore` if not already ignored.
- Use a remote backend (Azure Storage Account + state locking) instead of local state for anything beyond a personal sandbox.
- Prefer VNet integration / private access over `allow_all_ips = true` in production.
- Rotate the administrator password regularly, or move to Entra ID (Azure AD) authentication.
- Keep client connections on `sslmode=require` (or `verify-full`) — PostgreSQL Flexible Server enforces SSL by default.

## References

- [azurerm_postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server)
- [azurerm_postgresql_flexible_server_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database)
- [azurerm_postgresql_flexible_server_firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule)
