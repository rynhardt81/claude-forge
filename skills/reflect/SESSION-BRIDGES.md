# Session Bridges: Persistent State Across Sessions

This document defines the three data bridges that preserve state between autonomous development sessions.

---

## Overview

Autonomous development spans multiple sessions. State must persist reliably:

```
Session N                    Session N+1
    │                            │
    ▼                            ▼
┌─────────┐                 ┌─────────┐
│ Work    │                 │ Resume  │
│ on      │                 │ from    │
│ features│                 │ state   │
└────┬────┘                 └────▲────┘
     │                           │
     │    ┌─────────────────┐    │
     └───►│ Persistent      │────┘
          │ State Bridges   │
          │                 │
          │ 1. Feature DB   │
          │ 2. Git Commits  │
          │ 3. Progress Notes│
          └─────────────────┘
```

---

## Bridge 1: Feature Database

### Purpose

Single source of truth for feature state.

### Location

`.claude/features/features.db` (SQLite)

### Data Preserved

| Field | Purpose |
|-------|---------|
| `id` | Unique identifier (referenced in commits) |
| `priority` | Implementation order |
| `category` | Agent routing (A-T) |
| `name` | Human-readable feature name |
| `description` | Full feature description |
| `steps` | JSON array of test steps |
| `passes` | Implementation complete |
| `in_progress` | Feature locked for work |
| `test_type` | browser/api/unit/manual |
| `screenshot_path` | Verification screenshot |
| `last_tested_at` | Last test timestamp |

### Read Operations

```python
# Get current progress
stats = feature_get_stats()
# Returns: { passing: 45, in_progress: 0, total: 92, percentage: 48.9 }

# Get next feature to implement
feature = feature_get_next()
# Returns in-progress first, then lowest priority pending

# Get features for regression testing
regression = feature_get_for_regression(limit=2)
# Returns random passing features
```

### Write Operations

```python
# Lock feature for implementation
feature_mark_in_progress(feature_id)

# Mark feature as complete
feature_mark_passing(feature_id)

# Skip blocked feature
feature_skip(feature_id)

# Clear stale lock
feature_clear_in_progress(feature_id)
```

### Session Bridge Pattern

```markdown
## End of Session N

1. feature_mark_passing(current_id)  # Complete current
2. Commit code changes
3. Update progress notes

## Start of Session N+1

1. stats = feature_get_stats()        # Check progress
2. Check for in_progress features     # Handle stale locks
3. feature = feature_get_next()       # Get next feature
4. Continue implementation
```

---

## Bridge 2: Git Commits

### Purpose

Persist all code changes with feature traceability.

### Commit Format

```
feat(<scope>): <description>

<bullet points of changes>

Feature-ID: <id>
Testing: <mode> - <verification>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### Example

```
feat(cart): add item to shopping cart

- Add AddToCart component with quantity selector
- Connect to cart context via useCart hook
- Show success toast on add
- Update cart badge count

Feature-ID: 46
Testing: Standard mode - browser verified

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### Feature ID Tracking

Every feature commit includes `Feature-ID: <id>` for:
- Tracing which code implements which feature
- Verifying feature completion
- Debugging regressions

### Session Bridge Pattern

```markdown
## End of Session N

1. git add .
2. git commit (with Feature-ID)
3. Verify commit succeeded

## Start of Session N+1

1. git log --oneline -10            # Review recent commits
2. Extract Feature-IDs from commits
3. Cross-reference with database
4. Identify any gaps
```

### Recovery from Git

If database is lost, can partially recover from git:

```bash
# Find all feature commits
git log --grep="Feature-ID:" --oneline

# Extract feature IDs
git log --grep="Feature-ID:" --format="%s %b" | grep "Feature-ID:"
```

---

## Bridge 3: Progress Notes

### Purpose

Human-readable context that can't be structured.

### Location

`.claude/memories/progress-notes.md`

### Content Types

| Section | What It Contains |
|---------|------------------|
| Session Summary | Features completed, duration, mode |
| Completed Features | List with IDs and names |
| Blockers | Issues preventing progress |
| Decisions | Architecture and design choices |
| Notes for Next Session | Recommendations, context |
| Architecture Context | Code organization notes |

### Template

```markdown
## Session: YYYY-MM-DD HH:MM

### Summary
- Features completed: X (ID-start through ID-end)
- Total progress: Y/Z (percentage%)
- Testing mode: Standard/YOLO/Hybrid
- Duration: approximately X minutes

### Completed This Session
- [ID-45] Feature name ✅
- [ID-46] Feature name ✅

### Blockers
- [ID-48] Blocked: [reason]

### Decisions Made
- [Decision 1]
- [Decision 2]

### Notes for Next Session
- [Recommendation 1]
- [Context note 2]

### Architecture Context
- [Code organization]
- [Patterns used]
```

### Session Bridge Pattern

```markdown
## End of Session N

1. Write session summary
2. Document any blockers
3. Note decisions made
4. Add recommendations for next session
5. Commit progress notes

## Start of Session N+1

1. Read progress notes
2. Understand context and decisions
3. Note any blockers to address
4. Use recommendations
```

