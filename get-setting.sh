#!/usr/bin/env bash

# setup script for claude-code-template
# Moves specific files/folders up one level then deletes the cloned repo
# Usage: ./get-settings.sh

set -euo pipefail

echo "===================="
echo "Running get-settings.sh"
echo "===================="

# 目前工作目錄（repo 被 clone 的位置）
CURRENT_DIR="$(pwd)"
REPO_NAME="$(basename "$CURRENT_DIR")"
PARENT_DIR="$(dirname "$CURRENT_DIR")"

echo "Repo directory: $CURRENT_DIR"
echo "Parent directory: $PARENT_DIR"

# 列出你想搬出的檔案 / 目錄
FILES_TO_MOVE=(
  ".claude"
  ".env.example"
  "run-claude.sh"
)

echo
echo "→ Moving files to parent directory: $PARENT_DIR"
for f in "${FILES_TO_MOVE[@]}"; do
  if [ -e "$CURRENT_DIR/$f" ]; then
    echo "  - Moving $f"
    mv "$CURRENT_DIR/$f" "$PARENT_DIR/"
  else
    echo "  - Skipping $f (not found)"
  fi
done

echo
echo "→ Files moved!"

# 返回 parent 目錄
cd "$PARENT_DIR"

echo
echo "→ Deleting cloned repository directory: $REPO_NAME"
rm -rf "$REPO_NAME"   # 使用 rm -rf 遞迴刪除整個目錄 :contentReference[oaicite:0]{index=0}

echo
echo "Done! Repository moved and cleaned up."
