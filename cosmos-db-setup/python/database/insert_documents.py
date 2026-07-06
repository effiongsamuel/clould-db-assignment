from config import container

sample_items = [
    {
        "id": "item-001",
        "partitionKey": "category-electronics",
        "name": "Wireless Headphones",
        "price": 89.99,
        "stock": 150,
        "tags": ["audio", "wireless", "bluetooth"],
        "createdAt": "2025-01-01T00:00:00Z"
    },
    {
        "id": "item-002",
        "partitionKey": "category-electronics",
        "name": "USB-C Hub",
        "price": 35.00,
        "stock": 320,
        "tags": ["accessories", "usb", "hub"],
        "createdAt": "2025-01-02T00:00:00Z"
    },
    {
        "id": "item-003",
        "partitionKey": "category-books",
        "name": "Cloud Architecture Patterns",
        "price": 49.99,
        "stock": 75,
        "tags": ["cloud", "architecture", "devops"],
        "createdAt": "2025-01-03T00:00:00Z"
    }
]

for item in sample_items:
    result = container.upsert_item(item)
    print(f"Upserted: {result['id']} ({result['partitionKey']})")