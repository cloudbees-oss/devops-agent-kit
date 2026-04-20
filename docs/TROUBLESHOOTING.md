# Troubleshooting

## MCP Server Connection Issues

### CloudBees Unify MCP server won't start

**Symptom:** The CloudBees Unify tools don't appear in the agent, or you see connection errors.

**Fixes:**
- Verify Docker is running: `docker ps`
- Pull the latest image: `docker pull cloudbees/unify-mcp-server:9c4153e2084a18a82fe746605170c610e203e1d8`
- Check that `CLOUDBEES_API_TOKEN` and `CLOUDBEES_ORG_ID` are set in your `.env` or `.mcp.json`
- If behind a corporate proxy, set `HTTPS_PROXY` environment variable

> **Note:** The CloudBees Unify MCP server runs via Docker, not npm. The `@cloudbees/unify-mcp-server` npm package is not publicly available. If you see `npm error 404 Not Found`, switch to the Docker-based configuration in `.mcp.json`.

### CloudBees API token expired (401 Unauthorized)

**Symptom:** `user_whoami` or `components_list` returns `401 serviceEndpointListServicesUnauthorized`.

**Fixes:**
- Generate a fresh token: CloudBees Unify > User Settings > API Tokens
- Test it directly: `curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer YOUR_TOKEN" https://api.cloudbees.io/v2/organizations`
- Update the token in `.mcp.json` (in the `args` array for the Docker command) and restart the agent
- Tokens expire periodically — if your agent was working yesterday but not today, this is the most likely cause

### Jira MCP server won't start

**Symptom:** `uvx --from 'mcp-atlassian==0.21.1' mcp-atlassian` fails.

**Fixes:**
- Install uv: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Verify `JIRA_URL` includes the protocol: `https://yourcompany.atlassian.net`
- Generate a new API token at https://id.atlassian.com/manage-profile/security/api-tokens
- `JIRA_USERNAME` should be your email, not your display name

### Slack MCP server won't start

**Symptom:** `npx -y @zencoderai/slack-mcp-server@0.0.1` fails.

**Fixes:**
- Verify `SLACK_BOT_TOKEN` starts with `xoxb-`
- Ensure the Slack app has required scopes: `chat:write`, `channels:read`, `channels:history`
- `SLACK_TEAM_ID` is the workspace ID (found in Slack app settings)

### GitHub CLI not working

**Symptom:** Agent can't check GitHub PRs or Actions runs.

**Fixes:**
- Authenticate: `gh auth login`
- Verify: `gh auth status` should show you're logged in
- The agent uses the `gh` CLI directly (not an MCP server) for GitHub operations — this is by design

## Agent Behavior Issues

### Agent gets stuck or produces unexpected output

**Fixes:**
- Start a new conversation — MCP server state may be stale
- Check that the correct org is set in `CLOUDBEES_ORG_ID`
- Run `demo/setup.sh` to validate all connections

### `logs_list` returns 500 error

**This is a known limitation.** The CloudBees Unify MCP server's log retrieval may fail for some runs. The agent is designed to fall back to analyzing step names, statuses, and durations instead. No action needed.

### Controller analytics widgets return empty data

**Known limitation.** Widgets ci5 (Completed Runs), ci6 (Usage Patterns), and ci7 (Project Activity) may return empty data. The agent skips them gracefully and calculates the CI Health Score from available data.

### Org-level security reports show "No Data Found"

**Known limitation.** Widgets s4 and s5 at the org level may not have data. The agent falls back to component-level `security_issues_all_get` which works reliably.

### Agent skips some runs (code_scan workflows)

**By design.** Runs with workflow names containing "code_scan" are infrastructure-managed security scans, not user CI pipelines. The agent filters these out to focus on user-relevant pipelines.

## Environment Issues

### .env file not loading

**Fix:** The setup script sources `.env` from the repo root. Ensure:
- The file is named `.env` (not `env` or `.env.local`)
- Values don't have quotes around them: `CLOUDBEES_API_TOKEN=abc123` not `CLOUDBEES_API_TOKEN="abc123"`
- No trailing whitespace in values

### Running behind a corporate proxy

Set these environment variables:
```bash
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080
export NO_PROXY=localhost,127.0.0.1
```

## Still stuck?

Open an issue at https://github.com/cloudbees/devops-agent-kit/issues with:
1. Which MCP server is failing
2. The error message
3. Output of `demo/setup.sh`
