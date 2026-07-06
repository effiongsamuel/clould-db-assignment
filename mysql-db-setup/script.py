import mysql.connector
from mysql.connector import Error

HOST = "samuel-3mtt-azure-mysql-db-001.mysql.database.azure.com"
USER = "sammysqladmin"
PASSWORD = "P@ssw0rd1234!"
DB = "appdatabase"

try:
    connection = mysql.connector.connect(
        host=HOST,
        user=USER,
        password=PASSWORD,
        database=DB,
        ssl_disabled=False
    )

    if connection.is_connected():
        print(f"Connected to MySQL server: {HOST}")

        cursor = connection.cursor()

        # Create table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS items (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                price DECIMAL(10,2) NOT NULL,
                stock INT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        # Insert data
        cursor.execute("""
            INSERT INTO items (name, price, stock)
            VALUES (%s, %s, %s)
        """, ("Wireless Mouse", 25.50, 100))

        connection.commit()
        print("Data inserted.")

        # Read data
        cursor.execute("SELECT * FROM items")

        for row in cursor.fetchall():
            print(row)

except Error as e:
    print(f"MySQL Error: {e}")

finally:
    if 'connection' in locals() and connection.is_connected():
        cursor.close()
        connection.close()
        print("MySQL connection closed.")