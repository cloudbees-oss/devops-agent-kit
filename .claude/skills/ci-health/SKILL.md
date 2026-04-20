---
name: ci-health
description: >
  Generate a CI health report for a component or the entire organization.
  Uses controller analytics, run history, and security posture.
argument-hint: "[component-name or 'org']"
---

## CI Health Report: $ARGUMENTS

1. `controllers_list` — find all CI controllers (Jenkins instances)

2. For each controller, pull analytics:
   a. `controllers_data_get(ci2)` — System Information (version, plugins,
      nodes, executors)
   b. `controllers_data_get(ci3)` — System Health (disk, threads, plugins)
   c. `controllers_data_get(ci4)` — Runs Overview (active, queued, wait times)
   NOTE: ci5, ci6, ci7 may return empty data. If they do, skip gracefully.
   d. `report_drilldown_get(pluginsInfo)` — plugin health details

3. If specific component:
   a. `components_search` — find the component
   b. `runs_list(limit=20)` — pull recent run history
   c. Calculate pass rate from run statuses
   d. `security_issues_all_get` — security posture

4. If 'org':
   a. `components_list` — all components
   b. Per component: `runs_list(limit=10)` — recent runs
   c. `security_issues_all_get` — org-wide security

5. Calculate and report:
   - **Pass rate**: Per CI tool, per component. Break out GitHub Actions
     vs. CloudBees Workflows vs. Jenkins.
   - **Failure patterns**: Common failure steps/categories across runs
   - **Controller health**: System health score, plugin status, version
   - **Security posture**: Open findings count and severity
   - **Queue time**: From ci4 — how long runs wait before starting

6. Provide a "CI Health Score" (0-100) based on:
   - Pass rate (weight: 35%)
   - Controller health (weight: 20%)
   - Security posture (weight: 25%)
   - Queue efficiency (weight: 20%)

7. List top 3 actionable recommendations
8. Offer next actions:
   - "/triage [component]" for components with low pass rates
   - "/security-scan" if security posture is poor
   - Post health report to Slack
