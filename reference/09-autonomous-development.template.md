# 09-autonomous-development.md

**Autonomous Development Patterns**

> **Audience:** Developers, Architects, Claude Code
> **Authority:** Development Standards (Tier 2)
> **Persona:** Principal Engineer
> **Purpose:** Define patterns for long-running autonomous agent development

---

## 1. Purpose of This Document

This document defines **patterns for autonomous development** using AI agents.

It answers:
* How do agents implement features autonomously?
* How is state preserved across sessions?
* How do agents coordinate and handoff work?
* How is quality maintained during automation?

This document does NOT cover:
* Security model (see `08-security-model.md`)
* Application architecture (see `02-architecture-and-tech-stack.md`)
* Deployment procedures (see `05-operational-and-lifecycle.md`)

---

## 2. Autonomous Development Overview

### What is Autonomous Development?

AI agents implementing features with minimal human intervention:

```
Human Input                    Agent Work                    Human Review
     │                              │                              │
     ▼                              ▼                              ▼
┌─────────┐                  ┌─────────────┐                ┌─────────┐
│ Define  │                  │ Implement   │                │ Review  │
│ project │ ───────────────► │ 50-400      │ ──────────────►│ & merge │
│ idea    │                  │ features    │                │         │
└─────────┘                  └─────────────┘                └─────────┘
                                   │
                            Checkpoints every
                            10 features for
                            human approval
```

### Key Principles

1. **Incremental Progress:** One feature at a time, committed after each
2. **Quality Gates:** Regression testing before new features
3. **Human Checkpoints:** Pause for approval every 10 features
4. **State Persistence:** Database + Git + Progress Notes
5. **Fail-Safe:** Security model prevents dangerous operations

---

## 3. Two-Phase Workflow

### Phase A: Project Initialization (`/new-project`)

```
User: /new-project "E-commerce MVP"
          │
          ▼
┌─────────────────────────────────────┐
│ Phase 1: Requirements Discovery      │
│ @analyst → @project-manager         │
│ Output: PRD document                │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│ Phase 2: Feature Breakdown          │
│ @scrum-master                       │
│ Output: 50-400 features in database │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│ Phase 3: Technical Planning         │
│ @architect                          │
│ Output: ADRs, technical decisions   │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│ Phase 4: Implementation Readiness   │
│ Setup MCP servers, security         │
│ Output: Ready to implement          │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│ Phase 5: Kickoff                    │
│ User approval                       │
│ Output: Start /implement-features   │
└─────────────────────────────────────┘
```

### Phase B: Implementation (`/implement-features`)

```
          ┌────────────────────────────────────────┐
          │                                        │
          ▼                                        │
┌─────────────────┐                               │
│ Get next        │                               │
│ feature         │◄──────────────────────────────┤
└────────┬────────┘                               │
         │                                        │
         ▼                                        │
┌─────────────────┐     ┌─────────────────┐      │
│ Regression      │────►│ FAIL: Fix       │      │
│ test (1-2)      │     │ regression      │      │
└────────┬────────┘     └─────────────────┘      │
         │ PASS                                   │
         ▼                                        │
┌─────────────────┐                               │
│ Implement       │                               │
│ feature         │                               │
└────────┬────────┘                               │
         │                                        │
         ▼                                        │
┌─────────────────┐     ┌─────────────────┐      │
│ Test &          │────►│ FAIL: Fix &     │      │
│ verify          │     │ retry (3x)      │      │
└────────┬────────┘     └─────────────────┘      │
         │ PASS                                   │
         ▼                                        │
┌─────────────────┐                               │
│ Mark passing    │                               │
│ Git commit      │                               │
└────────┬────────┘                               │
         │                                        │
         ▼                                        │
┌─────────────────┐     ┌─────────────────┐      │
│ Checkpoint?     │────►│ User: Continue  │──────┤
│ (every 10)      │     │ / Pause / Adjust│      │
└────────┬────────┘     └─────────────────┘      │
         │ No                                     │
         ▼                                        │
┌─────────────────┐                               │
│ More features?  │────YES────────────────────────┘
└────────┬────────┘
         │ No
         ▼
┌─────────────────┐
│ ALL COMPLETE!   │
└─────────────────┘
```

---

## 4. Feature Organization

### 20 Feature Categories

Features are categorized for proper agent routing:

