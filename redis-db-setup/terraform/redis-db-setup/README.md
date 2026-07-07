# Azure Cache for Redis — Terraform Setup

Terraform equivalent of the `redis-db-setup` ARM template. Uses the `azurerm` provider.

| File | Purpose |
| ---- | ------- |
| `providers.tf` | Terraform + azurerm provider version pins |
| `variables.tf` | Input variable definitions |
| `main.tf` | Resource definition (Redis cache) |
| `outputs.tf` | Output values |
| `terraform.tfvars.example` | Example variable values — copy to `terraform.tfvars` and edit |

## Architecture Overview

```
Azure Resource Group (existing, referenced by data source)
└── azurerm_redis_cache
    ├── SKU: Basic, Standard, or Premium
    ├── Capacity: 0-6
    └── TLS: minimum 1.2, non-SSL port disabled
```

## Prerequisites

- Terraform ≥ 1.5.0
- Azure CLI, logged in (`az login`)
- An existing Resource Group (this module reads it via `data "azurerm_resource_group"`, it does not create one)

## Usage

### Step 1 — Create the resource group (if it doesn't exist yet)

```bash
az group create --name rg-redis-dev --location eastus
```

### Step 2 — Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set at minimum:

```hcl
redis_cache_name = "YOUR-UNIQUE-REDIS-NAME"
```

### Step 3 — Init, plan, apply

```bash
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

Apply typically takes **15–20 minutes**, same as the ARM deployment — Redis cache creation is slow regardless of tooling.

### Step 4 — Review outputs

```bash
terraform output
terraform output host_name
terraform output -raw primary_access_key
```

### Step 5 — Clean up

```bash
terraform destroy -var-file="terraform.tfvars"
```

## Testing with Data

Same as the ARM version — grab the hostname and key from `terraform output`, then use `redis-cli` over TLS or the Python `redis` client:

```bash
redis-cli \
  -h "$(terraform output -raw host_name)" \
  -p 6380 \
  --tls \
  -a "$(terraform output -raw primary_access_key)"
```

```python
import redis

r = redis.Redis(
    host="<host_name output>",
    port=6380,
    password="<primary_access_key output>",
    ssl=True,
)
r.set("greeting", "Hello from Azure Cache for Redis!")
print(r.get("greeting"))
```

## Notes vs. the ARM template

- Parameter names map directly: `redisCacheName` → `redis_cache_name`, `skuName`/`skuFamily` → `sku_name`/`sku_family`, `capacity`, `enableNonSslPort` → `enable_non_ssl_port`, `minimumTlsVersion` → `minimum_tls_version`.
- `primary_access_key` is marked `sensitive = true` in the output, but — as with the ARM `listKeys()` output — it's still stored in plaintext in Terraform state, so treat state like a secret (remote backend + encryption + restricted access).
- If you later pin a newer `azurerm` provider major version (4.x), note that HashiCorp renamed `enable_non_ssl_port` to `non_ssl_port_enabled`; this module is pinned to the 3.x series so the ARM-style name still applies.

## Security Best Practices

- Always use the **SSL/TLS endpoint** (port 6380) for data in transit.
- Keep `enable_non_ssl_port = false`.
- Rotate keys periodically — `az redis regenerate-keys` (not currently managed by this Terraform module).
- For production, use **Private Link** or VNet injection (Premium SKU) instead of the public endpoint.

## References

- [azurerm_redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache)
- [Azure Cache for Redis documentation](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/)
