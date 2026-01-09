# Testing Modes

Three testing modes for different project needs: Standard, YOLO, and Hybrid.

---

## Mode Comparison

| Aspect | Standard | YOLO | Hybrid |
|--------|----------|------|--------|
| **Browser Testing** | All features | None | Critical only |
| **Regression Testing** | Every feature | Skipped | Critical only |
| **Verification** | Full end-to-end | Lint + type-check | Mixed |
| **Speed** | Slowest (~5-10 min/feature) | Fastest (~1-2 min/feature) | Medium (~3-5 min/feature) |
| **Confidence** | Highest | Lowest | Medium |
| **Manual Testing Required** | Minimal | Extensive | Moderate |
| **Best For** | Production, critical features | Prototypes, MVPs | Internal tools, balanced approach |

---

## Standard Mode

### Configuration
```bash
/new-project "My app" --mode=standard
```

### Behavior

**All Features:**
- ✅ Full browser automation testing
- ✅ Execute all test steps in feature.steps
- ✅ Take screenshots on success/failure
- ✅ Verify DOM elements, URLs, content
- ✅ Test user interactions (clicks, forms, navigation)

**Regression Testing:**
- ✅ Test 1-2 random passing features before each new feature
- ✅ Catch breaking changes immediately
- ✅ Maintain high quality bar throughout development

**Verification Process:**
```
For each feature:
1. Mark as in-progress
2. Implement code
3. Run lint and type-check
4. Launch browser via Playwright
5. Execute all test steps:
   - Navigate to URL
   - Interact with elements
   - Verify expected state
   - Take success screenshot
6. If all steps pass:
   - Mark as passing
   - Git commit
   - Move to next feature
7. If any step fails:
   - Take failure screenshot
   - Debug and fix
   - Retry from step 4
```

### MCP Requirements
```json
{
  "feature-tracking": "REQUIRED",
  "browser-automation": "REQUIRED"
}
```

### Example Feature Flow
```
Feature: "User can login with email/password"

Steps:
1. Navigate to http://localhost:3000/login
   → Playwright: page.goto('http://localhost:3000/login')

2. Enter email: test@example.com
   → Playwright: page.fill('input[name="email"]', 'test@example.com')

3. Enter password: Test123!
   → Playwright: page.fill('input[name="password"]', 'Test123!')

4. Click login button
   → Playwright: page.click('button[type="submit"]')

5. Verify URL changed to /dashboard
   → Playwright: expect(page.url()).toContain('/dashboard')

6. Verify welcome message
   → Playwright: expect(page.locator('.welcome')).toContainText('Welcome')

✅ All steps passed → Mark as passing
📸 Screenshot saved to: screenshots/feature-23-success.png
```

### When to Use Standard Mode

**Always use for:**
- Production applications
- Customer-facing features
- Security-critical features (auth, payments, data handling)
- Compliance-required projects (healthcare, finance)

**Advantages:**
- Highest confidence in quality
- Catches bugs early
- Automated QA
- Documentation via screenshots
- Regression prevention

**Disadvantages:**
- Slower development (~5-10 min per feature)
- Requires browser automation setup
- More complex debugging when tests fail

---

## YOLO Mode

**"You Only Live Once"** - Rapid prototyping mode with minimal verification.

### Configuration
```bash
/new-project "My prototype" --mode=yolo
```

### Behavior

**All Features:**
- ❌ NO browser automation testing
- ✅ Lint and type-check only
- ❌ No screenshot verification
- ❌ No DOM interaction testing
- ⚠️ Features marked passing after code compiles

**Regression Testing:**
- ❌ Skipped entirely
- ⚠️ Breaking changes may go unnoticed

**Verification Process:**
```
For each feature:
1. Mark as in-progress
2. Implement code
3. Run lint:
   - ESLint (JavaScript/TypeScript)
   - Ruff/Black (Python)
   - Clippy (Rust)
   - etc.
4. Run type-check:
   - TypeScript: tsc --noEmit
   - Python: mypy
   - etc.
5. If lint and type-check pass:
   - Mark as passing (assumed working)
   - Git commit
   - Move to next feature
6. If lint/type-check fails:
   - Fix errors
   - Retry from step 3
```

### MCP Requirements
```json
{
  "feature-tracking": "REQUIRED",
  "browser-automation": "DISABLED"
}
```

### Example Feature Flow
```
Feature: "User can login with email/password"

1. Implement code:
   - Create /api/login endpoint
   - Create LoginForm component
   - Add route to /login

2. Run lint:
   → eslint src/**/*.{ts,tsx}
   ✅ No errors

3. Run type-check:
   → tsc --noEmit
   ✅ No errors

✅ Mark as passing (NOT TESTED, just compiled)
⚠️ Manual testing recommended before production
```

