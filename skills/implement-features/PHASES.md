# Implement Features: Phase Details

This document provides detailed instructions for each phase of the `/implement-features` skill.

---

## Phase 1: Session Initialization

**Purpose:** Establish context, verify state, and prepare for implementation.

### 1.1 Query Current State

```python
# Get current progress
stats = feature_get_stats()

# Example response:
{
    "passing": 45,
    "in_progress": 0,
    "total": 92,
    "percentage": 48.9
}
```

### 1.2 Read Progress Notes

Location: `.claude/memories/progress-notes.md`

Extract from progress notes:
- Last session summary
- Known blockers
- Skipped features and reasons
- Architecture decisions made
- Testing mode preferences

### 1.3 Check for Stale In-Progress Features

```python
if stats['in_progress'] > 0:
    # Session may have crashed
    # Get the in-progress feature
    feature = feature_get_next()  # Returns in-progress first

    # Options:
    # 1. Clear and restart: feature_clear_in_progress(feature['id'])
    # 2. Resume implementation
    # 3. Ask user
```

**Recovery Decision Matrix:**

| Scenario | Action |
|----------|--------|
| Code exists, tests pass | Mark passing, continue |
| Code exists, tests fail | Resume debugging |
| No code changes | Clear lock, restart |
| Unsure | Ask user |

### 1.4 Review Recent Git History

```bash
git log --oneline -5
```

Verify:
- Last commit matches expected feature
- No uncommitted changes blocking progress
- Branch is clean

### 1.5 Verify Dev Server

```bash
# Check if server is running (for browser tests)
curl -s http://localhost:3000 > /dev/null && echo "Server running" || echo "Server not running"
```

If not running and testing mode requires browser:
```bash
npm run dev &
# Wait for server startup
sleep 5
```

### 1.6 Display Session Summary

```markdown
## Session Initialization Complete

**Project:** [Name]
**Progress:** 45/92 features (48.9%)
**Testing Mode:** Standard

**Last Session:**
- Completed: 8 features
- Last feature: ID-45 "Shopping cart display"

**This Session:**
- Starting from: ID-46 "Add item to cart"
- Estimated features: 10-15

**Status:** Ready to begin
```

---

## Phase 2: Feature Loop

**Purpose:** Implement features one at a time with quality gates.

### 2.1 Get Next Feature

```python
feature = feature_get_next()

# Example response:
{
    "id": 46,
    "priority": 2,
    "category": "D",
    "name": "Add item to shopping cart",
    "description": "Users can add products to their cart from product detail page",
    "steps": [
        "Navigate to product detail page",
        "Click 'Add to Cart' button",
        "Verify success message appears",
        "Verify cart count increases"
    ],
    "passes": false,
    "in_progress": false
}
```

### 2.2 Mark In-Progress

```python
feature_mark_in_progress(feature['id'])
```

This locks the feature to prevent duplicate work in parallel sessions.

### 2.3 Run Regression Tests

**Before implementing, verify existing features still work.**

```python
# Get 1-2 random passing features
regression_features = feature_get_for_regression(limit=2)
```

For each regression feature:
1. Execute test steps in browser
2. Verify all steps pass
3. If ANY step fails: **STOP IMMEDIATELY**

See `REGRESSION.md` for detailed regression protocol.

### 2.4 Route to Agent by Category

**Agent Routing Table:**

| Category | Primary Agent | Supporting Agent |
|----------|---------------|------------------|
| A - Security | @security-boss | @developer |
| B - Navigation | @developer | - |
| C - Data (CRUD) | @developer | @api-tester |
| D - Workflow | @developer | @quality-engineer |
| E - Forms | @developer | - |
| F - Display | @developer | - |
| G - Search | @developer | - |
| H - Notifications | @developer | - |
| I - Settings | @developer | - |
| J - Integration | @developer | @api-tester |
| K - Analytics | @developer | - |
| L - Admin | @developer | @security-boss |
| M - Performance | @performance-enhancer | - |
| N - Accessibility | @developer | - |
| O - Error Handling | @developer | - |
| P - Payment | @security-boss | @developer |
| Q - Communication | @developer | - |
| R - Media | @developer | - |
| S - Documentation | @developer | - |
| T - UI Polish | @whimsy | @developer |

### 2.5 Implementation Process

**@developer receives:**
```markdown
## Feature Implementation Request

**ID:** 46
**Category:** D (Workflow)
**Name:** Add item to shopping cart

**Description:**
Users can add products to their cart from product detail page

**Test Steps:**
1. Navigate to product detail page
2. Click 'Add to Cart' button
3. Verify success message appears
4. Verify cart count increases

**Testing Mode:** Standard (browser verification required)

**Instructions:**
1. Implement the feature
2. Ensure code compiles
3. Run lint and type-check
4. Hand off to @quality-engineer for browser verification
```

