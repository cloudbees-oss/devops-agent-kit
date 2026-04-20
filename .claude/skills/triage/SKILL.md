---
name: triage
description: >
  Analyze the latest failed CI run for a component. Identifies failing jobs
  and steps, reads logs, determines root cause, and classifies the failure.
argument-hint: "[component-name]"
---

## Triage Failed Run: $ARGUMENTS

1. Search for the component using `components_search`
2. Pull recent runs using `runs_list(limit=10)`
3. Filter for FAILED runs. Skip any with workflow names containing "code_scan"
4. For the latest failed run:
   a. `automation_jobs_list` — list all jobs and their statuses
   b. For each failed job, identify the failing step
   c. `logs_list` — attempt to pull logs from the failing step
      NOTE: If this returns a 500 error, proceed without logs. Analyze
      based on step names, statuses, and durations instead.
   d. `workflow_get_content` — read the workflow YAML to understand what
      each step does and identify configuration issues

5. Classify the failure:
   - **CONFIG**: Workflow/pipeline configuration error (missing inputs,
     invalid action references, YAML syntax). Look for validation errors.
   - **CODE**: Compilation failure or test failure caused by a code change.
     Check if earlier steps (build, compile) passed.
   - **SECURITY**: Security scan gate failure (Gitleaks, SAST, SCA).
     Cross-reference with `security_findings_summary_get`.
   - **ENVIRONMENT**: Infrastructure issue — timeouts, connection refused,
     resource exhaustion, runner unavailability.
   - **KNOWN**: Matches a pattern from previous triage (same step, same error).

6. Enrich with security context:
   a. `security_findings_summary_get` — check if the component has open
      security findings that may be related to the failure

7. Present a structured triage report:
   - Run ID, workflow name, trigger, timestamp
   - Step-by-step results table (step name, status, duration)
   - Root cause analysis with specific evidence
   - Classification (CONFIG/CODE/SECURITY/ENVIRONMENT/KNOWN)
   - Fix recommendation

8. Offer next actions:
   - File a Jira ticket for the issue (`/file-ticket`)
   - Post the summary to Slack
   - Comment on the relevant GitHub PR
   - If the fix is a workflow config change, offer to apply it via
     `workflow_update_content` (with user confirmation)
