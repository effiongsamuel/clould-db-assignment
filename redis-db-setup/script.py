import redis

HOST = "samuel-3mtt-azure-redis-001.redis.cache.windows.net"
PORT = 6380
PASSWORD = "<your-primary-key>"

try:
    # Connect to Redis
    r = redis.Redis(host=HOST, port=PORT, password=PASSWORD, ssl=True)
    
    print(f"Connected to Redis cache: {HOST}")

    # Set a simple key-value
    r.set("greeting", "Hello from Azure Cache for Redis!")
    print("Set 'greeting' key.")

    # Retrieve the value
    result = r.get("greeting")
    if result:
        print(f"Value retrieved: {result.decode('utf-8')}")

    # Set an expiring key (e.g., for caching/sessions)
    r.setex("session:201", 60, "active_user_data")
    print("Set expiring session key.")

except Exception as e:
    print(f"Error connecting to Redis: {e}")