**@developer implementation checklist:**
- [ ] Understand feature requirements
- [ ] Plan implementation approach
- [ ] Write code changes
- [ ] Verify lint passes: `npm run lint`
- [ ] Verify types pass: `npm run typecheck`
- [ ] Self-test in browser (informal)
- [ ] Hand off to @quality-engineer

### 2.6 Verification Process

**Based on Testing Mode:**

#### Standard Mode
```markdown
@quality-engineer receives:
- Feature ID and test steps
- Pre-verified lint/type status

@quality-engineer executes:
1. Start browser session
2. Execute each test step
3. Verify expected outcomes
4. Take completion screenshot
5. Return pass/fail status
```

#### YOLO Mode
```markdown
No @quality-engineer involvement.
Mark as passing after:
- npm run lint (passes)
- npm run typecheck (passes)
```

#### Hybrid Mode
```markdown
If category in [A, C, D, P]:
  → Standard mode (full browser test)
Else:
  → YOLO mode (lint only)
```

### 2.7 Handle Failures

**Implementation Failure:**
```markdown
Attempt 1: Implement → Fail
  ↓ Analyze error
Attempt 2: Fix → Test → Fail
  ↓ Try different approach
Attempt 3: Fix → Test → Fail
  ↓ Skip feature
feature_skip(feature['id'])
Log blocker in progress notes
Continue with next feature
```

**Test Failure:**
```markdown
Step fails → Analyze failure
  ↓
Is it a bug in implementation?
  → Yes: Fix and re-test
  → No: Is it environment issue?
      → Yes: Fix environment, re-test
      → No: Log as blocked, skip
```

### 2.8 Mark Passing

Only after ALL verification passes:

```python
feature_mark_passing(feature['id'])
```

### 2.9 Git Commit

```bash
git add .
git commit -m "feat(workflow): add item to shopping cart

- Add AddToCart component
- Connect to cart context
- Show success toast on add

Feature-ID: 46
Testing: Standard mode - browser verified

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**Commit Message Format:**
```
feat(<category>): <short description>

<bullet points of implementation details>

Feature-ID: <id>
Testing: <mode> - <verification method>
```

**Category Mapping for Commits:**
| Category Code | Commit Scope |
|---------------|--------------|
| A | auth, security |
| B | nav, routing |
| C | data, crud |
| D | workflow |
| E | forms |
| F | display, ui |
| G | search |
| H | notifications |
| I | settings, config |
| J | integration, api |
| K | analytics |
| L | admin |
| M | perf |
| N | a11y |
| O | error |
| P | payment, billing |
| Q | email, sms |
| R | media, files |
| S | docs |
| T | ui, animation |

### 2.10 Check for Checkpoint

```python
features_this_session += 1

if features_this_session % 10 == 0:
    trigger_checkpoint()
```

### 2.11 Loop Control

```python
# Check if more features
stats = feature_get_stats()

if stats['passing'] == stats['total']:
    # All features complete!
    trigger_completion()
else:
    # Continue to next feature
    continue_loop()
```

---

## Phase 3: Checkpoint

**Purpose:** Pause, report progress, and get user input.

### 3.1 Trigger Conditions

Checkpoint triggers when:
- 10 features completed in current session
- User requests checkpoint (`*checkpoint`)
- Critical error encountered
- Session duration exceeds 2 hours

### 3.2 Checkpoint Report

```markdown
## Checkpoint Report

**Progress:** 50/92 features (54.3%)
**This Session:** 10 features completed
**Time Elapsed:** 45 minutes

### Last 5 Completed Features
| ID | Category | Name | Status |
|----|----------|------|--------|
| 46 | D | Add item to cart | ✅ |
| 47 | D | Remove item from cart | ✅ |
| 48 | D | Update cart quantity | ✅ |
| 49 | F | Cart summary display | ✅ |
| 50 | F | Cart item list | ✅ |

### Next 5 Pending Features
| ID | Category | Name | Priority |
|----|----------|------|----------|
| 51 | G | Search products | 2 |
| 52 | G | Filter by category | 2 |
| 53 | G | Sort results | 3 |
| 54 | F | Product grid view | 3 |
| 55 | F | Product list view | 3 |

### Session Notes
- No blockers encountered
- Cart features complete
- Moving to search functionality

### Options
1. **Continue** - Resume with feature 51
2. **Pause** - Save progress and exit
3. **Adjust** - Re-prioritize or skip features
4. **Review** - Deep-dive into specific feature
```

### 3.3 User Options

#### Continue
```markdown
User: "Continue"

Response:
- Reset session counter
- Resume feature loop
- Target next 10 features
```

#### Pause
```markdown
User: "Pause"

Response:
- Update progress notes
- Commit progress notes
- Display session summary
- Exit gracefully
```

#### Adjust
```markdown
User: "Adjust - skip search features for now"

