#!/usr/bin/env bash
# 用法
#.   bash .claude-scripts/create-branch-from-issue.sh <issue-id> 
#.   bash .claude-scripts/create-branch-from-issue.sh 1 
set -euo pipefail

# Load .env if exists
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

# 必要：完整 repo URL
: "${GITHUB_REPO:?Missing GITHUB_REPO (repo URL)}"

ISSUE_NUMBER="${1:-}"
if [ -z "$ISSUE_NUMBER" ]; then
  echo "Usage: $0 ISSUE_NUMBER"
  exit 1
fi

#
# === Parse GITHUB_REPO (ex: https://git.linecorp.com/luka-jiang/test-init)
#
repo_no_proto="${GITHUB_REPO#https://}"
repo_no_proto="${repo_no_proto#http://}"

GITHUB_HOST="${repo_no_proto%%/*}"     # git.linecorp.com
path="${repo_no_proto#*/}"             # luka-jiang/test-init

GITHUB_OWNER="${path%%/*}"             # luka-jiang
GITHUB_REPO_NAME="${path#*/}"          # test-init

echo "Repo: $GITHUB_OWNER/$GITHUB_REPO_NAME"
echo "Host: $GITHUB_HOST"
echo "Issue: #$ISSUE_NUMBER"
echo ""

#
# === GitHub Enterprise 支援 ===
#
export GH_HOST="$GITHUB_HOST"

#
# === Step 1: 取得 Repo default branch ===
#
DEFAULT_BRANCH=$(gh api \
  /repos/$GITHUB_OWNER/$GITHUB_REPO_NAME \
  --hostname "$GITHUB_HOST" \
  --jq '.default_branch')

echo "Default branch: $DEFAULT_BRANCH"

#
# === Step 2: 使用 GitHub 官方 develop flow 建 branch（會自動連結 Issue）
#
BRANCH_NAME="fix-issue-$ISSUE_NUMBER"

gh issue develop "$ISSUE_NUMBER" \
  --repo "$GITHUB_OWNER/$GITHUB_REPO_NAME" \
  --base "$DEFAULT_BRANCH" \
  --name "$BRANCH_NAME"

echo ""
echo "✅ Branch created & linked to Issue #$ISSUE_NUMBER"
echo "   Branch name: $BRANCH_NAME"
