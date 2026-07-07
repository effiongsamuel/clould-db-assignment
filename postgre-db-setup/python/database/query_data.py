from config import get_connection

connection = get_connection()
cursor = connection.cursor()

cursor.execute("""
SELECT id, name, price, stock, created_at
FROM items
ORDER BY id
""")

rows = cursor.fetchall()

print("\nItems\n")

for row in rows:
    print(row)

cursor.close()
connection.close()