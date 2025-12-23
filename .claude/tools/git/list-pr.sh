#!/usr/bin/env bash
set -euo pipefail

# 用法：
#   bash .claude/tools/git/list-pr.sh

# Load .env if exists
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

: "${GITHUB_REPO:?Missing GITHUB_REPO (repo URL)}"

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
echo "Host:     $GITHUB_HOST"
echo "=============================="
echo ""

# Support GitHub Enterprise
export GH_HOST="$GITHUB_HOST"

#
# List open PRs: number and title
#
gh pr list \
  --repo "$GITHUB_OWNER/$GITHUB_REPO_NAME" \
  --state open \
  --json number,title \
  --jq '.[] | "#" + (.number|tostring) + "  " + .title'