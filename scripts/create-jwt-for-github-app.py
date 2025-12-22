import jwt
import time
 
# Load your private key
with open("~/Downloads/claude-code-github-app.2025-12-22.private-key.pem", "r") as key_file:
    private_key = key_file.read()
 
# Define the payload
payload = {
    "iat": int(time.time()),
    "exp": int(time.time()) + (10 * 60),  # 10 minutes
    "iss": "8836"
}
 
# Generate the JWT
jwt_token = jwt.encode(payload, private_key, algorithm="RS256")