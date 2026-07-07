from config import get_connection

r = get_connection()

r.set("product:1:price", "84.99")
r.set("product:1:stock", "120")

print("Product updated.")

print("New Price:", r.get("product:1:price"))
print("New Stock:", r.get("product:1:stock"))