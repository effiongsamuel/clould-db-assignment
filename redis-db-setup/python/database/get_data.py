from config import get_connection

r = get_connection()

print("Greeting:")
print(r.get("greeting"))

print()

print("Product Information")
print("-------------------")
print("Name :", r.get("product:1:name"))
print("Price:", r.get("product:1:price"))
print("Stock:", r.get("product:1:stock"))

print()

print("Session:")
print(r.get("session:201"))