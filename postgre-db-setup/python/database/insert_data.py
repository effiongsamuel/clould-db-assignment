from config import get_connection

connection = get_connection()
connection.autocommit = False

cursor = connection.cursor()

try:
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS items (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            price DECIMAL(10,2) NOT NULL,
            stock INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    items = [
        ("Wireless Headphones", 89.99, 150),
        ("USB-C Hub", 35.00, 320),
        ("Cloud Architecture Patterns", 49.99, 75),
        ("Wireless Mouse", 25.50, 100)
    ]

    cursor.executemany("""
        INSERT INTO items (name, price, stock)
        VALUES (%s, %s, %s)
    """, items)

    connection.commit()

    print(f"{cursor.rowcount} rows inserted.")

except Exception as e:
    connection.rollback()
    print(e)

finally:
    cursor.close()
    connection.close()