---
name: pipeline-overview
description: >
  Show a unified view of all CI/CD pipelines across Jenkins, GitHub Actions,
  and CloudBees Workflows. The cross-tool picture no single tool can provide.
argument-hint: "[component-name or 'all']"
---

## Pipeline Overview: $ARGUMENTS

Show the user a unified view of their CI/CD pipelines across all tools.

1. If the user specified a component name, search for it using
   `components_search`. Otherwise, list all components with `components_list`.

2. For each component, gather:
   a. `workflow_list` — all configured workflows (CloudBees + GitHub Actions)
   b. `runs_list(limit=3)` — the 3 most recent runs per workflow
   c. Skip any workflows with names containing "code_scan" — these are
      infrastructure-managed scans, not user pipelines

3. Get controller data:
   a. `controllers_list` — find Jenkins controllers
   b. For each controller: `controllers_data_get(ci4)` — runs overview
      (active runs, queued, wait times)

4. Get security context:
   a. `security_issues_all_get` — open vulnerability count per component

5. Get feature flag context:
   a. `flags_applications_list` — find flag applications
   b. For each application: `flags_list` — count of active flags

6. Present a unified dashboard:

   **Organization Pipeline Status**

   | Component | GitHub Actions | CloudBees Workflow | Jenkins | Security | Flags |
   |-----------|---------------|-------------------|---------|----------|-------|
   | name      | #N PASS/FAIL  | #N PASS/FAIL      | status  | N HIGH   | N active |

   For each component, show:
   - Latest run status per CI tool (pass/fail/running)
   - Open security findings count and max severity
   - Active feature flags
   - Any blockers or issues

7. Provide a summary:
   - Components green vs. red
   - Cross-tool patterns (e.g., "GitHub Actions healthy but CloudBees
     Workflows failing on all 3 components — likely a common config issue")
   - Top recommendations

8. Offer next actions:
   - "/triage [component]" for any failed component
   - "/security-scan all" if security findings exist
   - "/release-status" if all components are green
