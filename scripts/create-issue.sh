#!/usr/bin/env bash
# 用法：bash scripts/create-issue.sh "Issue 標題" "Issue 內容"
set -euo pipefail

# Load .env
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

# 必要欄位
: "${GITHUB_REPO:?Missing GITHUB_REPO (repo URL)}"

# === 自動解析 URL ===
# 範例：https://git.linecorp.com/luka-jiang/test-init

# 去掉 protocol
repo_no_proto="${GITHUB_REPO#https://}"
repo_no_proto="${repo_no_proto#http://}"

# host = 第一段
GITHUB_HOST="${repo_no_proto%%/*}"

# path = 去掉 host 後面剩的
path="${repo_no_proto#*/}"

# owner = 第一段
GITHUB_OWNER="${path%%/*}"

# repo name = 第二段
GITHUB_REPO_NAME="${path#*/}"

GITHUB_API_BASE="https://git.linecorp.com/api/v3"

echo "Using:"
echo "  Host: $GITHUB_HOST"
echo "  Owner: $GITHUB_OWNER"
echo "  Repo: $GITHUB_REPO_NAME"
echo "  API:  $GITHUB_API_BASE"

# === Step 1: 取得 Access Token ===
ACCESS_TOKEN=$(./scripts/create-access-token.sh)
if [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Failed to get token"
  exit 1
fi

# === Step 2: 建 Issue ===
TITLE="${1:-}"
BODY="${2:-}"

if [ -z "$TITLE" ]; then
  echo "Usage: $0 \"TITLE\" \"BODY(optional)\""
  exit 1
fi

response=$(curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "$GITHUB_API_BASE/repos/$GITHUB_OWNER/$GITHUB_REPO_NAME/issues" \
  -d "$(jq -n --arg title "$TITLE" --arg body "$BODY" '{title:$title, body:$body}')")

html_url=$(echo "$response" | jq -r '.html_url')

if [[ "$html_url" == "null" || -z "$html_url" ]]; then
  echo "❌ Failed to create issue"
  echo "$response"
  exit 1
fi

echo "✅ Issue created:"
echo "$html_url"


