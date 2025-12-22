# Please use `create-jwt-for-github-app.py` to get JWT Token First
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

curl -X GET \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/app/installations

curl -X POST \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/app/installations/8836/access_tokens