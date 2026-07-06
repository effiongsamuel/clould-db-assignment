from config import get_connection

connection = get_connection()
cursor = connection.cursor(dictionary=True)

cursor.execute("SELECT * FROM items")

rows = cursor.fetchall()

print("\nItems in database\n")

for row in rows:
    print(row)

cursor.close()
connection.close()