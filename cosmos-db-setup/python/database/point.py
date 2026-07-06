from config import container

item = container.read_item(item="item-001", partition_key="category-electronics")
print(item)