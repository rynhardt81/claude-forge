# Regression Testing Protocol

This document defines the regression testing protocol for the `/implement-features` skill.

---

## Purpose

Regression testing ensures that implementing new features doesn't break existing functionality. Before implementing each new feature, we verify that previously passing features still work.

---

## Core Principles

1. **Test Before Implement** - Always run regression tests BEFORE starting new work
2. **Random Selection** - Select regression candidates randomly to ensure coverage
3. **Fail Fast** - Stop immediately if any regression is detected
4. **Fix First** - Never proceed with new features until regressions are resolved
5. **Minimal Set** - Test 1-2 features per cycle to balance speed and safety

---

## When to Run Regression Tests

### Standard Mode

Run regression tests:
- Before EVERY new feature implementation
- Select 2 random passing features
- Execute all test steps in browser

### YOLO Mode

**No regression tests.** Speed is prioritized over safety.
- User accepts risk of undetected regressions
- Manual testing recommended periodically

### Hybrid Mode

Run regression tests:
- Before features in categories A, C, D, P only
- Select 1 random passing feature
- Execute all test steps in browser

---

## Regression Test Selection

### Selection Algorithm

```python
def select_regression_features(limit=2):
    """
    Select features for regression testing.

    Priority:
    1. Recently passed features (last 10)
    2. Critical category features (A, C, D, P)
    3. Random from all passing features
    """
    features = feature_get_for_regression(limit=limit)
    return features['features']
```

### Selection Criteria

| Priority | Description | Weight |
|----------|-------------|--------|
| 1 | Last 10 passed features | 40% |
| 2 | Critical categories (A, C, D, P) | 30% |
| 3 | Random from all passing | 30% |

### MCP Tool Usage

```python
# Get features for regression testing
result = feature_get_for_regression(limit=2)

# Response:
{
    "features": [
        {
            "id": 23,
            "name": "User login",
            "category": "A",
            "steps": [
                "Navigate to /login",
                "Enter email and password",
                "Click login button",
                "Verify redirect to dashboard"
            ]
        },
        {
            "id": 31,
            "name": "View product list",
            "category": "F",
            "steps": [
                "Navigate to /products",
                "Verify product cards display",
                "Verify pagination controls"
            ]
        }
    ],
    "count": 2
}
```

---

## Executing Regression Tests

### Test Execution Flow

```
For each regression feature:
  1. Log: "Regression test: [ID] [Name]"
  2. Start browser session (if not already running)
  3. Reset application state (logout, clear cart, etc.)
  4. Execute each step sequentially
  5. Verify expected outcome for each step
  6. Log result: PASS or FAIL
  7. If FAIL: Stop immediately, report failure
  8. If PASS: Continue to next feature
```

### Step Execution

```markdown
## Regression Test: ID-23 "User login"

### Setup
- Navigate to base URL
- Ensure logged out state

### Steps

Step 1: "Navigate to /login"
- Action: page.goto('/login')
- Verify: URL is /login
- Result: ✅ PASS

Step 2: "Enter email and password"
- Action: page.fill('[name="email"]', 'test@example.com')
- Action: page.fill('[name="password"]', 'password123')
- Verify: Fields populated
- Result: ✅ PASS

Step 3: "Click login button"
- Action: page.click('button[type="submit"]')
- Verify: Click registered
- Result: ✅ PASS

Step 4: "Verify redirect to dashboard"
- Action: page.waitForURL('**/dashboard')
- Verify: URL contains /dashboard
- Result: ✅ PASS

### Overall Result: ✅ PASSING
```

### Timeout Handling

```python
STEP_TIMEOUT = 30000  # 30 seconds per step
TOTAL_TIMEOUT = 120000  # 2 minutes per feature

# If step times out
if step_timeout:
    take_screenshot('regression-timeout.png')
    mark_as_failed("Step timeout: {step}")
    trigger_regression_failure()
```

---

## Regression Failure Protocol

