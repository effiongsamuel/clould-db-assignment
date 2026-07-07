from config import get_connection

connection = get_connection()
connection.autocommit = False

cursor = connection.cursor()

try:
    cursor.execute("""
        DELETE FROM items
        WHERE id=%s
    """, (1,))

    connection.commit()

    print(f"{cursor.rowcount} row deleted.")

except Exception as e:
    connection.rollback()
    print(e)

finally:
    cursor.close()
    connection.close()