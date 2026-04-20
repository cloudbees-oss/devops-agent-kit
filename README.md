# DevOps Agent Kit

Turn your AI coding assistant into a DevOps specialist. Clone this repo, open it in [Claude Code](https://claude.ai/code) or [Cursor](https://cursor.com/), and get a working DevOps agent that sees across all your CI/CD tools.

> **This is a demo and community reference project maintained by CloudBees DevRel. It is not production-hardened, not a CloudBees product, and not covered by CloudBees support. Use at your own risk and review all configurations before connecting to production systems.**

## What it does

The DevOps Agent connects to your CI/CD tools via [MCP](https://modelcontextprotocol.io/) and gives you:

- **Unified pipeline visibility** across Jenkins, GitHub Actions, and CloudBees Workflows
- **Build failure triage** with root cause classification
- **Security posture assessment** with remediation priorities
- **Release readiness checks** with go/no-go decisions
- **Feature flag management** from your IDE
- **CI health monitoring** with actionable scores
- **Cross-tool actions** — Jira tickets, Slack posts, GitHub PR comments

## Quick start

```bash
git clone https://github.com/cloudbees-oss/devops-agent-kit.git
cd devops-agent-kit
cp demo/env.template .env
# Edit .env with your tokens
bash demo/setup.sh
claude .
```

## Skills (slash commands)

| Skill | What it does |
|-------|-------------|
| `/pipeline-overview` | Unified cross-tool CI/CD status dashboard |
| `/triage` | Analyze failed runs — root cause + classification |
| `/security-scan` | Security posture across components |
| `/release-status` | Release readiness with go/no-go verdict |
| `/flag-rollout` | List, enable, disable, or create feature flags |
| `/ci-health` | CI health score with controller analytics |
| `/file-ticket` | Create a Jira ticket from any finding |

## Connections

| Tool | How | What it provides |
|------|-----|-----------------|
| [CloudBees Unify](https://www.cloudbees.com/) | MCP (Docker) | CI runs, logs, components, security, analytics, workflows, flags |
| [Jira](https://www.atlassian.com/software/jira) | MCP (uvx) | Issue creation and management |
| [Slack](https://slack.com/) | MCP (npx) | Team notifications |
| [GitHub](https://github.com/) | `gh` CLI | PRs, issues, code search, Actions status |

Three MCP servers + one CLI tool. The agent handles both seamlessly — use MCP where servers exist, CLI where they don't.

## Works with

- **Claude Code** — Full support via CLAUDE.md + .claude/skills/ + .claude/settings.json
- **Cursor** — Full support via .cursor/rules/ + .cursor/mcp.json

## Bring your own environment

The kit works with any CloudBees Unify environment. Set your `CLOUDBEES_API_TOKEN` and `CLOUDBEES_ORG_ID` to point at your own org.

## Security considerations

**Never commit your `.env` file.** The `.gitignore` in this repo excludes it, but if you fork or copy the kit elsewhere, make sure your tokens stay out of version control.

**Read-only by default.** The MCP server config ships with `--toolsets=all=r`, which exposes all CloudBees Unify tools in read-only mode. To enable write operations (flag changes, workflow triggers), change this to `--toolsets=all` in `.mcp.json` or `.claude/settings.json` — but do so deliberately.

**Prompt injection via CI logs.** The `/triage` skill reads pipeline logs and can trigger downstream actions like creating Jira tickets or posting to Slack. A malicious actor with commit access could craft log output designed to manipulate the agent. Mitigations: the kit ships read-only by default, skills require user confirmation before write actions, and the agent persona in CLAUDE.md includes guardrails. If you enable write toolsets, review the triage output before approving any actions.

**Report vulnerabilities responsibly.** See [SECURITY.md](SECURITY.md) for how to report security issues without opening a public GitHub issue.

## Documentation

- [Setup Guide](docs/SETUP.md) — Environment variables, prerequisites, configuration
- [Demo Scenarios](docs/SCENARIOS.md) — Four demo scripts with expected outputs
- [Troubleshooting](docs/TROUBLESHOOTING.md) — Common issues and fixes

## License

[Apache 2.0](LICENSE)
