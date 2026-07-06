from config import get_connection

connection = get_connection()
cursor = connection.cursor()

cursor.execute("DELETE FROM items WHERE id = %s", (1,))

connection.commit()

print(f"{cursor.rowcount} row deleted.")

cursor.close()
connection.close()