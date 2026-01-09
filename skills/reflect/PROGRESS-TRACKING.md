# Progress Tracking for Autonomous Development

This document defines how to track and report progress during autonomous feature implementation.

---

## Overview

Progress tracking provides visibility into:
- How many features are complete
- Current implementation state
- Velocity and estimates
- Blockers and issues

---

## Progress Metrics

### Core Metrics

| Metric | Source | Formula |
|--------|--------|---------|
| Completion % | Feature DB | `(passing / total) * 100` |
| Remaining | Feature DB | `total - passing` |
| In Progress | Feature DB | `in_progress count` |
| Blocked | Progress Notes | Manual count |
| Skipped | Feature DB | Features with `skipped: true` |

### MCP Tool: feature_get_stats()

```python
stats = feature_get_stats()

# Returns:
{
    "passing": 45,
    "in_progress": 1,
    "total": 92,
    "percentage": 48.9
}
```

### Extended Stats (Manual Calculation)

```python
def get_extended_stats():
    stats = feature_get_stats()

    # Calculate by category
    categories = {}
    for cat in 'ABCDEFGHIJKLMNOPQRST':
        cat_features = feature_get_by_category(cat)
        categories[cat] = {
            'total': len(cat_features),
            'passing': sum(1 for f in cat_features if f['passes']),
            'percentage': (passing / total * 100) if total > 0 else 0
        }

    return {
        'overall': stats,
        'by_category': categories
    }
```

---

## Progress Display

### Session Start Summary

```markdown
## Session Start

**Project:** E-commerce MVP
**Progress:** 45/92 features (48.9%)

### Category Breakdown
| Category | Complete | Total | % |
|----------|----------|-------|---|
| A - Security | 5/5 | 100% | ✅ |
| B - Navigation | 8/8 | 100% | ✅ |
| C - Data | 12/15 | 80% | 🔄 |
| D - Workflow | 8/20 | 40% | 🔄 |
| E - Forms | 5/10 | 50% | 🔄 |
| ... | ... | ... | ... |

### Last Session
- Completed: 10 features
- Date: 2024-01-15

### Next Feature
ID-46: "Add item to shopping cart" (Category D)
```

### Checkpoint Progress Report

Every 10 features, display detailed progress:

```markdown
## Checkpoint Report: 50/92 Features (54.3%)

### Progress Bar
[████████████████████░░░░░░░░░░░░░░░░░░] 54.3%

### This Session
- Started at: 40 features (43.5%)
- Completed: 10 features
- Duration: ~45 minutes
- Rate: ~4.5 min/feature

### Last 5 Completed
| ID | Category | Name | Time |
|----|----------|------|------|
| 46 | D | Add to cart | 5m |
| 47 | D | Remove from cart | 4m |
| 48 | D | Update quantity | 6m |
| 49 | F | Cart summary | 3m |
| 50 | F | Cart item list | 4m |

### Next 5 Pending
| ID | Category | Name | Priority |
|----|----------|------|----------|
| 51 | G | Search products | 2 |
| 52 | G | Filter by category | 2 |
| 53 | G | Sort results | 3 |
| 54 | F | Product grid | 3 |
| 55 | F | Product list | 3 |

### Blockers
- None currently

### Estimates
- Remaining: 42 features
- At current rate: ~3 hours
- Sessions needed: 2-3 more
```

### Session End Summary

```markdown
## Session Complete

### Statistics
| Metric | Value |
|--------|-------|
| Features Completed | 10 |
| Starting Progress | 45/92 (48.9%) |
| Ending Progress | 55/92 (59.8%) |
| Regressions Caught | 0 |
| Features Skipped | 0 |
| Features Blocked | 0 |

### Time Breakdown
| Activity | Time |
|----------|------|
| Implementation | 35m |
| Testing | 8m |
| Regression Tests | 5m |
| Commits/Admin | 2m |
| **Total** | **50m** |

### Velocity
- Features/hour: 12
- Minutes/feature: 5

### Remaining Work
- Features left: 37
- Estimated time: ~3 hours
- Estimated sessions: 2-3

### Next Steps
1. Resume with /implement-features --resume
2. Next feature: ID-56 "User profile page"
3. Consider: Switch to Hybrid mode for Category I
```

---

## Tracking by Category

### Category Progress Table

```markdown
## Progress by Category

| Code | Category | Done | Total | % | Status |
|------|----------|------|-------|---|--------|
| A | Security | 5 | 5 | 100% | ✅ Complete |
| B | Navigation | 8 | 8 | 100% | ✅ Complete |
| C | Data (CRUD) | 12 | 15 | 80% | 🔄 In Progress |
| D | Workflow | 10 | 20 | 50% | 🔄 In Progress |
| E | Forms | 5 | 10 | 50% | 🔄 In Progress |
| F | Display | 8 | 12 | 67% | 🔄 In Progress |
| G | Search | 0 | 5 | 0% | ⏳ Pending |
| H | Notifications | 0 | 4 | 0% | ⏳ Pending |
| I | Settings | 0 | 3 | 0% | ⏳ Pending |
| J | Integration | 0 | 2 | 0% | ⏳ Pending |
| K | Analytics | 0 | 2 | 0% | ⏳ Pending |
| L | Admin | 0 | 3 | 0% | ⏳ Pending |
| M | Performance | 0 | 1 | 0% | ⏳ Pending |
| N | Accessibility | 0 | 2 | 0% | ⏳ Pending |
| O | Error Handling | 0 | 0 | - | ✅ N/A |
| P | Payment | 0 | 0 | - | ✅ N/A |
| Q | Communication | 0 | 0 | - | ✅ N/A |
| R | Media | 0 | 0 | - | ✅ N/A |
| S | Documentation | 0 | 0 | - | ✅ N/A |
| T | UI Polish | 0 | 0 | - | ✅ N/A |
```

