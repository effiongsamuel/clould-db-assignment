# Azure Database for PostgreSQL Flexible Server — ARM Template Setup

Deploy a fully parameterized Azure Database for PostgreSQL (Flexible Server) using the two files in this repository:

| File | Purpose |
| ---- | ------- |
| `azuredeploy.json` | ARM template — resource definitions |
| `azuredeploy.parameters.json` | Parameter values for the deployment |

## Architecture Overview

```
Azure Resource Group
└── PostgreSQL Flexible Server
    ├── Firewall Rule: AllowAll (0.0.0.0 - 255.255.255.255)
    ├── Firewall Rule: AllowAzureServices (0.0.0.0 - 0.0.0.0)
    └── PostgreSQL Database (appdatabase)
```

## Prerequisites

- Azure CLI ≥ 2.50 or Azure PowerShell ≥ 10.0
- An active Azure subscription
- Contributor role (or higher) on the target Resource Group

Verify your CLI setup:

```bash
az --version
az account show
```

## Parameters Reference

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `serverName` | string | *(required)* | Globally unique PostgreSQL server name |
| `administratorLogin` | string | `pgadmin` | Server administrator login |
| `administratorLoginPassword` | securestring | *(required)* | Administrator password |
| `location` | string | RG location | Primary Azure region |
| `version` | string | `16` | PostgreSQL major version (`11`–`16`) |
| `skuName` | string | `Standard_B1ms` | VM SKU name |
| `skuTier` | string | `Burstable` | Compute tier (`Burstable`, `GeneralPurpose`, `MemoryOptimized`) |
| `storageSizeGB` | int | `32` | Storage size in GB (min 32) |
| `backupRetentionDays` | int | `7` | Days to keep backups (7-35) |
| `geoRedundantBackup` | string | `Disabled` | Geo-redundant backup mode |
| `highAvailabilityMode`| string | `Disabled` | High availability mode (`Disabled`, `ZoneRedundant`, `SameZone`) |
| `databaseName` | string | `appdatabase` | Name of the initial database |
| `allowAllIPs` | bool | `true` | Create firewall rule to allow all public IPs (for dev/test) |
| `allowAzureServices` | bool | `true` | Create firewall rule allowing Azure services (0.0.0.0/0.0.0.0 special rule) |
| `tags` | object | `{environment, project, managedBy}` | Resource tags |

> Note: unlike MySQL Flexible Server, PostgreSQL Flexible Server has no separate `storageIops` sku-independent parameter exposed here — IOPS scale automatically with `storageSizeGB` and `skuName` unless you extend the template with the `storage.iops` property.

## Deployment

### Step 1 — Edit parameters

Open `azuredeploy.parameters.json` and update at minimum:

```json
"serverName": { "value": "YOUR-UNIQUE-SERVER-NAME" },
"administratorLoginPassword": { "value": "YOUR-SECURE-PASSWORD" }
```

### Step 2 — Create a Resource Group

```bash
az group create --name rg-postgresdb-dev --location eastus
```

### Step 3 — Validate the template (recommended)

```bash
# ensure you are in the postgres-db-setup directory
az deployment group validate \
  --resource-group rg-postgresdb-dev \
  --template-file azuredeploy.json \
  --parameters @azuredeploy.parameters.json
```

### Step 4 — Deploy

```bash
az deployment group create \
  --resource-group rg-postgresdb-dev \
  --template-file azuredeploy.json \
  --parameters @azuredeploy.parameters.json \
  --name postgres-deploy-$(date +%Y%m%d%H%M%S)
```

check for failed deployment:

```bash
az postgres flexible-server show \
  --resource-group rg-postgresdb-dev \
  --name samuel-3mtt-azure-postgres-db-001
```

```bash
az postgres flexible-server list \
  --resource-group rg-postgresdb-dev \
  -o table
```

delete previous if failed:

```bash
az postgres flexible-server delete \
  --resource-group rg-postgresdb-dev \
  --name samuel-3mtt-azure-postgres-db-002 \
  --yes
```

Deployment typically completes in **5–10 minutes**.

### Step 5 — Review outputs

you can do before first timestamp:

```bash
az deployment group list \
  --resource-group rg-postgresdb-dev \
  -o table
```

```bash
# ensure to change the timestamp to the one you used in step 4
az deployment group show \
  --resource-group rg-postgresdb-dev \
  --name postgres-deploy-<timestamp> \
  --query properties.outputs
```