---

## Bridge Synchronization

### Consistency Rules

The three bridges must stay synchronized:

```
Feature Database           Git Commits              Progress Notes
      │                         │                         │
      ▼                         ▼                         ▼
passes: true      ◄────►   Feature-ID: X     ◄────►   [X] completed ✅
                           in commit
```

**Rule 1:** Feature marked passing ↔ Commit exists with Feature-ID
**Rule 2:** Session in progress notes ↔ Matching git commits
**Rule 3:** In-progress feature → No commit yet (or commit in progress)

### Sync Verification

At session start, verify bridges are synchronized:

```python
def verify_bridge_sync():
    # Get database state
    stats = feature_get_stats()

    # Get git commits with feature IDs
    commits = parse_git_log("git log --grep='Feature-ID:' -100")
    committed_ids = extract_feature_ids(commits)

    # Get progress notes
    notes = read_progress_notes()
    noted_ids = extract_completed_ids(notes)

    # Verify consistency
    passing_features = get_passing_features()

    for feature in passing_features:
        if feature.id not in committed_ids:
            warn(f"Feature {feature.id} passing but no commit found")
        if feature.id not in noted_ids:
            warn(f"Feature {feature.id} passing but not in notes")

    return all_consistent
```

### Handling Desync

If bridges are out of sync:

| Scenario | Resolution |
|----------|------------|
| DB says passing, no commit | Revert DB, re-implement |
| Commit exists, DB says pending | Update DB to passing |
| Notes missing session | Reconstruct from git log |
| DB in_progress but committed | Clear in_progress |

---

## Data Flow Diagram

```
┌────────────────────────────────────────────────────────────────────┐
│                        Session N                                    │
│                                                                     │
│  ┌───────────┐    ┌──────────────┐    ┌──────────────────┐        │
│  │ Get Next  │───►│ Implement    │───►│ Test & Verify    │        │
│  │ Feature   │    │ Feature      │    │                  │        │
│  └───────────┘    └──────────────┘    └────────┬─────────┘        │
│        │                 │                      │                  │
│        │                 │                      │                  │
│        ▼                 ▼                      ▼                  │
│  ┌──────────┐     ┌──────────┐          ┌──────────┐              │
│  │ feature_ │     │ Write    │          │ feature_ │              │
│  │ mark_in_ │     │ Code     │          │ mark_    │              │
│  │ progress │     │          │          │ passing  │              │
│  └────┬─────┘     └────┬─────┘          └────┬─────┘              │
│       │                │                      │                    │
└───────┼────────────────┼──────────────────────┼────────────────────┘
        │                │                      │
        ▼                ▼                      ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────────────────────┐
│ Feature DB    │ │ Git Repo      │ │ Progress Notes                │
│               │ │               │ │                               │
│ in_progress:  │ │ Uncommitted   │ │ Session: ...                  │
│ true          │ │ changes       │ │ (updated at session end)      │
│               │ │               │ │                               │
│ passes: false │ │               │ │                               │
└───────────────┘ └───────┬───────┘ └───────────────────────────────┘
                          │
                          ▼ (on feature complete)
                  ┌───────────────┐
                  │ git commit    │
                  │ Feature-ID: X │
                  └───────────────┘
```

---

## Bridge Maintenance

### Daily Maintenance

```markdown
## At Session Start
1. Verify bridge sync
2. Check for orphaned in_progress
3. Review git status for uncommitted changes

## At Session End
1. All features committed
2. Progress notes updated
3. No dangling state
```

### Weekly Maintenance

```markdown
## Weekly Bridge Health Check
1. Count passing features in DB
2. Count Feature-ID commits in git
3. Count completed features in notes
4. Resolve any discrepancies
```

### Backup Strategy

```bash
# Backup feature database
cp .claude/features/features.db .claude/features/features.db.bak

# Progress notes are in git
git log -1 -- .claude/memories/progress-notes.md

# Full backup
tar -czf project-state-backup.tar.gz \
    .claude/features/features.db \
    .claude/memories/progress-notes.md \
    .git
```

---

## Failure Recovery

### Database Corruption

```markdown
1. Check for backup: .claude/features/features.db.bak
2. If backup exists: restore
3. If no backup:
   a. Re-run /new-project Phase 2 (feature breakdown)
   b. Mark features as passing based on git commits
   c. Reconstruct from git log
```

### Git History Loss

```markdown
1. Database still has feature state
2. Progress notes have human context
3. Re-implement uncommitted work
4. Resume from database state
```

### Progress Notes Lost

```markdown
1. Reconstruct from:
   - Git commit messages
   - Database feature states
   - Git log timestamps
2. Write summary of reconstruction
3. Continue normally
```

---

## See Also

- `CONTEXT-MANAGEMENT.md` - Managing context across sessions
- `PROGRESS-TRACKING.md` - Feature completion tracking
- `../../mcp-servers/feature-tracking/README.md` - MCP tools
- `../../templates/progress-notes.md` - Notes template
