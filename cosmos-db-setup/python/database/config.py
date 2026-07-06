import os
from dotenv import load_dotenv
from azure.cosmos import CosmosClient

load_dotenv()

ENDPOINT = os.getenv("COSMOS_ENDPOINT")
KEY = os.getenv("COSMOS_KEY")

DATABASE_NAME = os.getenv("AppDatabase")
CONTAINER_NAME = os.getenv("Container")

client = CosmosClient(ENDPOINT, credential=KEY)

database = client.get_database_client(DATABASE_NAME)
container = database.get_container_client(CONTAINER_NAME)