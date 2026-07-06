import os
from dotenv import load_dotenv
import mysql.connector

load_dotenv()

HOST = os.getenv("MYSQL_HOST")
USER = os.getenv("MYSQL_USER")
PASSWORD = os.getenv("MYSQL_PASSWORD")
DB = os.getenv("MYSQL_DATABASE")

def get_connection():
    return mysql.connector.connect(
        host=HOST,
        user=USER,
        password=PASSWORD,
        database=DB,
        ssl_disabled=False
    )