### Immediate Actions

When a regression test fails:

1. **STOP** - Do not proceed with new feature
2. **SCREENSHOT** - Capture current browser state
3. **LOG** - Record failure details
4. **REPORT** - Notify user immediately

### Failure Report Format

```markdown
## ⚠️ REGRESSION FAILURE DETECTED

**Feature:** ID-23 "User login"
**Category:** A (Security)
**Previously:** PASSING
**Now:** FAILING

### Failing Step
**Step 4:** "Verify redirect to dashboard"

**Expected:** URL contains '/dashboard'
**Actual:** URL is '/login?error=invalid_credentials'

**Screenshot:** regression-failure-id23-step4.png

### Recent Changes
Last 5 commits:
1. `abc1234` feat(auth): add rate limiting - 10 min ago
2. `def5678` fix(api): session token handling - 25 min ago
3. `ghi9012` feat(cart): add item validation - 1 hour ago
4. `jkl3456` docs: update README - 2 hours ago
5. `mno7890` feat(products): search filter - 3 hours ago

### Likely Cause
Commits `abc1234` or `def5678` likely introduced this regression.

### Recommended Actions
1. **Investigate** `abc1234` (rate limiting)
2. **Check** test user isn't rate-limited
3. **Verify** session handling in `def5678`

### Options
1. **Fix** - Investigate and fix the regression
2. **Revert** - Revert to last known good commit
3. **Skip** - Mark feature as needing review (NOT RECOMMENDED)
```

### Recovery Options

#### Option 1: Fix the Regression

```markdown
1. Identify the breaking commit
2. Analyze the change
3. Implement fix
4. Re-run regression test
5. If passes: Resume feature implementation
6. If fails: Try again or escalate
```

#### Option 2: Revert the Change

```bash
# Revert the breaking commit
git revert abc1234

# Re-run regression
# If passes: Investigate original change separately
# Resume feature implementation
```

#### Option 3: Skip (Emergency Only)

```markdown
⚠️ NOT RECOMMENDED

Only use if:
- Regression is in non-critical feature
- Deadline is imminent
- User explicitly approves

Action:
- Log in progress notes
- Create issue for follow-up
- Continue with caution
```

---

## Regression Categories

### Critical (Always Test)

Features in these categories are always included in regression pool:

| Category | Code | Why Critical |
|----------|------|--------------|
| Security | A | Auth/security bugs are severe |
| Data | C | Data corruption is unrecoverable |
| Workflow | D | Core user flows must work |
| Payment | P | Financial impact |

### Standard (Normal Priority)

| Category | Code | Risk Level |
|----------|------|------------|
| Navigation | B | Medium |
| Forms | E | Medium |
| Display | F | Low |
| Search | G | Medium |
| Notifications | H | Low |

### Low Priority (Rarely Test)

| Category | Code | Why Lower |
|----------|------|-----------|
| Settings | I | Rarely changes |
| Analytics | K | Non-blocking |
| Documentation | S | No functionality |
| UI Polish | T | Visual only |

---

## Regression Test Frequency

### Recommended Schedule

| Context | Frequency | Features |
|---------|-----------|----------|
| Before each feature | Every time | 1-2 |
| After 10 features | Extended test | 5 |
| After session | Full regression | All critical |
| Before release | Complete suite | All |

### Feature Count Guidelines

| Total Features | Regression Sample |
|----------------|-------------------|
| < 20 | Test 1 |
| 20-50 | Test 2 |
| 50-100 | Test 2 |
| 100-200 | Test 2-3 |
| 200+ | Test 3 |

---

## State Management

### Clean State Requirements

Before each regression test:

```python
def reset_application_state():
    """
    Reset app to known state for consistent testing.
    """
    # Logout if logged in
    if is_logged_in():
        logout()

    # Clear cart/session
    clear_session_storage()
    clear_local_storage()

    # Clear cookies (optional, may break CSRF)
    # clear_cookies()

    # Navigate to home
    navigate_to('/')
```