### When to Use YOLO Mode

**Appropriate for:**
- Proof of concepts
- Internal prototypes
- MVPs for user feedback
- Throwaway code
- Learning projects
- Time-constrained hackathons

**Advantages:**
- ~5x faster than standard mode
- Quick iteration
- Less tooling required
- Good for exploring ideas

**Disadvantages:**
- Low confidence in functionality
- No regression detection
- Requires extensive manual testing
- Not suitable for production
- May accumulate bugs

**Important:**
```
⚠️ YOLO mode is NOT a substitute for testing.
   It trades quality for speed.
   Always manually test before shipping.
```

---

## Hybrid Mode

**Best of both worlds** - Full testing for critical features, fast iteration for non-critical.

### Configuration
```bash
/new-project "My internal tool" --mode=hybrid
```

### Behavior

**Critical Features (Browser Tested):**
Categories with full browser automation:
- A. Security & Access Control
- C. Real Data Verification (CRUD operations)
- D. Workflow Completeness (multi-step processes)
- P. Payment & Financial Operations

**Non-Critical Features (Lint Only):**
Categories with lint/type-check only:
- B. Navigation Integrity
- F. Form Input & Validation
- G. Search & Filter
- H. Responsive Design
- I. Performance & Load Times
- K. Notifications & Alerts
- L. User Preferences & Settings
- M. Help & Documentation
- N. Analytics & Tracking
- O. Accessibility & Internationalization
- Q. Admin & Moderation
- R. Collaboration & Sharing
- S. Data Export & Reporting
- T. UI Polish & Aesthetics

**Regression Testing:**
- ✅ Test critical categories only
- ❌ Skip non-critical categories

**Verification Process:**
```
For each feature:
1. Mark as in-progress
2. Implement code
3. Check feature category
4. If category is CRITICAL:
   → Use Standard mode verification (full browser test)
5. Else:
   → Use YOLO mode verification (lint only)
6. Mark as passing
7. Git commit
```

### MCP Requirements
```json
{
  "feature-tracking": "REQUIRED",
  "browser-automation": "REQUIRED"
}
```

### Custom Category Configuration

You can customize which categories are critical:

```markdown
## .claude/memories/testing-mode.txt

Mode: hybrid

Critical Categories (full testing):
- A (Security & Access Control)
- C (Real Data Verification)
- D (Workflow Completeness)
- P (Payment & Financial Operations)
- J (Integration & External Services)  ← Added custom

Non-Critical Categories (lint only):
- [all others]
```

### Example Feature Flow

**Critical Feature:**
```
Feature: "User can login with email/password"
Category: A (Security & Access Control)

→ Use Standard mode verification
→ Full browser testing with Playwright
→ High confidence
```

**Non-Critical Feature:**
```
Feature: "Homepage has smooth scroll animation"
Category: T (UI Polish & Aesthetics)

→ Use YOLO mode verification
→ Lint and type-check only
→ Visual verification recommended
```

### When to Use Hybrid Mode

**Appropriate for:**
- Internal tools (high security, lower polish)
- B2B applications (functionality over aesthetics)
- Admin dashboards
- API-heavy applications
- Projects with tight deadlines but quality requirements

**Advantages:**
- ~2x faster than standard mode
- Still catches critical bugs
- Balances speed and quality
- Flexible (customize critical categories)

**Disadvantages:**
- More complex configuration
- Need to decide what's "critical"
- Non-critical features still need manual testing
- May miss integration issues across categories

---

## Choosing the Right Mode

### Decision Tree

```
Is this going to production?
├─ Yes
│  ├─ Customer-facing?
│  │  ├─ Yes → STANDARD
│  │  └─ No (internal tool) → HYBRID
│  └─ No (prototype/MVP) → YOLO
└─ No (learning/experiment) → YOLO
```

### By Project Type

**E-commerce / SaaS / Public Web App:**
- **Mode:** Standard
- **Reason:** Customer trust, payment processing, data security

**Internal Admin Dashboard:**
- **Mode:** Hybrid
- **Reason:** Security matters, but UI polish less critical

**API Service:**
- **Mode:** Hybrid (custom critical: A, C, J)
- **Reason:** Focus on data and integrations, less on UI

**Proof of Concept:**
- **Mode:** YOLO
- **Reason:** Speed matters most, will be rewritten anyway

**Open Source Library:**
- **Mode:** Standard
- **Reason:** Public reputation, many users depend on it

