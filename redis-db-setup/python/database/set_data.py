from config import get_connection

r = get_connection()

# Set simple key-value pairs
r.set("greeting", "Hello from Azure Cache for Redis!")

# Set multiple keys
r.set("product:1:name", "Wireless Headphones")
r.set("product:1:price", "89.99")
r.set("product:1:stock", "150")

# Expiring key
r.setex("session:201", 60, "active_user_data")

print("Data stored successfully.")