| Code | Category | Primary Agent | Testing |
|------|----------|---------------|---------|
| A | Security & Auth | @security-boss | Always browser |
| B | Navigation | @developer | Browser (standard) |
| C | Data (CRUD) | @developer | Browser (standard/hybrid) |
| D | Workflow | @developer | Browser (standard/hybrid) |
| E | Forms | @developer | Browser (standard) |
| F | Display | @developer | Browser (standard) |
| G | Search | @developer | Browser (standard) |
| H | Notifications | @developer | Browser (standard) |
| I | Settings | @developer | Lint only |
| J | Integration | @developer | Browser (standard) |
| K | Analytics | @developer | Lint only |
| L | Admin | @developer | Browser (standard) |
| M | Performance | @performance-enhancer | Lint only |
| N | Accessibility | @developer | Browser (standard) |
| O | Error Handling | @developer | Browser (standard) |
| P | Payment | @security-boss | Always browser |
| Q | Communication | @developer | Lint only |
| R | Media | @developer | Browser (standard) |
| S | Documentation | @developer | Lint only |
| T | UI Polish | @whimsy | Lint only |

### Priority System

Features have priority values (lower = higher priority):

| Priority | Meaning | Typical Categories |
|----------|---------|-------------------|
| 1 | Critical | A (Security), P (Payment) |
| 2 | High | C (Data), D (Workflow) |
| 3 | Medium | B, E, F, G, H |
| 4 | Lower | I, K, N, O |
| 5 | Polish | T, S |

---

## 5. Testing Modes

### Standard Mode

Full browser automation for ALL features:

- Regression tests before every feature (2 random passing)
- Browser automation via Playwright for verification
- Screenshots captured for each feature
- Highest quality, slowest speed (~5-10 min/feature)

### YOLO Mode

Rapid prototyping, lint only:

- NO regression tests
- NO browser automation
- Only lint + type-check verification
- Fastest speed (~1-2 min/feature)
- Manual testing required after

### Hybrid Mode

Browser tests for critical features only:

- Categories A, C, D, P: Full browser testing
- Other categories: Lint only
- Balanced speed and quality (~3-5 min/feature)

### Mode Selection Guide

| Project Type | Recommended Mode |
|--------------|------------------|
| Production app | Standard |
| Prototype / POC | YOLO |
| Internal tool | Hybrid |
| Security-critical | Standard (always) |

---

## 6. State Persistence

### Three Bridges

State persists through three mechanisms:

```
┌─────────────────────────────────────────────────────────┐
│                    Persistent State                      │
├───────────────────┬─────────────────┬──────────────────┤
│   Feature DB      │   Git Commits   │  Progress Notes  │
│                   │                 │                  │
│ • Which features  │ • All code      │ • Session logs   │
│   are complete    │   changes       │ • Decisions      │
│ • Test steps      │ • Feature IDs   │ • Blockers       │
│ • Priority order  │   in messages   │ • Human context  │
└───────────────────┴─────────────────┴──────────────────┘
```

### Feature Database

Location: `.claude/features/features.db`

```sql
CREATE TABLE features (
    id INTEGER PRIMARY KEY,
    priority INTEGER,
    category TEXT,
    name TEXT,
    description TEXT,
    steps TEXT,  -- JSON array
    passes BOOLEAN DEFAULT FALSE,
    in_progress BOOLEAN DEFAULT FALSE,
    test_type TEXT,
    screenshot_path TEXT,
    last_tested_at DATETIME
);
```

### MCP Tools

| Tool | Purpose |
|------|---------|
| `feature_get_stats()` | Get completion stats |
| `feature_get_next()` | Get next feature to implement |
| `feature_get_for_regression(limit)` | Get random passing features |
| `feature_mark_in_progress(id)` | Lock feature |
| `feature_mark_passing(id)` | Complete feature |
| `feature_skip(id)` | Skip blocked feature |
| `feature_clear_in_progress(id)` | Clear stale lock |
| `feature_create_bulk(features)` | Create features from PRD |
| `feature_get_by_category(cat)` | Get features by category |

---

## 7. Session Management

### Session Lifecycle

```
┌─────────────┐
│ Session     │
│ Start       │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│ 1. Read progress notes              │
│ 2. Query feature_get_stats()        │
│ 3. Check for in-progress features   │
│ 4. Review recent git commits        │
│ 5. Start dev server if needed       │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│         Feature Loop                │
│   (repeat 10-15 times per session)  │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│ 1. Update progress notes            │
│ 2. Commit progress notes            │
│ 3. Display session summary          │
│ 4. Provide resume command           │
└─────────────────────────────────────┘
```

### Session Handoff

At session end, capture:

```markdown
## Session: 2024-01-15 14:30

### Summary
- Features: 10 completed (ID-46 to ID-55)
- Progress: 55/92 (59.8%)
- Mode: Standard

### Next Feature
ID-56: "User profile page" (Category D)

### Notes
- Cart features complete
- Using Zustand for state
- Dev server on port 3000
```

### Resume Protocol

```
/implement-features --resume
```

1. Read progress notes
2. Query database state
3. Check git status
4. Verify dev server
5. Run regression test
6. Continue with next feature

