from config import get_connection

connection = get_connection()
connection.autocommit = False

cursor = connection.cursor()

try:
    cursor.execute("""
        UPDATE items
        SET price=%s,
            stock=%s
        WHERE id=%s
    """, (84.99, 120, 1))

    connection.commit()

    print(f"{cursor.rowcount} row updated.")

except Exception as e:
    connection.rollback()
    print(e)

finally:
    cursor.close()
    connection.close()