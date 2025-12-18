#!/usr/bin/env bash
set -euo pipefail

# 確認 Slack webhook 來自環境變數
if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  echo "Missing SLACK_WEBHOOK_URL environment variable." >&2
  exit 1
fi

# 讀取 Claude Code 傳入的 JSON（stdin）
input=$(cat)

# 解析檔案路徑
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# 如果沒有檔案就退出
if [ -z "$file_path" ]; then
  echo "No file path found in hook input." >&2
  exit 0
fi

# Slack 訊息內容
payload="Claude 已經寫入檔案：${file_path}"

# 傳送到 Slack
curl -s -X POST \
  -H "Content-type: application/json" \
  --data "{\"text\": \"$payload\"}" \
  "$SLACK_WEBHOOK_URL"

echo "Slack notification sent for $file_path" >&2
