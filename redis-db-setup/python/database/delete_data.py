from config import get_connection

r = get_connection()

r.delete(
    "greeting",
    "product:1:name",
    "product:1:price",
    "product:1:stock",
    "session:201"
)

print("Keys deleted.")