**Personal Project:**
- **Mode:** YOLO (start) → Standard (before sharing)
- **Reason:** Iterate fast, polish before sharing

---

## Switching Modes

You can switch modes mid-project:

### From YOLO to Standard
```bash
# Re-test all features with browser automation

1. Update .claude/memories/testing-mode.txt:
   Mode: standard

2. Run: /retest-all-features

3. Agent will:
   - Query all "passing" features
   - Re-test each with full browser automation
   - Mark failures for fixing
   - Generate new confidence report
```

### From Standard to YOLO
```bash
# Speed up remaining features

1. Update .claude/memories/testing-mode.txt:
   Mode: yolo

2. Continue: /implement-features

3. Agent will:
   - Use lint-only for remaining features
   - Warn about reduced confidence
   - Suggest manual testing plan
```

### From Hybrid to Standard
```bash
# Increase quality bar

1. Update critical categories to "all"

2. Run: /retest-all-features --categories=non-critical

3. Agent will:
   - Re-test previously lint-only features
   - Upgrade confidence level
```

---

## Mode Configuration Files

### Standard Mode Config
```json
// .claude/mcp-servers/config.json
{
  "mcpServers": {
    "feature-tracking": {
      "command": "python",
      "args": ["-m", "mcp_server.feature_mcp"],
      "env": {"PROJECT_DIR": "."}
    },
    "browser-automation": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "enabled": true
    }
  }
}
```

### YOLO Mode Config
```json
// .claude/mcp-servers/config.json
{
  "mcpServers": {
    "feature-tracking": {
      "command": "python",
      "args": ["-m", "mcp_server.feature_mcp"],
      "env": {"PROJECT_DIR": "."}
    }
    // Note: browser-automation omitted
  }
}
```

### Hybrid Mode Config
```json
// .claude/mcp-servers/config.json
{
  "mcpServers": {
    "feature-tracking": {
      "command": "python",
      "args": ["-m", "mcp_server.feature_mcp"],
      "env": {"PROJECT_DIR": "."}
    },
    "browser-automation": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "enabled": true
    }
  }
}

// .claude/memories/testing-mode.txt
Mode: hybrid
Critical Categories: A,C,D,P
```

---

## Performance Comparison

### 100-Feature Project Timeline

**Standard Mode:**
- Time per feature: 5-10 minutes
- Total time: 500-1000 minutes (8-16 hours)
- Confidence: 95% features work correctly
- Manual testing needed: 5-10 hours

**YOLO Mode:**
- Time per feature: 1-2 minutes
- Total time: 100-200 minutes (2-3 hours)
- Confidence: 60% features work correctly
- Manual testing needed: 30-40 hours

**Hybrid Mode:**
- Time per feature: 3-5 minutes (average)
- Total time: 300-500 minutes (5-8 hours)
- Confidence: 85% features work correctly
- Manual testing needed: 10-15 hours

---

## Recommendations

### For New Projects
Start with **Standard** mode. The upfront investment in browser testing pays off:
- Catches bugs early (cheaper to fix)
- Documents expected behavior
- Builds confidence
- Enables true autonomy

### For Prototypes
Use **YOLO** mode. Speed is paramount:
- Validate ideas quickly
- Get user feedback fast
- Expect to rewrite anyway
- Manual testing is sufficient

### For Internal Tools
Use **Hybrid** mode. Balance is key:
- Test security and data handling thoroughly
- Move fast on UI polish
- Reduce manual testing burden
- Maintain professional quality

---

## Mode Indicators

The agent will display mode in progress output:

```
Standard Mode:
═══════════════════════════════════════════
Features: 23/100 complete (23%)
Testing: STANDARD (full browser automation)
Last feature: ✅ User can login (5.2 min)
═══════════════════════════════════════════

YOLO Mode:
═══════════════════════════════════════════
Features: 67/100 complete (67%)
Testing: YOLO (lint only, ⚠️ manual testing required)
Last feature: ✅ User can add item (1.3 min)
═══════════════════════════════════════════

Hybrid Mode:
═══════════════════════════════════════════
Features: 45/100 complete (45%)
Testing: HYBRID (23 browser-tested, 22 lint-only)
Last feature: ✅ User preferences saved (2.1 min)
═══════════════════════════════════════════
```

---

## Notes

- Mode can be changed at any time
- Browser automation requires Playwright setup
- YOLO mode is not recommended for production
- Hybrid mode requires thoughtful category selection
- All modes use feature database for tracking
- Screenshots saved in `screenshots/` directory (Standard/Hybrid only)
