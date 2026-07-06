from config import container

container.delete_item(
    item="item-001",
    partition_key="category-electronics"
)

print("Item deleted successfully.")