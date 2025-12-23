# GitHub Tools

此目錄包含一系列用於與 GitHub/GitHub Enterprise 進行互動的工具腳本。這些工具支援 GitHub.com 及 GitHub Enterprise，透過解析 `.env` 文件中的 `GITHUB_REPO` 環境變數來自動判斷倉庫資訊。

## 環境設定

所有腳本都需要在專案根目錄的 `.env` 文件中設定以下環境變數：

```bash
GITHUB_REPO=https://github.com/owner/repo-name
# 或 GitHub Enterprise
GITHUB_REPO=https://git.company.com/owner/repo-name
```

## 工具列表

### 1. list-issues.sh

列出指定倉庫中的所有 issues。

**功能：**
- 從 `.env` 讀取 `GITHUB_REPO`
- 自動解析 GitHub host、owner 和 repo name
- 使用 `gh issue list` 列出所有 issues

**使用方式：**
```bash
bash .claude/tools/git/list-issues.sh
```

**輸出範例：**
```
Repo:     owner/repo-name
Host:     github.com
==============================

#1  Fix authentication bug
#2  Add new feature for user profile
#3  Update documentation
```

---

### 2. list-branches.sh

列出指定倉庫中的所有分支。

**功能：**
- 從 `.env` 讀取 `GITHUB_REPO`
- 支援 GitHub Enterprise (透過 `GH_HOST` 環境變數)
- 使用 GitHub API 列出所有分支名稱

**使用方式：**
```bash
bash .claude/tools/git/list-branches.sh
```

**輸出範例：**
```
Repo: owner/repo-name
Host: github.com

main
develop
feature/new-api
fix-issue-1
```

---

### 3. create-issue.sh

建立新的 GitHub issue。

**功能：**
- 建立新的 issue 並設定標題和內容
- 使用 GitHub API 和 access token
- 依賴 `./scripts/create-access-token.sh` 來獲取 token

**使用方式：**
```bash
bash .claude/tools/git/create-issue.sh "Issue 標題" "Issue 內容"
```

**參數：**
- `$1`: Issue 標題 (必填)
- `$2`: Issue 內容 (選填)

**輸出範例：**
```
Using:
  Host: github.com
  Owner: owner
  Repo: repo-name
  API:  https://api.github.com

✅ Issue created:
https://github.com/owner/repo-name/issues/5
```

---

### 4. describe-issue.sh

顯示指定 issue 的詳細資訊。

**功能：**
- 顯示 issue 的標題和內容
- 列出所有評論及評論者
- 支援 GitHub Enterprise

**使用方式：**
```bash
bash .claude/tools/git/describe-issue.sh 1
```

**參數：**
- `$1`: Issue 編號 (必填)

**輸出範例：**
```
Repo:     owner/repo-name
Issue:    #1
Host:     github.com
==============================

===== TITLE =====
Fix authentication bug

===== BODY =====
Users are experiencing login issues when using OAuth.
Need to investigate the token refresh mechanism.

===== COMMENTS =====
----
john-doe:
I've reproduced this issue on staging environment.

----
jane-smith:
Working on a fix, will submit PR soon.
```

---

### 5. create-branch-from-issue.sh

從指定的 issue 建立新分支並自動關聯。

**功能：**
- 自動偵測倉庫的預設分支 (main/master)
- 使用 `gh issue develop` 建立分支並關聯到 issue
- 分支命名格式：`fix-issue-{issue-number}`

**使用方式：**
```bash
bash .claude/tools/git/create-branch-from-issue.sh 1
```

**參數：**
- `$1`: Issue 編號 (必填)

**輸出範例：**
```
Repo: owner/repo-name
Host: github.com
Issue: #1

Default branch: main

✅ Branch created & linked to Issue #1
   Branch name: fix-issue-1
```

---

### 6. create-pr.sh

建立新的 Pull Request。

**功能：**
- 自動偵測倉庫的預設分支作為 base branch
- 從指定的 source branch 建立 PR
- PR 標題預設為 branch 名稱

**使用方式：**
```bash
bash .claude/tools/git/create-pr.sh <source-branch> "<body>"
```

**參數：**
- `$1`: Source branch 名稱 (必填)
- `$2`: PR 內容 (選填)

**使用範例：**
```bash
bash .claude/tools/git/create-pr.sh fix-issue-1 "修復驗證問題並新增單元測試"
```

**輸出範例：**
```
Repo:   owner/repo-name
Host:   github.com
Branch: fix-issue-1

Default branch: main

✅ Pull Request created:
https://github.com/owner/repo-name/pull/10
```

---

### 7. list-pr.sh

列出所有開啟中的 Pull Requests。

**功能：**
- 列出所有狀態為 open 的 PRs
- 顯示 PR 編號和標題
- 支援 GitHub Enterprise

**使用方式：**
```bash
bash .claude/tools/git/list-pr.sh
```

**輸出範例：**
```
Repo:     owner/repo-name
Host:     github.com
==============================

#10  Fix authentication bug
#11  Add user profile feature
#12  Update API documentation
```

---

### 8. describe-pr.sh

顯示指定 Pull Request 的詳細資訊。

**功能：**
- 顯示 PR 的標題、狀態、body
- 顯示是否可合併 (mergeable)
- 顯示是否為草稿 (draft)
- 列出討論評論 (discussion comments)
- 列出程式碼審查評論 (review comments)

**使用方式：**
```bash
bash .claude/tools/git/describe-pr.sh 10
```

**參數：**
- `$1`: PR 編號 (必填)

**輸出範例：**
```
Repo:     owner/repo-name
PR:       #10
Host:     github.com
==============================

===== TITLE =====
Fix authentication bug

===== STATE =====
open

===== MERGEABLE =====
true

===== DRAFT =====
false

===== BODY =====
This PR fixes the OAuth token refresh issue reported in #1.

Changes:
- Updated token refresh logic
- Added unit tests
- Updated documentation

===== DISCUSSION COMMENTS =====
----
jane-smith:
LGTM, tests are passing!

===== REVIEW COMMENTS =====
----
john-doe [path: src/auth.js]
Consider adding error handling for edge cases here.
```

---

## 工作流程範例

### 完整的 Issue 到 PR 流程

```bash
# 1. 列出所有 issues
bash .claude/tools/git/list-issues.sh

# 2. 查看特定 issue 的詳細資訊
bash .claude/tools/git/describe-issue.sh 1

# 3. 從 issue 建立分支
bash .claude/tools/git/create-branch-from-issue.sh 1

# 4. (進行程式碼修改...)

# 5. 建立 Pull Request
bash .claude/tools/git/create-pr.sh fix-issue-1 "修復驗證問題"

# 6. 列出所有 PRs
bash .claude/tools/git/list-pr.sh

# 7. 查看 PR 詳細資訊
bash .claude/tools/git/describe-pr.sh 10
```

### 建立新 Issue 並開始開發

```bash
# 1. 建立新 issue
bash .claude/tools/git/create-issue.sh "新增使用者設定功能" "需要新增使用者可以自訂主題和通知設定的功能"

# 2. 從新建立的 issue 建立分支 (假設 issue 編號為 5)
bash .claude/tools/git/create-branch-from-issue.sh 5

# 3. (進行開發...)

# 4. 建立 PR
bash .claude/tools/git/create-pr.sh fix-issue-5 "實作使用者設定功能"
```
