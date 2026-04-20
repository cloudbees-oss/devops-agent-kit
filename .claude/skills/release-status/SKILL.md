---
name: release-status
description: >
  Check release readiness across all components. Verifies CI status, security
  gates, and feature flag states for a go/no-go decision.
argument-hint: "[application-name or empty for all]"
---

## Release Status: $ARGUMENTS

1. `components_list` — get all components in the organization
2. For each component:
   a. `workflow_list` — identify CI and release workflows
   b. `runs_list(limit=5)` — get latest run status per workflow
      Skip code_scan workflows.
   c. `security_issues_open_get` or `security_findings_summary_get` —
      check for open vulnerabilities on the default branch
   d. `branches_list` — verify the default branch

3. Check release orchestration:
   a. Look for components with release/deploy workflows
      (workflow_dispatch triggers, staged deployments)
   b. `automation_jobs_list` — check for staged deployment jobs
      (staging -> approval -> production pattern)
   c. Check for PENDING_APPROVAL jobs — these are deployment gates
      waiting on human sign-off

4. Check feature flags:
   a. `flags_applications_list` — find flag applications
   b. `flags_environments_list` — list environments (staging, production)
   c. `flags_configurations_list` — check flag states per environment

5. Present a release readiness report:

   **Release Readiness Report**
   **Date:** [timestamp]
   **Verdict:** READY / NOT READY / BLOCKED

   | Component | CI Status | Security | Flags | Blocker |
   |-----------|-----------|----------|-------|---------|
   | name      | GREEN/RED | N HIGH   | state | desc    |

   Blockers by Priority:
   1. [Highest priority blocker with specific details]
   2. [Next blocker]
   ...

   What Must Be Done Before Release:
   - [ ] Specific action item 1
   - [ ] Specific action item 2

6. Offer next actions:
   - "/triage [component]" for any red component
   - "/security-scan [component]" for components with findings
   - "/flag-rollout [flag] enable" to activate flags for release
   - Post release readiness to Slack
   - Trigger release workflow via `workflow_trigger` (with explicit
     user confirmation — show which workflow will be triggered and
     what it will do before executing)
