#!/usr/bin/env bash
set -euo pipefail

if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

: "${SLACK_WEBHOOK_URL:?Missing SLACK_WEBHOOK_URL}"
: "${SLACK_MENTION_UID:?Missing SLACK_MENTION_UID}"

# 讀整個 hook JSON input
input=$(cat)

# 抽 hook event 名稱
hook_event=$(echo "$input" | jq -r '.hook_event_name // ""')

# Slack message
message=""

# 如果是 PostToolUse（寫檔 / 編輯 / bash）
if [ "$hook_event" = "PostToolUse" ]; then
  # 取 tool 名稱
  tool_name=$(echo "$input" | jq -r '.tool_name // ""')
  
  # 把跟 file operation 相關的欄位拿出來
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' || true)
  
  if [ -n "$file_path" ]; then
    # 通知你哪個檔案被寫/編輯了
    message="Claude 已寫入或編輯檔案：${file_path}"
  else
    # 若沒 file_path，直接用 tool 名稱
    message="Claude 執行了工具：${tool_name}"
  fi

# 如果是 Notification 且 matcher 是 idle_prompt
elif [ "$hook_event" = "Notification" ]; then
  # idle_prompt 通常會進來這個事件
  message="<@${SLACK_MENTION_UID}> Claude 正在等待你的訊息"

else
  # 其他情況直接退出，不發通知
  exit 0
fi

# 傳送到 Slack，不 mention user 的情況 message 已經帶好了
payload=$(jq -n --arg txt "$message" '{text: $txt}')

curl -s -X POST \
     -H "Content-type: application/json" \
     --data "$payload" \
     "$SLACK_WEBHOOK_URL"

echo "Slack notification sent: $message" >&2
