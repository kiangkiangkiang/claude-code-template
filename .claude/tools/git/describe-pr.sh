#!/usr/bin/env bash
set -euo pipefail

# 用法：
#   bash .claude/tools/git/describe-pr.sh <pr-number>
#   bash .claude/tools/git/describe-pr.sh 5

# Load .env
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

: "${GITHUB_REPO:?Missing GITHUB_REPO (repo URL)}"

PR_NUMBER="${1:-}"

if [ -z "$PR_NUMBER" ]; then
  echo "Usage: $0 PR_NUMBER"
  exit 1
fi

#
# Parse GITHUB_REPO
#
repo_no_proto="${GITHUB_REPO#https://}"
repo_no_proto="${repo_no_proto#http://}"

GITHUB_HOST="${repo_no_proto%%/*}"
path="${repo_no_proto#*/}"

GITHUB_OWNER="${path%%/*}"
GITHUB_REPO_NAME="${path#*/}"

echo "Repo:     $GITHUB_OWNER/$GITHUB_REPO_NAME"
echo "PR:       #$PR_NUMBER"
echo "Host:     $GITHUB_HOST"
echo "=============================="
echo ""

export GH_HOST="$GITHUB_HOST"

#
# --- Fetch Pull Request JSON ---
#
PR_JSON=$(gh api \
  /repos/$GITHUB_OWNER/$GITHUB_REPO_NAME/pulls/$PR_NUMBER \
  --hostname "$GITHUB_HOST")

TITLE=$(echo "$PR_JSON" | jq -r '.title')
BODY=$(echo "$PR_JSON" | jq -r '.body // ""')
STATE=$(echo "$PR_JSON" | jq -r '.state')
MERGEABLE=$(echo "$PR_JSON" | jq -r '.mergeable // "unknown"')
DRAFT=$(echo "$PR_JSON" | jq -r '.draft')

echo "===== TITLE ====="
echo "$TITLE"
echo ""

echo "===== STATE ====="
echo "$STATE"
echo ""

echo "===== MERGEABLE ====="
echo "$MERGEABLE"
echo ""

echo "===== DRAFT ====="
echo "$DRAFT"
echo ""

echo "===== BODY ====="
echo "$BODY"
echo ""

#
# --- Discussion Comments (same API as issue comments) ---
#
DISCUSSION_JSON=$(gh api \
  /repos/$GITHUB_OWNER/$GITHUB_REPO_NAME/issues/$PR_NUMBER/comments \
  --hostname "$GITHUB_HOST")

echo "===== DISCUSSION COMMENTS ====="

DISCUSSION_COUNT=$(echo "$DISCUSSION_JSON" | jq length)

if [ "$DISCUSSION_COUNT" -eq 0 ]; then
  echo "(No discussion comments)"
else
  echo "$DISCUSSION_JSON" |
    jq -r '.[] | "----\n\(.user.login):\n\(.body)\n"'
fi

#
# --- Review Comments (comments on code diffs) ---
#
REVIEW_JSON=$(gh api \
  /repos/$GITHUB_OWNER/$GITHUB_REPO_NAME/pulls/$PR_NUMBER/comments \
  --hostname "$GITHUB_HOST")

echo "===== REVIEW COMMENTS ====="

REVIEW_COUNT=$(echo "$REVIEW_JSON" | jq length)

if [ "$REVIEW_COUNT" -eq 0 ]; then
  echo "(No review comments)"
else
  echo "$REVIEW_JSON" |
    jq -r '.[] | "----\n\(.user.login) [path: \(.path)]\n\(.body)\n"'
fi
