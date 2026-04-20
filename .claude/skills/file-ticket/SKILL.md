---
name: file-ticket
description: >
  Create a Jira ticket from a build failure, security finding, or
  improvement recommendation.
argument-hint: "[type: failure|security|improvement] [description]"
---

## File Jira Ticket

Parse arguments to determine issue type and description.

1. If the agent has recent triage/scan context, use it. Otherwise, ask
   which component and issue to reference.

2. Build the Jira ticket:

   **For build failures:**
   - Summary: "[Build Failure] {component} — {root_cause_summary}"
   - Description: Root cause analysis, failing step, log excerpt (if available),
     fix recommendation, link to run
   - Labels: build-failure, devops-agent
   - Priority: High if blocking all builds, Medium if intermittent

   **For security findings:**
   - Summary: "[Security] {component} — {finding_type} in {file_path}"
   - Description: Finding details (severity, scanner, file, line), SLA due date,
     remediation steps, affected environments
   - Labels: security, devops-agent
   - Priority: based on severity (Critical/High = High, Medium = Medium, Low = Low)

   **For improvements:**
   - Summary: "[Improvement] {description}"
   - Description: Current state, proposed change, expected impact,
     implementation steps
   - Labels: improvement, devops-agent
   - Priority: Medium (default)

3. Show the ticket preview and ask for confirmation
4. Create via `mcp__mcp-atlassian__jira_create_issue`
5. Confirm with ticket URL
6. Offer to:
   - Post the ticket link to Slack
   - Add the ticket as a GitHub issue comment on the relevant PR
