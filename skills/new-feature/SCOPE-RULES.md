# Scope Inference Rules

## How to Determine Scope

Analyze the feature description against these indicators:

## Small Scope Indicators

- Single file change likely
- UI tweak, label change, style adjustment
- Add/modify single field or property
- Simple validation rule
- Configuration change
- Keywords: "add button", "change text", "update style", "fix typo", "rename"

**Examples:**
- "Add a loading spinner to the submit button"
- "Change the error message for invalid email"
- "Add tooltip to the API key field"

## Medium Scope Indicators

- 2-5 files affected
- New API endpoint with basic logic
- New UI component with state
- Integration with existing service
- Moderate business logic
- Keywords: "new endpoint", "new component", "add feature", "integrate"

**Examples:**
- "Add endpoint to fetch user preferences"
- "Create a notification dropdown component"
- "Add rate limit display to the dashboard"

## Large Scope Indicators

- 6+ files affected
- New domain/module
- Database schema changes
- Multiple services affected
- Security implications
- Complex business logic
- Keywords: "new module", "new integration", "refactor", "migrate", "multi-tenant"

**Examples:**
- "Add webhook delivery system with retries"
- "Implement SSO integration with Okta"
- "Add audit logging across all admin endpoints"

## When Uncertain

Default to **medium** scope. The checkpoint after discovery allows adjustment.
