# Setup Guide

## Prerequisites

- [Docker](https://www.docker.com/) (for the CloudBees Unify MCP server)
- [Node.js](https://nodejs.org/) v18+ (for `npx` — Slack MCP server)
- [uv](https://github.com/astral-sh/uv) (for `uvx` — Jira MCP server)
- [GitHub CLI](https://cli.github.com/) (`gh`) authenticated
- [Claude Code](https://claude.ai/code) or [Cursor](https://cursor.com/)
- A CloudBees Unify account with API access

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/cloudbees-oss/devops-agent-kit.git
cd devops-agent-kit

# 2. Copy the env template and fill in your values
cp demo/env.template .env

# 3. Run the setup check
bash demo/setup.sh

# 4. Launch the agent
claude .        # Claude Code
# or
cursor .        # Cursor
```

## MCP Server Setup

Each MCP server connects the agent to a different system. Set them up in order — CloudBees Unify is required, the rest are optional depending on which skills you want to use.

---

### 1. CloudBees Unify (required)

CloudBees Unify is the core connection. All seven skills depend on it.

**Step 1: Generate a Personal Access Token (PAT)**

1. Log in to your CloudBees Unify instance (e.g., `https://your-org.cloudbees.io`)
2. Click your avatar (top right) > **User Settings** > **API Tokens**
3. Click **Generate Token**, give it a name (e.g., "devops-agent-kit"), and copy the token

**Step 2: Find your Organization ID**

1. In CloudBees Unify, click **Admin Settings** (top right) > **Organizational Profile**
2. Copy the Organization ID (a UUID like `a1b2c3d4-e5f6-7890-abcd-ef1234567890`)

**Step 3: Add to `.env`**

```bash
CLOUDBEES_API_TOKEN=cb_api_your_token_here
CLOUDBEES_ORG_ID=your-org-uuid-here
```

**Step 4: Pull the Docker image**

The CloudBees Unify MCP server runs as a Docker container:

```bash
docker pull cloudbees/unify-mcp-server:9c4153e2084a18a82fe746605170c610e203e1d8
```

The `.mcp.json` config uses `docker run` to start the server in stdio mode. By default, the kit ships with `--toolsets=all=r` (read-only). To enable write operations (flag changes, workflow triggers), change this to `--toolsets=all`. The server accepts these flags:

```bash
docker run --rm -i \
  -e CLOUDBEES_API_TOKEN=your_token \
  cloudbees/unify-mcp-server:9c4153e2084a18a82fe746605170c610e203e1d8 \
  stdio \
  --credential=CLOUDBEES_API_TOKEN \
  --organization-id=your-org-uuid
```

| Flag | Description | Default |
|------|-------------|---------|
| `--credential` | Env var name containing the API token | (required) |
| `--organization-id` | Your CloudBees Unify org UUID | (required) |
| `--toolsets` | Which tools to expose. Use `all=r` for read-only | `all` |
| `--url` | Custom service URL (for on-prem instances) | CloudBees SaaS |
| `-v` | Verbose logging (useful for debugging) | off |
| `--logfile` | Log file path | `/tmp/unify-mcp-app.log` |

> For full documentation, see the [CloudBees Unify MCP Server docs](https://docs.cloudbees.com/docs/cloudbees-unify-mcp-server/latest/).

**Step 5: Verify**

Launch the agent and ask it to run `/ci-health` or simply say "who am I?" — it will call `user_whoami` and confirm the token works.

> **Token expiry:** CloudBees API tokens expire. If you see `401 Unauthorized` errors, generate a fresh token from User Settings > API Tokens. You can test your token directly with: `curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer YOUR_TOKEN" https://api.cloudbees.io/v2/organizations`

| Variable | Description | How to get it |
|----------|-------------|---------------|
| `CLOUDBEES_API_TOKEN` | Personal access token | CloudBees Unify > User Settings > API Tokens |
| `CLOUDBEES_ORG_ID` | Organization ID | CloudBees Unify > Admin Settings > Organizational Profile |

---

### 2. Slack (required for Slack notifications)

The Slack MCP server lets the agent post summaries, alerts, and triage results to your team's channels.

**Step 1: Create a Slack App**

1. Go to https://api.slack.com/apps
2. Click **Create New App** > **From scratch**
3. Name it (e.g., "DevOps Agent") and select your workspace

**Step 2: Configure Bot Token Scopes**

1. In your app settings, go to **OAuth & Permissions**
2. Under **Bot Token Scopes**, add:
   - `chat:write` — post messages to channels
   - `channels:read` — list public channels
   - `channels:history` — read channel messages (optional, for context)
3. Click **Install to Workspace** and authorize

**Step 3: Copy your credentials**

1. On the **OAuth & Permissions** page, copy the **Bot User OAuth Token** (starts with `xoxb-`)
2. For the Team ID: open any channel in Slack (desktop or web). The URL follows the pattern `https://app.slack.com/client/TXXXXXXXX/CXXXXXXXX` — the first ID (starting with `T`) is your Team ID. Alternatively, go to your workspace name (top left) > **Settings & administration** > **Workspace settings** and find it there

**Step 4: Add to `.env`**

```bash
SLACK_BOT_TOKEN=xoxb-your-bot-token-here
SLACK_TEAM_ID=T0123456789
```

**Step 5: Invite the bot to a channel**

In Slack, go to the channel where you want the agent to post and type:
```
/invite @DevOps Agent
```
(Use whatever name you gave your app in Step 1.)

**Step 6: Verify**

Launch the agent and ask it to post a test message to the channel.

| Variable | Description | How to get it |
|----------|-------------|---------------|
| `SLACK_BOT_TOKEN` | Bot OAuth token (`xoxb-...`) | Slack App > OAuth & Permissions > Bot User OAuth Token |
| `SLACK_TEAM_ID` | Workspace ID (`T...`) | Slack URL: `app.slack.com/client/TXXXXXX/...` or workspace settings |

---

### 3. Jira (required for /file-ticket)

| Variable | Description | How to get it |
|----------|-------------|---------------|
| `JIRA_URL` | Your Jira instance URL | e.g., `https://yourcompany.atlassian.net` |
| `JIRA_USERNAME` | Your Jira email | The email you log in with |
| `JIRA_API_TOKEN` | API token | [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens) |

---

### 4. GitHub (CLI, not MCP)

The agent uses the GitHub CLI (`gh`) directly — no MCP server needed. This is intentional: it demonstrates that MCP servers and CLI tools work side by side in the same agent.

```bash
gh auth login
```

The agent calls `gh` for GitHub operations like checking PR status, viewing Actions run logs, and commenting on issues. Authenticate once and it just works.

## Using Your Own Environment (BYOE)

The kit works with any CloudBees Unify environment. Set `CLOUDBEES_API_TOKEN` and `CLOUDBEES_ORG_ID` to point at your own org and the agent will work against your real data.

The kit ships read-only by default (`--toolsets=all=r`). To enable write operations (flag changes, workflow triggers), change this to `--toolsets=all` in `.mcp.json` or `.claude/settings.json`.

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues.
