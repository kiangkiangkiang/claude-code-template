#!/usr/bin/env bash

set -e

TEMPLATE_DIR="claude-code-template"

# 複製需要的檔案到當前目錄
cp -r "$TEMPLATE_DIR/.claude" .
cp "$TEMPLATE_DIR/.env.example" .
cp "$TEMPLATE_DIR/run-claude.sh" .

# 刪除模板目錄
rm -rf "$TEMPLATE_DIR"

echo "Claude settings initialized."
