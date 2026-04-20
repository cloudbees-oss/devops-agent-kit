# Demo Scenarios

Four scenarios that demonstrate the DevOps Agent's capabilities. Each builds on the previous one, but they can also be run independently.

---

## Scenario 1: "What's happening across my pipelines?"

**The hero demo.** Shows unified cross-tool pipeline visibility — the heterogeneous CI story that no single-tool vendor can replicate.

### Setup
- Meridian demo org with 1 application (Meridian Payment Platform) and 3 service components across Jenkins, GitHub Actions, and CloudBees Workflows
- Ensure recent CI runs exist (push a small commit to trigger fresh GHA runs if needed)

### Script

```
You: Show me what's happening across all our pipelines.
```

The agent runs `/pipeline-overview all` and:

1. Discovers the Meridian Payment Platform application and its 3 linked components
2. Pulls workflows and recent runs per component (GHA + CloudBees Workflows)
3. Checks the Meridian_Jenkins_OSS controller status (version, health, queue)
4. Pulls security findings and feature flag state
5. Presents a unified dashboard table

**Expected output:**

| Component | GitHub Actions | CloudBees Workflow | Jenkins | Security | Flags |
|-----------|---------------|-------------------|---------|----------|-------|
| meridian-payment-api | PASS | FAIL | — | 3 HIGH | 4 (platform) |
| meridian-web-portal | PASS | FAIL | — | 4 HIGH | 4 (platform) |
| meridian-account-service | — (Jenkins only) | FAIL | OSS controller | 0 | 4 (platform) |

- GitHub Actions passing on both GHA-enabled components
- CloudBees Workflows failing on all 3 service components
- Jenkins controller: 2.541.2, healthy, 2 idle executors
- 7 HIGH security findings (Gitleaks) across 2 components
- 4 feature flags: `instant-transfers` (ON in production), `dark-mode`, `new-dashboard`, `beta-payments-v2`

### Follow-up

```
You: Triage the web-portal failures.
```

The agent runs `/triage meridian-web-portal` and identifies the root cause: CloudBees Workflow `ci.yaml` fails at validation — the `publish-test-results` action requires a `folder-name` input but the workflow provides `path`. Classifies as CONFIG and recommends a specific YAML fix.

### Cross-tool actions

```
You: File a Jira ticket for this and post to Slack.
```

The agent creates a structured Jira ticket in the SCRUM project with root cause, failing step, and fix recommendation, then posts a summary to the specified Slack channel.

**Why it's compelling:** One question gives you a cross-tool picture that would take 15 minutes of clicking through three separate dashboards. The agent spots the pattern: GitHub Actions healthy but CloudBees Workflows failing on all components — likely a common config issue.

---

## Scenario 2: "Are we secure?"

**The DevSecOps demo.** Shows security posture assessment with cross-reference to CI status and feature flags.

### Script

```
You: Give me the security posture across all our components.
```

The agent runs `/security-scan all` and:

1. Pulls all open security issues
2. Gets severity breakdowns per component
3. Checks scanner coverage and SLA status
4. Cross-references with feature flag state

**Expected output:**

| Component | HIGH | Scanner | Details |
|-----------|------|---------|---------|
| meridian-payment-api | 3 | Gitleaks | Private Key (`gateway.ts:19`), Stripe Token (`gateway.ts:7`), API Key (`gateway.ts:8`) |
| meridian-web-portal | 4 | Gitleaks | API Keys in `analytics.ts:7`, `analytics.ts:14`, `dist/index.js:72`, `.env:1` |
| meridian-account-service | 0 | — | Clean |

- All 7 findings are UNREVIEWED with SLA tracking active
- Scanner coverage: SAST active in 4 workflows, 6 workflow runs
- SLA status: all WITHIN (due within 35 days of first detection)

### Follow-up

```
You: File tickets for the critical findings.
```

The agent creates structured Jira tickets with severity, file paths, SLA dates, and remediation steps.

**Why it's compelling:** Combines security scanning data with CI status, feature flags, and project management in one view.

---

## Scenario 3: "Ship the release"

**The progressive delivery demo.** Shows release orchestration + feature flags + security gates.

### Script

```
You: Is the release candidate ready? Walk me through the deployment.
```

The agent runs `/release-status` and:

1. Checks all components: CI status, security findings, flag states
2. Identifies the release orchestration workflow
3. Generates a go/no-go report

**Expected output:**

Release Readiness Report — **Verdict: NOT READY**

| Component | GHA CI | CB Workflow | Security | Blocker |
|-----------|--------|------------|----------|---------|
| meridian-payment-api | PASS | FAIL | 3 HIGH (SLA active) | CI + Security |
| meridian-web-portal | PASS | FAIL | 4 HIGH (SLA active) | CI + Security |
| meridian-account-service | — (Jenkins) | FAIL | 0 | CI |

Feature flag states per environment:
- `instant-transfers`: ON in Production, default in Staging
- `dark-mode`, `new-dashboard`, `beta-payments-v2`: default (code) in both

Blockers: 7 HIGH security findings, all CB Workflows failing, 3 new flags not yet configured for environments.

### After resolving blockers

```
You: Blockers are fixed. Enable dark-mode in staging.
```

The agent runs `/flag-rollout dark-mode enable staging`:
- Shows current state (default/code)
- Confirms the environment (Staging)
- Waits for confirmation
- Enables the flag
- Offers to post to Slack

```
You: Now enable it in production.
```

- Agent warns: "This will affect production traffic. Confirm?"
- Progressive rollout: Staging first, then Production

**Why it's compelling:** Progressive delivery end-to-end — release orchestration + feature flags + security gates, all from the IDE.

---

## Scenario 4: "Morning standup briefing"

**The full-breadth demo.** Chains all skills into one synthesized output.

### Script

```
You: Give me the morning briefing — what do I need to know?
```

The agent chains multiple skills:

1. **Pipeline status** — `/pipeline-overview all` (quick summary)
2. **Security update** — `/security-scan all` (changes since last check)
3. **CI health** — `/ci-health org` (health score, controller status)
4. **Release status** — `/release-status` (blockers, readiness)
5. **Feature flags** — current flag states

**Expected output:**

A synthesized briefing with:
- CI Health Score: 62/100
- Jenkins controller: healthy (100%), version 2.541.2, 71 plugins, 1 update available
- Per-tool pass rates: GitHub Actions 100%, CloudBees Workflows 0%
- Security: 7 HIGH findings, SLA active, all UNREVIEWED
- Release: NOT READY — 3 blockers (CI failures, security findings, unconfigured flags)
- Recommended focus: fix CB Workflow config, triage security findings before SLA deadline

### Follow-up

```
You: Post the briefing to the #engineering Slack channel.
```

**Why it's compelling:** Shows the agent as a true DevOps copilot that synthesizes across all tools, not a single-purpose utility.