```bash
az deployment group show \
  --resource-group rg-postgresdb-dev \
  --name postgres-deploy-20260706064904 \
  --query properties.outputs \
  -o json
```

**Outputs provided:**

| Output key | Description |
| ---------- | ----------- |
| `postgresServerName` | Deployed server name |
| `postgresServerId` | Full Azure Resource ID |
| `postgresServerEndpoint` | PostgreSQL connection endpoint |
| `databaseName` | Database name |
| `administratorLogin` | Administrator login name |

> **Security note:** Passing the password directly in `azuredeploy.parameters.json` is okay for dev, but in production, fetch it from **Azure Key Vault**.

## Testing with Data

### Option A — psql CLI (Terminal)

Install the PostgreSQL client if not already installed (`postgresql-client` on Debian/Ubuntu).
Connect using the endpoint from the outputs. PostgreSQL Flexible Server requires SSL by default and the username must be given as `user@servername` on some older client versions — plain `user` works with current `psql`.

```bash
psql "host=samuel-3mtt-azure-postgres-db-001.postgres.database.azure.com port=5432 dbname=appdatabase user=sampgadmin password=<your-secure-password> sslmode=require"
```

Once connected, verify the database and insert a record:

```sql
\l
\c appdatabase

CREATE TABLE items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO items (name, price, stock) VALUES
  ('Wireless Headphones', 89.99, 150),
  ('USB-C Hub', 35.00, 320),
  ('Cloud Architecture Patterns', 49.99, 75);

SELECT * FROM items;
```

*to exit the psql CLI, type `\q` and press Enter*

### Option B — Python Testing (Programmatic)

Install the required library:

```bash
pip install psycopg2-binary
```

Run a simple test script:

```python
import psycopg2
from psycopg2 import Error

HOST = "samuel-3mtt-azure-postgres-db-001.postgres.database.azure.com"
USER = "sampgadmin"
PASSWORD = "<your-secure-password>"
DB = "appdatabase"

try:
    connection = psycopg2.connect(
        host=HOST,
        user=USER,
        password=PASSWORD,
        dbname=DB,
        port=5432,
        sslmode="require"
    )
    connection.autocommit = False
    cursor = connection.cursor()
    print(f"Connected to PostgreSQL server: {HOST}")

    # Create table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS items (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            price DECIMAL(10,2) NOT NULL,
            stock INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # Insert data
    cursor.execute("""
        INSERT INTO items (name, price, stock)
        VALUES ('Wireless Mouse', 25.50, 100)
    """)
    connection.commit()
    print("Data inserted.")

    # Read data
    cursor.execute("SELECT * FROM items")
    records = cursor.fetchall()
    for row in records:
        print(row)

except Error as e:
    print(f"Error: {e}")
finally:
    if 'connection' in locals() and connection:
        cursor.close()
        connection.close()
        print("PostgreSQL connection closed.")
```

## Clean Up

Remove all deployed resources when finished:

```bash
az group delete --name rg-postgresdb-dev --yes --no-wait
```

## Troubleshooting

| Error | Cause | Fix |
| ----- | ----- | --- |
| `ServerNameAlreadyExists` | Server name is taken globally | Change `serverName` to something unique |
| `ClientConnectionFailure` / connection timeout | Firewall blocking IP | Ensure `allowAllIPs` is true, or add your IP to the firewall rules |
| `password authentication failed` | Wrong password or user | Verify `administratorLogin` and `administratorLoginPassword` |
| `SkuNotAvailable` | Selected SKU not available in region | Try a different region or change `skuName` (e.g., to `Standard_D2ds_v4`) |
| `SSL connection required` | Client not using SSL | Add `sslmode=require` to the connection string |

## Security Best Practices

- Do **NOT** store passwords in parameter files in production. Use **Azure Key Vault** references.
- Use **VNet integration** (private access) instead of public endpoints in production.
- Disable `allowAllIPs` and explicitly add required subnets or IP addresses to the firewall.
- Regularly rotate administrator passwords and use Entra ID (Azure AD) authentication when possible.
- Keep `sslmode=require` (or stronger, `verify-full`) on all client connections — PostgreSQL Flexible Server enforces SSL by default.

## References

- [Azure Database for PostgreSQL Flexible Server documentation](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/)
- [ARM template reference — Microsoft.DBforPostgreSQL](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/flexibleservers)
- [Connect to Azure Database for PostgreSQL Flexible Server using Python](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/connect-python)