---

## 8. Quality Assurance

### Regression Testing

Before implementing each new feature:

```python
# Get 1-2 random passing features
features = feature_get_for_regression(limit=2)

for feature in features:
    result = execute_test_steps(feature)
    if not result.passing:
        # STOP - regression detected
        report_regression(feature, result)
        await fix_regression()
        return
```

### Feature Verification

Each feature must pass:

1. **Lint:** `npm run lint` passes
2. **Types:** `npm run typecheck` passes
3. **Tests:** All test steps pass (mode-dependent)
4. **No regressions:** Previous features still work

### Commit Strategy

One commit per feature:

```
feat(cart): add item to shopping cart

- Add AddToCart component
- Connect to cart context
- Show success toast

Feature-ID: 46
Testing: Standard mode - browser verified

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

---

## 9. Agent Coordination

### Agent Roles

| Agent | Responsibility |
|-------|---------------|
| @orchestrator | Feature routing, checkpoints, session management |
| @project-manager | PRD creation, scope definition |
| @scrum-master | Feature breakdown, database population |
| @architect | Technical decisions, ADRs |
| @developer | Feature implementation |
| @quality-engineer | Browser testing, regression testing |
| @security-boss | Security features, payment flows |

### Handoff Protocol

```markdown
## Handoff: @developer → @quality-engineer

Feature: ID-46 "Add to cart"
Category: D (Workflow)
Mode: Standard

Pre-verified:
- Lint: ✅ Pass
- Types: ✅ Pass

Request: Execute browser test steps

Test Steps:
1. Navigate to product page
2. Click "Add to Cart"
3. Verify success toast
4. Verify cart count updates
```

### Return Protocol

```markdown
## Return: @quality-engineer → @orchestrator

Feature: ID-46
Status: PASSING ✅

Steps: 4/4 passed
Screenshot: feature-46-passing.png
Duration: 8.5s
A11y warnings: 0
```

---

## 10. Checkpoint Protocol

### Trigger

Every 10 features, pause for user:

```markdown
## Checkpoint: 50/92 Features (54.3%)

### Last 5 Completed
- [46] Add to cart ✅
- [47] Remove from cart ✅
- [48] Update quantity ✅
- [49] Cart summary ✅
- [50] Cart item list ✅

### Next 5 Pending
- [51] Search products
- [52] Filter by category
- [53] Sort results
- [54] Product grid
- [55] Product list

### Options
1. **Continue** - Resume implementation
2. **Pause** - Save and exit
3. **Adjust** - Re-prioritize features
4. **Review** - Inspect specific feature
```

### User Choices

| Choice | Action |
|--------|--------|
| Continue | Reset counter, resume loop |
| Pause | Update notes, commit, exit |
| Adjust | Skip features, change priority |
| Review | Show feature details, re-test |

---

## 11. Error Handling

### Implementation Failure

```markdown
Attempt 1: Implement → Test → Fail
    ↓
Attempt 2: Fix → Test → Fail
    ↓
Attempt 3: Fix → Test → Fail
    ↓
feature_skip(id)
Log blocker
Continue with next feature
```

### Regression Failure

```markdown
1. STOP all implementation
2. Identify failing feature
3. Review recent commits
4. Fix regression
5. Re-run regression suite
6. Resume only when all pass
```

### Session Crash

```markdown
1. Check git status for uncommitted changes
2. Check database for in_progress features
3. Clear stale locks if needed
4. Review progress notes
5. Resume normally
```

---

## 12. Metrics and Reporting

### Key Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Completion Rate | 100% | passing / total |
| Regression Rate | < 5% | regressions / features |
| Velocity | 5-10 min/feature | time / features |
| Block Rate | < 10% | blocked / total |

### Progress Reporting

```markdown
## Progress Report

Overall: 55/92 (59.8%)
Rate: 4.5 min/feature
Estimated: 3 hours remaining

By Category:
- Security (A): 100% ✅
- Navigation (B): 100% ✅
- Data (C): 80% 🔄
- Workflow (D): 50% 🔄
```

---

## 13. Best Practices

### Do

- ✅ Complete features atomically
- ✅ Commit after each feature
- ✅ Run regression tests
- ✅ Update progress notes
- ✅ Respect checkpoints

### Don't

- ❌ Skip regression tests
- ❌ Batch multiple features
- ❌ Leave features in_progress
- ❌ Force through blockers
- ❌ Ignore test failures

---

## 14. See Also

- `skills/new-project/SKILL.md` - Project initialization
- `skills/implement-features/SKILL.md` - Implementation workflow
- `skills/reflect/CONTEXT-MANAGEMENT.md` - Session continuity
- `08-security-model.md` - Security boundaries
- `mcp-servers/feature-tracking/README.md` - Database tools
