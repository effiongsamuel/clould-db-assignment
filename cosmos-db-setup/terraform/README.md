# Azure Cosmos DB SQL API — Terraform Setup

Terraform equivalent of the `cosmos-db-setup` ARM template. Uses the `azurerm` provider.

| File | Purpose |
| ---- | ------- |
| `providers.tf` | Terraform + azurerm provider version pins |
| `variables.tf` | Input variable definitions |
| `main.tf` | Resource definitions (account, SQL database, container) |
| `outputs.tf` | Output values |
| `terraform.tfvars.example` | Example variable values — copy to `terraform.tfvars` and edit |

## Architecture Overview

```
Azure Resource Group (existing, referenced by data source)
└── azurerm_cosmosdb_account
    └── azurerm_cosmosdb_sql_database.this (AppDatabase)
        └── azurerm_cosmosdb_sql_container.this (Items)
            ├── Partition Key: /partitionKey
            ├── Indexing: consistent (all paths included, _etag excluded)
            └── TTL: enabled, no default expiry
```

## Prerequisites

- Terraform ≥ 1.5.0
- Azure CLI, logged in (`az login`)
- An existing Resource Group (this module reads it via `data "azurerm_resource_group"`, it does not create one)

## Usage

### Step 1 — Create the resource group (if it doesn't exist yet)

```bash
az group create --name rg-cosmosdb-dev --location eastus2
```

### Step 2 — Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set at minimum:

```hcl
account_name = "YOUR-UNIQUE-ACCOUNT-NAME"
```

Account name rules: 3–44 characters, lowercase letters and hyphens only, globally unique.

### Step 3 — Init, plan, apply

```bash
terraform init
# terraform plan -var-file="terraform.tfvars"
# terraform apply -var-file="terraform.tfvars"
terraform plan -var-file="terraform.tfvars" -out=tfplan
terraform apply tfplan
# auto approve
terraform apply -auto-approve -var-file="terraform.tfvars"
```

Verify

```bash
az cosmosdb show \
  --resource-group rg-cosmosdb-dev \
  --name samueleffiong-3mtt-azure-cosmos-db-001 \
  --query "{Name:name,Location:location,Kind:kind,State:provisioningState}" \
  -o table

  # list db
  az cosmosdb sql database list \
  --account-name samueleffiong-3mtt-azure-cosmos-db-001 \
  --resource-group rg-cosmosdb-dev \
  -o table

  # list containers
  az cosmosdb sql container list \
  --account-name samueleffiong-3mtt-azure-cosmos-db-001 \
  --database-name Samueleffiong-3mmt-AppDatabase \
  --resource-group rg-cosmosdb-dev \
  -o table
```

### Step 4 — Review outputs

```bash
terraform output
terraform output -raw primary_connection_string
terraform output -raw primary_readonly_key
```

### Step 5 — Clean up

```bash
terraform destroy -var-file="terraform.tfvars"
```

## Deployment Scenarios

Same knobs as the ARM template, just as `terraform.tfvars` entries instead of JSON parameters:

### Serverless (dev/test, spiky workloads)

```hcl
enable_serverless = true
```

Throughput settings on the container are automatically skipped when this is `true`.

### Autoscale (variable production workloads)

```hcl
enable_serverless        = false
throughput_type          = "autoscale"
autoscale_max_throughput = 4000
```

### Multi-region geo-redundancy

```hcl
secondary_location       = "westus"
enable_automatic_failover = true
```

### Multi-region writes (active-active)

```hcl
secondary_location               = "westus"
enable_automatic_failover        = true
enable_multiple_write_locations  = true
```

### BoundedStaleness consistency

```hcl
default_consistency_level = "BoundedStaleness"
max_staleness_prefix      = 100000
max_interval_in_seconds   = 300
```

### Item expiry via TTL (e.g., 7-day session data)

```hcl
default_ttl_seconds = 604800
```

## Notes vs. the ARM template

- The primary `geo_location` block is always created from `location`; a second `geo_location` block is added via a `dynamic` block only when `secondary_location != ""` — same optional-secondary-region logic as the ARM template's `if(empty(...))` variable.
- `capabilities { name = "EnableServerless" }` is added via a `dynamic` block only when `enable_serverless = true`, mirroring the ARM template's conditional `capabilities` array.
- The container's `throughput` argument and `autoscale_settings` block are mutually exclusive in the provider (as in the ARM template's manual-vs-autoscale split) and both are omitted entirely when `enable_serverless = true`, since Cosmos DB rejects throughput settings on containers in serverless accounts.
- `consistency_policy.max_staleness_prefix` / `max_interval_in_seconds` are only populated when `default_consistency_level = "BoundedStaleness"`; otherwise they're left `null` and the provider ignores them, matching the ARM template's per-level variable lookup.
- `primary_connection_string` and `primary_readonly_key` outputs are marked `sensitive = true` — they still land in Terraform state in plaintext, so use a remote encrypted backend and avoid printing them in CI logs.

## Security Best Practices

- Store the connection string and keys in **Azure Key Vault**, not in code, tfvars, or CI logs.
- Prefer **Azure Managed Identity** and Cosmos DB RBAC over primary keys where your client SDK supports it.
- Set `enable_public_network_access = false` and use **Private Endpoints** for production.
- Enable **Microsoft Defender for Cosmos DB** for threat detection.
- Rotate keys periodically via `az cosmosdb keys regenerate` (Terraform doesn't manage key rotation).

## References

- [azurerm_cosmosdb_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account)
- [azurerm_cosmosdb_sql_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database)
- [azurerm_cosmosdb_sql_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_container)
