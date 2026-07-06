from config import get_connection

connection = get_connection()
cursor = connection.cursor()

cursor.execute("""
UPDATE items
SET price = %s,
    stock = %s
WHERE id = %s
""", (84.99, 120, 1))

connection.commit()

print(f"{cursor.rowcount} row updated.")

cursor.close()
connection.close()