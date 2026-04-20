# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly. **Do not open a public GitHub issue.**

Email **security@cloudbees.com** with:

- A description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

You should receive an acknowledgment within 3 business days. We will work with you to understand the issue and coordinate a fix before any public disclosure.

## Scope

This is a community demo project, not a production CloudBees product. Security reports related to the DevOps Agent Kit itself (skills, configurations, documentation) are in scope. For vulnerabilities in CloudBees Unify, the MCP server, or other CloudBees products, please report them through [CloudBees Support](https://www.cloudbees.com/support).

## Security Design

- **Read-only by default**: The MCP server configuration ships with `--toolsets=all=r`, preventing write operations unless explicitly changed by the user.
- **User confirmation required**: Skills that create Jira tickets, post to Slack, or modify feature flags require explicit user approval before executing.
- **No credentials in the repository**: All tokens are loaded from a `.env` file excluded by `.gitignore`. Configuration files reference environment variables only.
