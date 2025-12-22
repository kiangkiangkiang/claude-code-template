#!/usr/bin/env bash
set -euo pipefail

# 用法：bash .claude-scripts/list-branches.sh

# Load .env
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

: "${GITHUB_REPO:?Missing GITHUB_REPO (repo URL)}"

#
# Parse repo URL
#
repo_no_proto="${GITHUB_REPO#https://}"
repo_no_proto="${repo_no_proto#http://}"

GITHUB_HOST="${repo_no_proto%%/*}"     # git.linecorp.com
path="${repo_no_proto#*/}"             # luka-jiang/test-init

GITHUB_OWNER="${path%%/*}"
GITHUB_REPO_NAME="${path#*/}"

echo "Repo: $GITHUB_OWNER/$GITHUB_REPO_NAME"
echo "Host: $GITHUB_HOST"
echo ""

# Enterprise support
export GH_HOST="$GITHUB_HOST"

#
# List branches
#
gh api \
  /repos/$GITHUB_OWNER/$GITHUB_REPO_NAME/branches \
  --hostname "$GITHUB_HOST" \
  --jq '.[].name'