Response:
- feature_skip(51)
- feature_skip(52)
- feature_skip(53)
- Update progress notes with reason
- Resume with feature 54
```

#### Review
```markdown
User: "Review feature 48"

Response:
- Display feature details
- Show implementation summary
- Show test results
- Offer to re-test or modify
```

### 3.4 Checkpoint Timeout

If user doesn't respond within 5 minutes:
```markdown
## Checkpoint Timeout

No response received. Options:
1. Type 'continue' to resume
2. Type 'pause' to exit gracefully
3. Session will auto-pause in 5 minutes

[Auto-pause in 5:00...]
```

---

## Phase 4: Session End

**Purpose:** Clean up, persist state, and prepare for future resume.

### 4.1 Trigger Conditions

Session ends when:
- All features complete
- User requests pause
- Checkpoint timeout
- Critical unrecoverable error
- Context limit approaching

### 4.2 Update Progress Notes

Location: `.claude/memories/progress-notes.md`

```markdown
## Session: [Date/Time]

### Summary
- Features completed: 10 (ID-46 through ID-55)
- Total progress: 55/92 (59.8%)
- Testing mode: Standard
- Duration: ~50 minutes

### Completed This Session
- [46] Add item to cart ✅
- [47] Remove item from cart ✅
- [48] Update cart quantity ✅
- [49] Cart summary display ✅
- [50] Cart item list ✅
- [51] Search products ✅
- [52] Filter by category ✅
- [53] Sort results ✅
- [54] Product grid view ✅
- [55] Product list view ✅

### Blockers
- None this session

### Skipped Features
- None this session

### Notes for Next Session
- Cart and search features complete
- Next: Start on user account features
- Consider switching to Hybrid mode for settings (Category I)

### Architecture Decisions
- Used React Query for search caching
- Cart state in Zustand store

### Next Feature
ID-56: User profile page (Category D)
```

### 4.3 Commit Progress Notes

```bash
git add .claude/memories/progress-notes.md
git commit -m "docs: update progress notes

Session completed: 10 features (ID-46 to ID-55)
Progress: 55/92 (59.8%)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### 4.4 Display Session Summary

```markdown
## Session Complete

### Statistics
| Metric | Value |
|--------|-------|
| Features Completed | 10 |
| Starting Progress | 45/92 (48.9%) |
| Ending Progress | 55/92 (59.8%) |
| Regressions | 0 |
| Skipped | 0 |
| Blocked | 0 |

### Git Commits
- feat(workflow): add item to cart (ID-46)
- feat(workflow): remove item from cart (ID-47)
- feat(workflow): update cart quantity (ID-48)
- feat(display): cart summary (ID-49)
- feat(display): cart item list (ID-50)
- feat(search): search products (ID-51)
- feat(search): filter by category (ID-52)
- feat(search): sort results (ID-53)
- feat(display): product grid view (ID-54)
- feat(display): product list view (ID-55)
- docs: update progress notes

### Resume Command
To continue: `/implement-features --resume`

### All Features Complete?
❌ No - 37 features remaining
```

### 4.5 Clean Up

```python
# Ensure no features left in-progress
stats = feature_get_stats()
if stats['in_progress'] > 0:
    # Shouldn't happen, but clear if so
    feature = feature_get_next()
    feature_clear_in_progress(feature['id'])
```

### 4.6 Exit Message

```markdown
Session ended successfully. Progress saved.

**Quick Stats:**
- Progress: 55/92 features (59.8%)
- Next: ID-56 "User profile page"

To resume: `/implement-features --resume`
```

---

## Phase Transitions

### Init → Loop
Automatic after initialization complete and first `feature_get_next()`.

### Loop → Checkpoint
When `features_this_session % 10 == 0`.

### Checkpoint → Loop
When user selects "Continue".

### Checkpoint → End
When user selects "Pause" or timeout.

### Loop → End
When all features complete or critical error.

### Any → End
User can always request pause with `*pause` or `/stop`.

---

## Error Recovery

### Mid-Feature Crash

If session crashes during feature implementation:

1. On resume, `feature_get_next()` returns in-progress feature
2. Check git status for uncommitted changes
3. Evaluate state:
   - If implementation incomplete: Resume
   - If tests failing: Debug
   - If unclear: Clear lock and restart

### Regression Failure

If regression test fails:

1. **STOP** all implementation
2. Identify the regression
3. Review recent commits
4. Fix the regression first
5. Re-run regression suite
6. Only then resume implementation

### Database Corruption

If feature database is corrupted:

1. Check for `.claude/features/features.db.bak`
2. If backup exists: Restore
3. If no backup: Re-run `/new-project` Phase 2 (feature breakdown)
4. Mark features that have commits as passing (git log analysis)

---

## See Also

- `SKILL.md` - Main skill definition
- `REGRESSION.md` - Regression testing protocol
- `../new-project/SKILL.md` - Project initialization
- `../../agents/orchestrator.md` - Workflow coordination
