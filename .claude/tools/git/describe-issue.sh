#!/usr/bin/env bash
set -euo pipefail

# 用法：
#.   bash .claude/tools/git/describe-issue.sh <issue-id>
#.   bash .claude/tools/git/describe-issue.sh 1

# Load .env
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

: "${GITHUB_REPO:?Missing GITHUB_REPO (repo URL)}"

ISSUE_NUMBER="${1:-}"

if [ -z "$ISSUE_NUMBER" ]; then
  echo "Usage: $0 ISSUE_NUMBER"
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
echo "Issue:    #$ISSUE_NUMBER"
echo "Host:     $GITHUB_HOST"
echo "=============================="
echo ""

export GH_HOST="$GITHUB_HOST"

#
# Fetch Issue JSON
#
ISSUE_JSON=$(gh api \
  /repos/$GITHUB_OWNER/$GITHUB_REPO_NAME/issues/$ISSUE_NUMBER \
  --hostname "$GITHUB_HOST")

TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
BODY=$(echo "$ISSUE_JSON" | jq -r '.body // ""')

echo "===== TITLE ====="
echo "$TITLE"
echo ""

echo "===== BODY ====="
echo "$BODY"
echo ""

#
# Fetch Comments
#
COMMENTS_JSON=$(gh api \
  /repos/$GITHUB_OWNER/$GITHUB_REPO_NAME/issues/$ISSUE_NUMBER/comments \
  --hostname "$GITHUB_HOST")

echo "===== COMMENTS ====="

COMMENT_COUNT=$(echo "$COMMENTS_JSON" | jq length)

if [ "$COMMENT_COUNT" -eq 0 ]; then
  echo "(No comments)"
  exit 0
fi

echo "$COMMENTS_JSON" |
  jq -r '.[] | "----\n\(.user.login):\n\(.body)\n"'
