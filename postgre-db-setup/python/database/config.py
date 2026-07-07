import os
from dotenv import load_dotenv
import psycopg2

load_dotenv()

HOST = os.getenv("POSTGRES_HOST")
USER = os.getenv("POSTGRES_USER")
PASSWORD = os.getenv("POSTGRES_PASSWORD")
DB = os.getenv("POSTGRES_DB")
PORT = os.getenv("POSTGRES_PORT", "5432")


def get_connection():
    return psycopg2.connect(
        host=HOST,
        user=USER,
        password=PASSWORD,
        dbname=DB,
        port=PORT,
        sslmode="require"
    )