# Severity Inference Rules

## How to Determine Severity

Analyze the bug description against these indicators:

## Critical Severity

**Impact:** Production down, data loss, security vulnerability, blocking all users

**Indicators:**
- Keywords: "production", "down", "outage", "security", "data loss", "urgent", "all users affected"
- HTTP 500 errors in production
- Authentication/authorization failures
- Database connection failures
- Payment processing errors
- Data corruption

**Examples:**
- "Production API returning 500 for all requests"
- "Users can access other users' data"
- "Database connection pool exhausted"
- "Payments failing in production"

**Approach:** Fast Triage (speed over ceremony)

---

## Normal Severity

**Impact:** Feature broken, test failure, errors in logs, some users affected

**Indicators:**
- Keywords: "failing test", "error in logs", "doesn't work", "broken", "regression"
- CI/CD test failures
- Specific feature not working
- Error affecting subset of users/requests
- Non-blocking but significant

**Examples:**
- "test_webhook_delivery failing with ConnectionResetError"
- "Export to CSV returns empty file"
- "Search not returning results for special characters"
- "Rate limiting not applying correctly"

**Approach:** Scientific Method (thorough diagnosis)

---

## Minor Severity

**Impact:** Edge case, cosmetic, non-blocking, easy to work around

**Indicators:**
- Keywords: "edge case", "minor", "cosmetic", "only when", "rare"
- Affects specific edge case only
- Workaround exists
- Low frequency occurrence
- UI/UX issues that don't block functionality

**Examples:**
- "Tooltip shows wrong date format for leap years"
- "Extra whitespace in error message"
- "Sorting breaks with exactly 100 items"
- "Button misaligned on Safari only"

**Approach:** Scientific Method (lighter - skip hypothesize phase)

---

## When Uncertain

Default to **Normal** severity. First checkpoint allows adjustment.

## Escalation Signals

During debugging, escalate to Critical if you discover:
- Bug affects more users than initially thought
- Data integrity is at risk
- Security implications found
