import os
import redis
from dotenv import load_dotenv

load_dotenv()

HOST = os.getenv("REDIS_HOST")
PORT = int(os.getenv("REDIS_PORT", 6380))
PASSWORD = os.getenv("REDIS_PASSWORD")


def get_connection():
    return redis.Redis(
        host=HOST,
        port=PORT,
        password=PASSWORD,
        ssl=True,
        decode_responses=True
    )