### Category Status Indicators

| Status | Meaning |
|--------|---------|
| ✅ Complete | 100% features passing |
| 🔄 In Progress | Some features passing |
| ⏳ Pending | No features started |
| ⚠️ Blocked | Has blocked features |
| ✅ N/A | No features in category |

---

## Velocity Tracking

### Per-Session Velocity

```markdown
## Session Velocity Log

| Session | Date | Features | Duration | Rate |
|---------|------|----------|----------|------|
| 1 | 2024-01-14 | 12 | 55m | 4.6m/f |
| 2 | 2024-01-15 | 10 | 50m | 5.0m/f |
| 3 | 2024-01-15 | 15 | 45m | 3.0m/f |
| **Avg** | - | **12.3** | **50m** | **4.2m/f** |
```

### Velocity by Category

Some categories are faster than others:

```markdown
## Category Velocity

| Category | Avg Time | Notes |
|----------|----------|-------|
| A - Security | 8m | Complex, thorough testing |
| B - Navigation | 3m | Simple routing changes |
| C - Data | 6m | CRUD operations |
| D - Workflow | 5m | User interactions |
| E - Forms | 4m | Validation logic |
| F - Display | 3m | UI components |
| I - Settings | 2m | Configuration |
| T - UI Polish | 2m | Styling only |
```

### Estimated Completion

```python
def estimate_completion(stats, velocity_per_feature=5):
    remaining = stats['total'] - stats['passing']
    minutes_remaining = remaining * velocity_per_feature

    return {
        'remaining_features': remaining,
        'estimated_minutes': minutes_remaining,
        'estimated_hours': minutes_remaining / 60,
        'estimated_sessions': remaining // 12  # ~12 features/session
    }
```

---

## Blocker Tracking

### Blocker Log Format

```markdown
## Blockers

### Active Blockers

| ID | Feature | Blocker | Since | Action Needed |
|----|---------|---------|-------|---------------|
| 67 | Stripe webhook | No API keys | 2024-01-15 | Get keys from admin |
| 72 | Email send | SMTP not configured | 2024-01-15 | Configure Mailgun |

### Resolved Blockers

| ID | Feature | Blocker | Resolved | Resolution |
|----|---------|---------|----------|------------|
| 45 | Login | Missing test user | 2024-01-14 | Created seed data |
```

### Blocker Impact

```markdown
## Blocker Impact Analysis

Total Features: 92
Passing: 55 (59.8%)
Blocked: 2 (2.2%)
Remaining Unblocked: 35 (38.0%)

**Can continue:** 35 features without blockers
**Blocked progress:** 2 features require external action

**Recommendation:** Continue with unblocked features, escalate blockers
```

---

## Progress Persistence

### In Progress Notes

Add progress summary to `.claude/memories/progress-notes.md`:

```markdown
## Progress Summary (Updated: 2024-01-15)

### Overall
- Total Features: 92
- Passing: 55 (59.8%)
- Remaining: 37

### By Phase
- Phase 1 (Auth/Nav): 13/13 ✅
- Phase 2 (Core Data): 22/30 🔄
- Phase 3 (UX/Polish): 20/49 🔄

### Blockers
- 2 features blocked on external dependencies

### Velocity
- Average: 4.5 min/feature
- Estimated completion: 3 more sessions
```

### In Git Commits

Progress milestones can be committed:

```bash
git commit -m "milestone: 50% features complete (46/92)

Completed categories:
- Security (A): 100%
- Navigation (B): 100%

In progress:
- Data (C): 80%
- Workflow (D): 50%

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

---

## Reporting Commands

### Quick Status

```
/implement-features status
```

Output:
```
Progress: 55/92 (59.8%)
Next: ID-56 "User profile page"
Blocked: 2 features
```

### Detailed Report

```
/implement-features report
```

Output: Full checkpoint report with all categories.

### Category Report

```
/implement-features category D
```

Output:
```
Category D: Workflow & User Actions

Features: 10/20 (50%)

Completed:
- [46] Add to cart ✅
- [47] Remove from cart ✅
...

Pending:
- [56] User profile page
- [57] Edit profile
...
```

---

## Integration with Reflect

### Auto-Capture Progress

When `/reflect` runs at session end:

1. Query `feature_get_stats()`
2. Calculate velocity from session
3. Add to progress notes
4. Include in session summary

### Progress in Session Template

The session template includes progress:

```markdown
## Session Summary

### Progress
- Starting: 45/92 (48.9%)
- Ending: 55/92 (59.8%)
- Completed: 10 features
- Velocity: 5 min/feature

### Projection
- Remaining: 37 features
- Estimated: 3 hours
- Sessions: 2-3 more
```

---

## Visualization

### ASCII Progress Bar

```python
def progress_bar(percentage, width=40):
    filled = int(width * percentage / 100)
    empty = width - filled
    return f"[{'█' * filled}{'░' * empty}] {percentage:.1f}%"

# Example:
# [████████████████████░░░░░░░░░░░░░░░░░░] 54.3%
```

### Category Completion Chart

```
Security     [████████████████████] 100%
Navigation   [████████████████████] 100%
Data         [████████████████░░░░]  80%
Workflow     [██████████░░░░░░░░░░]  50%
Forms        [██████████░░░░░░░░░░]  50%
Display      [█████████████░░░░░░░]  67%
Search       [░░░░░░░░░░░░░░░░░░░░]   0%
```

---

## See Also

- `CONTEXT-MANAGEMENT.md` - Managing session context
- `SESSION-BRIDGES.md` - Data persistence
- `../../implement-features/SKILL.md` - Implementation workflow
- `../../templates/progress-notes.md` - Notes template
