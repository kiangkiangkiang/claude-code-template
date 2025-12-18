1. 要有開 issue 的能力，然後要開的時候要 slack 問，等待一段時間，說 OK 就可以開，沒回應的話就不開，可能要用 python 把等待回應的過程寫進去，感覺也不用，只要設定成 ask hook 就好，ask 裡面有 BAST("bash .claude-scripts) 啥的，還沒很清楚，要再想想
2. 要有開 branch from issue 的能力
3. 要有開 PR 的能力

未來的開發模式：

# init 時
1. 人類會啟用 `claude` 然後說明專案規劃，基本的 CICD 規範應該要寫一版在某個地方，抽象出來，變成 基本專案管理知識＋這個專案的規劃
2. 都討論好了後建立 CLAUDE.md 檔案

之後開始討論專案開發規劃

# 開發時
1. 人類會說明目前要開發的項目，claude 要整理成一個 Story 成 md 檔案，(跟人類確認)， 然後根據這個 story.md 檔案，開發成 1~3 個 issue（太多很煩，限制一個 Story 最多 3 個 issue 可解決），然後根據 issue 開 branch（感覺開 branch 不用問欸），然後開發，然後開 PR，這段流程要想一下