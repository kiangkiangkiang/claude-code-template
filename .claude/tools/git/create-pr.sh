#!/usr/bin/env bash
set -euo pipefail

# 用法:
#   bash .claude/tools/git/create-pr.sh <source-branch> "<body>"
#   bash .claude/tools/git/create-pr.sh fix-issue-1 "測試 PR 的 Body"

# Load .env
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

: "${GITHUB_REPO:?Missing GITHUB_REPO (repo URL)}"

SOURCE_BRANCH="${1:-}"
PR_BODY="${2:-}"

if [ -z "$SOURCE_BRANCH" ]; then
  echo "Usage: $0 SOURCE_BRANCH \"PR_BODY(optional)\""
  exit 1
fi

#
# Parse repo URL (ex: https://git.linecorp.com/luka-jiang/test-init)
#
repo_no_proto="${GITHUB_REPO#https://}"
repo_no_proto="${repo_no_proto#http://}"

GITHUB_HOST="${repo_no_proto%%/*}"     # git.linecorp.com
path="${repo_no_proto#*/}"             # luka-jiang/test-init

GITHUB_OWNER="${path%%/*}"
GITHUB_REPO_NAME="${path#*/}"

echo "Repo:   $GITHUB_OWNER/$GITHUB_REPO_NAME"
echo "Host:   $GITHUB_HOST"
echo "Branch: $SOURCE_BRANCH"
echo ""

# GitHub Enterprise support
export GH_HOST="$GITHUB_HOST"

#
# Step 1: Detect default branch
#
DEFAULT_BRANCH=$(gh api \
  /repos/$GITHUB_OWNER/$GITHUB_REPO_NAME \
  --hostname "$GITHUB_HOST" \
  --jq '.default_branch')

echo "Default branch: $DEFAULT_BRANCH"
echo ""

#
# Step 2: Create PR
#
PR_URL=$(gh pr create \
  --repo "$GITHUB_OWNER/$GITHUB_REPO_NAME" \
  --base "$DEFAULT_BRANCH" \
  --head "$SOURCE_BRANCH" \
  --title "$SOURCE_BRANCH" \
  --body "$PR_BODY")

echo "✅ Pull Request created:"
echo "$PR_URL"