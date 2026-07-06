from config import container

print("\nElectronics\n")

query = """
SELECT * FROM c
WHERE c.partitionKey = 'category-electronics'
"""

items = list(
    container.query_items(
        query=query,
        enable_cross_partition_query=False
    )
)

for item in items:
    print(f"{item['id']} - {item['name']} - ${item['price']}")

print("\nItems cheaper than $50\n")

query = """
SELECT c.id, c.name, c.price
FROM c
WHERE c.price < 50
"""

items = list(
    container.query_items(
        query=query,
        enable_cross_partition_query=True
    )
)

for item in items:
    print(item)

count_query = "SELECT VALUE COUNT(1) FROM c"

count = list(
    container.query_items(
        query=count_query,
        enable_cross_partition_query=True
    )
)

print(f"\nTotal items: {count[0]}")