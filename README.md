# Claude Code Template

A production-ready template for building AI-assisted development workflows with [Claude Code](https://claude.com/claude-code). This template implements a **Specification-Driven Development (SDD)** methodology with GitHub integration, providing a structured approach to managing AI-assisted software projects.

## Features

- **Structured Development Workflow**: Three-tier instruction architecture (System, Project, Task)
- **GitHub Integration**: Pre-built scripts for managing issues, branches, and pull requests
- **Claude Code Configuration**: Pre-configured permissions and settings for secure AI collaboration
- **SDD Methodology**: Documentation-first development approach
- **Notification Hooks**: Slack integration for development activity monitoring
- **GitHub App Authentication**: Secure API access using GitHub App credentials

## Quick Start

### 1. Initialize Your Project

```bash
# Create your project directory
mkdir your-app
cd your-app

# Clone the template
git clone https://github.com/kiangkiangkiang/claude-code-template.git

# Run the initialization script to get
bash claude-code-template/get-setting.sh
```

This will:
- Copy the `.claude/` directory structure to your project
- Copy `.env.example` and `run-claude.sh`
- Remove the template directory

### 2. Configure Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit the .env file with your settings
nano .env
```



### 3. Start Claude Code

```bash
bash run-claude.sh
```

**Note: That will use `zsh` as default shell, if you are using `bash`. Please remove `export SHELL=/bin/zsh`**

## Project Structure

```
your-project/
├── .claude/
│   ├── CLAUDE.md                    # Core AI collaboration guide
│   ├── settings.local.json          # Claude Code permissions & hooks
│   ├── docs/
│   │   ├── PROJECT.md              # Project goals and guidelines
│   │   └── TASK.md                 # Current task tracking
│   ├── tools/
│   │   └── git/                    # GitHub integration scripts
│   │       ├── README.md
│   │       ├── list-issues.sh
│   │       ├── create-issue.sh
│   │       ├── describe-issue.sh
│   │       ├── create-branch-from-issue.sh
│   │       ├── create-pr.sh
│   │       ├── list-pr.sh
│   │       ├── describe-pr.sh
│   │       └── list-branches.sh
│   ├── scripts/
│   │   └── create-access-token.sh  # GitHub App auth
│   └── hooks/
│       └── slack_notify.sh          # Slack notifications
├── .env                             # Environment configuration (gitignored)
├── .env.example                     # Example environment variables
└── run-claude.sh                    # Claude Code launcher script
```

## Core Concepts

### Three-Tier Instruction Architecture

This template implements a hierarchical instruction system:

1. **System Instructions** (`.claude/CLAUDE.md`)
   - Global development processes and tool guidelines
   - Cross-project, stable workflows
   - Example: Git workflows, SDD methodology

2. **Project Instructions** (`.claude/docs/PROJECT.md`)
   - Repository-specific goals and guidelines
   - Epic concepts and core values
   - Updated continuously as the project evolves

3. **Task Instructions** (`.claude/docs/TASK.md`)
   - Current active tasks
   - Dynamic, cleared upon completion
   - Tracked through Git history

### Specification-Driven Development (SDD)

The template enforces a documentation-first approach:
- All system concepts unified in `.claude/docs/`
- `CLAUDE.md` provides high-level guidance
- Detailed processes separated into specialized documents
- `PROJECT.md` and `TASK.md` continuously updated

## Security & Permissions

The template includes pre-configured security settings (`.claude/settings.local.json`):

### Allowed Operations
- Read, Edit, Write files
- Git operations (except protected branches)
- GitHub tools execution
- Web fetching

### Denied Operations
- Direct push to `main`, `master`, `beta`, `release` branches
- Git reset operations
- Reading `.env` files
- Modifying GitHub tool scripts

### Confirmation Required
- Push operations to any branch (except protected ones)

## Hooks & Notifications

### Slack Notifications

The template includes automatic Slack notifications for:
- File write/edit operations
- Bash command executions
- Idle prompts

Configure by setting `SLACK_WEBHOOK_URL` in `.env`.

## GitHub App Setup

For full API access, create a GitHub App:

1. Go to GitHub Settings → Developer settings → GitHub Apps → New GitHub App
2. Set repository permissions (issues, pull requests, contents)
3. Generate a private key
4. Install the app to your repository
5. Add credentials to `.env`:
   ```bash
   GITHUB_APP_ID=123456
   GITHUB_APP_PRIVATE_KEY_BASE64=$(cat private-key.pem | base64 -w 0)
   GITHUB_INSTALLATION_ID=987654
   ```

The `create-access-token.sh` script will automatically generate installation access tokens.



