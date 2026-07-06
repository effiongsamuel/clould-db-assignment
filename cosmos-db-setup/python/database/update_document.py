from config import container

item = container.read_item(
    item="item-001",
    partition_key="category-electronics"
)

item["stock"] = 120
item["price"] = 84.99

container.replace_item(
    item=item,
    body=item
)

print("Item updated successfully.")