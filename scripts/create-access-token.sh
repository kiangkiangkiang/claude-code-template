#!/usr/bin/env bash
# 記得：chmod +x scripts/create-access-token.sh
set -euo pipefail

#
# Load .env if exists
#
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

#
# Required env vars
#
: "${GITHUB_APP_ID:?Missing GITHUB_APP_ID}"
: "${GITHUB_APP_PRIVATE_KEY_BASE64:?Missing GITHUB_APP_PRIVATE_KEY_BASE64}"
: "${GITHUB_INSTALLATION_ID:?Missing GITHUB_INSTALLATION_ID}"

GITHUB_API_BASE="https://git.linecorp.com/api/v3"

#
# Decode base64 private key into temp file
#
TEMP_KEY_FILE=$(mktemp)
echo "$GITHUB_APP_PRIVATE_KEY_BASE64" | base64 --decode > "$TEMP_KEY_FILE"

#
# Base64 URL encode helper
#
b64url() {
  openssl enc -base64 -A | tr '+/' '-_' | tr -d '='
}

#
# Build JWT
#
header_json='{"alg":"RS256","typ":"JWT"}'
header=$(printf '%s' "$header_json" | b64url)

NOW=$(date +%s)
iat=$((NOW - 60))    # prevent clock skew
exp=$((NOW + 600))   # max 10 minutes

payload_json=$(jq -n \
  --arg iat "$iat" \
  --arg exp "$exp" \
  --arg iss "$GITHUB_APP_ID" \
  '{iat: ($iat|tonumber), exp: ($exp|tonumber), iss: ($iss|tonumber)}'
)
payload=$(printf '%s' "$payload_json" | b64url)

signed="${header}.${payload}"
sig=$(printf '%s' "$signed" | openssl dgst -sha256 -sign "$TEMP_KEY_FILE" | b64url)

jwt="${signed}.${sig}"

#
# Exchange JWT → Installation Access Token
#
response=$(curl -s -X POST \
  -H "Authorization: Bearer $jwt" \
  -H "Accept: application/vnd.github+json" \
  "${GITHUB_API_BASE}/app/installations/${GITHUB_INSTALLATION_ID}/access_tokens")

token=$(echo "$response" | jq -r '.token')

if [ "$token" = "null" ] || [ -z "$token" ]; then
  echo "❌ Failed to fetch installation access token"
  echo "$response"
  exit 1
fi

echo "$token"

#
# Cleanup
#
rm -f "$TEMP_KEY_FILE"
