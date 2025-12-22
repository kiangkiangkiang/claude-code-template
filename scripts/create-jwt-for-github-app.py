# Load your private key
import os
import time

# import jwt
import jwt

file = os.path.expanduser("~/Downloads/claude-code-github-app.pem")


with open(file, "r") as key_file:
    private_key = key_file.read()

# Define the payload
payload = {
    "iat": int(time.time()),
    "exp": int(time.time()) + (10 * 60),  # 10 minutes
    "iss": 1277,
}

# Generate the JWT
jwt_token = jwt.encode(payload, private_key, algorithm="RS256")

print(jwt_token)
