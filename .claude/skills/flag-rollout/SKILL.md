---
name: flag-rollout
description: >
  Manage feature flags — list, inspect, enable, disable, or create flags.
  Supports progressive rollout workflows.
argument-hint: "[flag-name] [action: list|status|enable|disable|create]"
---

## Flag Rollout: $ARGUMENTS

Parse the arguments to determine action and target.

### Action: list (default if no flag name given)

1. `flags_applications_list` — find all flag applications
2. For each application: `flags_list` — list all flags
3. `flags_environments_list` — list all environments
4. For each environment: `flags_configurations_list` — get flag states
5. Present a flag inventory:

   **Feature Flags — [Application Name]**

   | Flag | Type | Production | Staging | Default Value |
   |------|------|------------|---------|---------------|
   | name | Bool | ON/OFF     | ON/OFF  | value         |

### Action: status [flag-name]

1. `flags_applications_list` then `flags_get_by_name` — find the flag
2. `flags_environments_list` — list environments
3. `flags_configurations_list` — get configuration per environment
4. Present detailed flag status:
   - Flag name, type, description, labels
   - State in each environment (enabled/disabled, default value)
   - Whether the flag is permanent or temporary

### Action: enable [flag-name] [environment]

1. Find the flag using `flags_get_by_name`
2. Find the environment using `flags_environments_list`
3. Show current state and what will change
4. **Ask for confirmation** — "Enable [flag] in [environment]?"
5. `flags_configuration_state_update(enabled=true)` — enable the flag
6. Confirm the change
7. Offer to post the change to Slack

### Action: disable [flag-name] [environment]

Same as enable, but with `flags_configuration_state_update(enabled=false)`

### Action: create [flag-name]

1. `flags_applications_list` — find the target application
2. Ask the user for: flag type (Boolean/String/Number), description, labels
3. `flags_add` — create the flag
4. Confirm creation with flag ID
5. Offer to enable it in an environment

### Safety guardrails for flag changes:
- Always show current state before any change
- Always ask for confirmation before enable/disable
- After any change, verify the new state with `flags_configurations_list`
- If changing production flags, add an extra warning: "This will affect
  production traffic. Confirm?"