### Test User Management

```markdown
## Test Users

Standard test account:
- Email: test@example.com
- Password: password123

Admin test account:
- Email: admin@example.com
- Password: adminpass123

These accounts should:
- Always exist in test database
- Never be rate-limited
- Have predictable state
```

---

## Performance Considerations

### Speed Optimization

```markdown
Regression Test Budget: ~30-60 seconds per feature

Optimizations:
1. Reuse browser session between tests
2. Parallelize where possible (different features)
3. Skip visual verification where not needed
4. Use faster selectors (data-testid)
```

### Timeout Configuration

```python
TIMEOUTS = {
    'navigation': 10000,    # 10s for page loads
    'element': 5000,        # 5s for element appearance
    'action': 3000,         # 3s for click/type
    'step': 30000,          # 30s total per step
    'feature': 120000,      # 2min total per feature
}
```

---

## Integration with Feature Loop

### In Feature Loop (Phase 2)

```python
# Get next feature to implement
feature = feature_get_next()
feature_mark_in_progress(feature['id'])

# Run regression BEFORE implementing
regression_result = run_regression_tests()

if not regression_result.passing:
    # STOP - Don't implement
    report_regression_failure(regression_result)
    await user_decision()  # Fix, Revert, or Skip
    return

# Regression passed - safe to implement
implement_feature(feature)
```

### Regression Skip Conditions

Skip regression tests when:
- YOLO mode enabled
- Hybrid mode AND feature not in critical category
- User explicitly requests `--skip-regression`
- First feature of session (nothing to regress against)

---

## Reporting and Logging

### Regression Log Format

```markdown
## Regression Log: [Timestamp]

### Tests Run
1. ID-23 "User login" (A) - ✅ PASS (12.3s)
2. ID-31 "View products" (F) - ✅ PASS (8.7s)

### Summary
- Total: 2
- Passed: 2
- Failed: 0
- Duration: 21.0s

### Proceeding with: ID-46 "Add to cart"
```

### Failure Log

```markdown
## Regression Failure: [Timestamp]

### Failed Test
ID-23 "User login" (A)

### Step Details
Step 4 failed: "Verify redirect to dashboard"
Expected: /dashboard
Actual: /login?error=invalid_credentials

### Screenshot
regression-failure-20240115-143022.png

### Git Context
HEAD: abc1234 (feat(auth): add rate limiting)
Last passing: xyz9876 (3 commits ago)

### Action Required
Implementation BLOCKED until resolved.
```

---

## Best Practices

### Do

- ✅ Always run regression before implementing
- ✅ Fix regressions immediately
- ✅ Keep test users in known state
- ✅ Log all regression results
- ✅ Screenshot failures

### Don't

- ❌ Skip regressions to save time
- ❌ Ignore "intermittent" failures
- ❌ Proceed with new features if regression fails
- ❌ Clear regression failures without fixing
- ❌ Modify test steps to make them pass

---

## Troubleshooting

### Common Issues

#### "Element not found"

```markdown
Cause: Selector changed or element removed
Fix: Update feature steps to match new UI
```

#### "Timeout waiting for navigation"

```markdown
Cause: Server slow or route changed
Fix: Check server health, verify routes
```

#### "Unexpected redirect"

```markdown
Cause: Auth state or session issue
Fix: Reset app state, check test user
```

#### "Flaky test"

```markdown
Cause: Race condition or timing issue
Fix: Add explicit waits, check async operations
```

### Recovery Commands

```python
# Clear stuck regression state
feature_clear_in_progress(feature_id)

# Skip problematic feature temporarily
feature_skip(feature_id)

# Get detailed feature info
feature = feature_get_by_category(category_code)
```

---

## See Also

- `SKILL.md` - Main skill definition
- `PHASES.md` - Phase details
- `../../agents/quality-engineer.md` - Browser automation details
- `../../agents/developer.md` - Implementation protocol
