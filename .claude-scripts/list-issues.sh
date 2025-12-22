#!/usr/bin/env bash
set -euo pipefail

# 用法：bash .claude-scripts/list-issues.sh

# Load .env
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

gh issue list --repo $GITHUB_OWNER/$GITHUB_REPO_NAME  