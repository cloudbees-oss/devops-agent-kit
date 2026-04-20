---
name: security-scan
description: >
  Analyze security posture across components. Shows vulnerabilities by
  severity, scanner type, SLA status, and remediation priority.
argument-hint: "[component-name or 'all']"
---

## Security Scan: $ARGUMENTS

### If "all" or no argument:

1. `security_issues_all_get` — get all open security issues across the org
2. `components_list` — get all components for cross-referencing
3. For each component with findings:
   a. `branches_list` — find the default branch
   b. `security_findings_summary_get` — severity breakdown
   c. `security_issues_open_get` — detailed finding list
   d. `runs_list(limit=3)` — check if recent scans ran successfully

4. Get org-level security reports:
   a. `organizations_suborg_report(s1)` — components with scanner coverage
   b. `organizations_suborg_report(s2)` — workflows with scanner coverage
   c. `organizations_suborg_report(s6)` — scan types in automations
   d. `organizations_suborg_report(s8)` — SLA status
   NOTE: s4 and s5 may return "No Data Found" at the org level.
   Use component-level tools instead if this happens.

5. Present a security dashboard:

   **Organization Security Posture**

   | Component | Critical | High | Medium | Low | Scanner | SLA Status |
   |-----------|----------|------|--------|-----|---------|------------|
   | name      | N        | N    | N      | N   | type    | On track   |

   Scanner coverage: N of M components (X%)
   Workflow coverage: N of M workflows (X%)
   Scan types active: SAST / DAST / SCA / Container

6. For each finding, include: finding type, file path, line number, SLA due date
7. Rank findings by priority: Critical > High with approaching SLA > High > Medium > Low
8. Provide remediation recommendations

### If specific component:

1. `components_search` — find the component
2. `branches_list` — find branches
3. `security_findings_summary_get` — severity breakdown for default branch
4. `security_issues_open_get` — all open issues with details
5. `runs_list(limit=5)` — recent scan run history

6. Present component-level security report with:
   - Finding details (type, file, line, severity, SLA)
   - Scan history (when last scanned, scan frequency)
   - Remediation steps specific to each finding type

7. Offer next actions:
   - "/file-ticket security [finding]" for high-priority findings
   - Post security summary to Slack
   - Check if a fix branch exists in GitHub
