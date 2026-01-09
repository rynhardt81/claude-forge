# Context Management for Autonomous Development

This document defines patterns for managing context across long-running autonomous sessions.

---

## Overview

When implementing features using `/implement-features`, sessions may span multiple conversations due to context window limits. This document describes how to:

1. Preserve context across session boundaries
2. Resume work without losing state
3. Handle context approaching limits

---

## Context Window Awareness

### Monitoring Usage

The context window has a maximum capacity. As you work:

- **Track Feature Count:** Approximately 10-15 features per session before context fills
- **Monitor Complexity:** Complex features with many files consume more context
- **Watch for Warnings:** Claude Code may warn when context is nearing limits

### Session Boundaries

Plan session boundaries around natural breakpoints:

| Checkpoint Type | When to End Session |
|----------------|---------------------|
| Feature Completion | After marking feature as passing and committing |
| Checkpoint (10 features) | Natural pause point for user approval |
| Category Change | Switching from Security → UI gives clean break |
| Blocker Encountered | When waiting for external input |

### Never End Session Mid-Feature

**Critical Rule:** Always complete a feature before ending a session:
- Feature locked (`in_progress: true`)
- Code changes uncommitted
- Tests partially run

If context runs low mid-feature, finish current feature, then end session.

---

## Context Persistence Strategy

### Three Pillars of State

```
Session State = Feature Database + Git Commits + Progress Notes
```

1. **Feature Database** (`.claude/features/features.db`)
   - Which features are pending/passing/in-progress
   - Test steps for each feature
   - Priority ordering

2. **Git Commits**
   - All code changes
   - Feature IDs in commit messages
   - Full implementation history

3. **Progress Notes** (`.claude/memories/progress-notes.md`)
   - Session summaries
   - Blockers and decisions
   - Architecture notes
   - Human-readable context

### What Gets Lost Between Sessions

The following are NOT persisted and must be reconstructed:
- Variable values in memory
- File contents read but not committed
- Partial implementations not committed
- Browser automation state
- Development server state

---

## Session Handoff Protocol

### End of Session

Before ending a session, always:

```markdown
## Session End Checklist

1. [ ] Current feature marked as passing OR cleared from in_progress
2. [ ] All code changes committed
3. [ ] Progress notes updated with:
   - [ ] Features completed this session
   - [ ] Any blockers encountered
   - [ ] Decisions made
   - [ ] Next feature to implement
4. [ ] Progress notes committed
5. [ ] Dev server status noted (running/stopped)
```

### Progress Notes Update

Add session summary to `.claude/memories/progress-notes.md`:

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
- [ID-47] Feature name ✅

### Blockers
- [ID-48] Blocked: Waiting for API credentials
- Description of blocker and what's needed

### Decisions Made
- Chose React Query over SWR for data fetching
- Using Zustand for cart state management

### Notes for Next Session
- Continue with ID-49 "Feature name"
- Consider switching to Hybrid mode for Category I features
- Dev server was running on port 3000

### Architecture Context
- Cart state in `src/store/cart.ts`
- API endpoints in `src/api/`
- Components follow atomic design pattern
```

---

## Session Resume Protocol

### Resume Checklist

When starting a new session after `/reflect resume`:

```markdown
## Session Resume Checklist

1. [ ] Read progress notes for context
2. [ ] Query feature_get_stats() for current progress
3. [ ] Check for in-progress features (may need cleanup)
4. [ ] Review last 3-5 git commits
5. [ ] Verify dev server status (start if needed)
6. [ ] Run regression test on 1-2 passing features
7. [ ] Get next feature and continue
```

### Handling Stale In-Progress Features

If `feature_get_stats()` shows `in_progress > 0`:

```python
# Session may have crashed
feature = feature_get_next()  # Returns in-progress first

# Check git for this feature
git_log = git log --oneline -3

# Decision matrix:
if feature_id in recent_commits:
    # Code was committed, verify tests pass
    run_tests(feature)
    if tests_pass:
        feature_mark_passing(feature.id)
    else:
        # Resume debugging
        continue_implementation(feature)
else:
    # No code committed, start fresh
    feature_clear_in_progress(feature.id)
    # Feature returns to queue
```

### Context Reconstruction

Rebuild mental model from artifacts:

```markdown
## Context Reconstruction Steps

1. **Read Progress Notes**
   - What was accomplished
   - What decisions were made
   - What's next

2. **Review Git History**
   ```bash
   git log --oneline -10
   ```
   - Recent changes
   - Feature IDs implemented

3. **Query Feature Database**
   ```python
   stats = feature_get_stats()
   # { passing: 45, in_progress: 0, total: 92, percentage: 48.9 }
   ```

4. **Check Project Structure**
   - Review src/ directory
   - Understand component organization
   - Note any patterns established

5. **Read Last Feature**
   ```python
   feature = feature_get_next()
   # Understand what you're implementing next
   ```
```

---

## Long Session Management

### Recommended Session Length

| Mode | Features per Session | Estimated Duration |
|------|---------------------|-------------------|
| Standard | 10-15 | 1-2 hours |
| Hybrid | 15-20 | 1-1.5 hours |
| YOLO | 20-30 | 45-90 minutes |

### Warning Signs

End session soon if you notice:
- Responses becoming slower
- Forgetting earlier context
- Needing to re-read files repeatedly
- Approaching checkpoint (feature count % 10 == 9)

### Graceful Session End

```markdown
## Approaching Context Limit

Current feature: ID-55 "Product search"
Features this session: 9

**Recommendation:** Complete this feature, then end session.

After marking ID-55 as passing:
1. Update progress notes
2. Commit all changes
3. Report final status
4. End session

**Resume command:** /implement-features --resume
```

---

## Context Optimization

### Minimize Context Usage

1. **Don't Re-Read Unchanged Files**
   - Use grep/glob for targeted searches
   - Remember file structures between features

2. **Commit Frequently**
   - After each feature, not in batches
   - Frees up context for next feature

3. **Use Progress Notes**
   - Write decisions down, don't hold in context
   - Reference notes instead of reconstructing

4. **Leverage Database**
   - Feature details in DB, not memory
   - Query only what you need

### Information Hierarchy

What to keep in active context:
1. Current feature being implemented
2. File currently being edited
3. Recent test results

What to store externally:
1. Completed feature details → Progress notes
2. All test steps → Feature database
3. Code changes → Git commits
4. Decisions → Progress notes

---

## Emergency Recovery

### Context Exhaustion Mid-Feature

If context runs out during feature implementation:

```markdown
## Emergency: Context Exhaustion

Current State:
- Feature ID-67 partially implemented
- Changes not yet committed
- Tests not yet run

Recovery Steps:
1. Note current state in user message
2. Start new session
3. Read progress notes
4. Review uncommitted changes (git diff)
5. Either:
   a. Commit partial work, continue implementation
   b. Discard partial work, restart feature
```

### Session Crash Recovery

If session terminates unexpectedly:

```markdown
## Recovery from Crash

1. Check git status
   - Uncommitted changes? Review and commit or discard

2. Check feature database
   - In-progress features? Evaluate state

3. Check progress notes
   - When was last update?
   - What was being worked on?

4. Reconstruct and continue
   - Use /implement-features --resume
```

---

## Integration with Reflect Skill

### Auto-Capture at Session End

When session ends (manually or at limit):

1. `/reflect` triggers automatically
2. Captures session context to progress notes
3. Updates skill learnings if applicable
4. Commits all session artifacts

### Resume Integration

`/reflect resume` enhanced for autonomous development:

1. Reads `.claude/memories/sessions/latest.md`
2. Reads `.claude/memories/progress-notes.md`
3. Queries feature database for state
4. Presents combined context:
   ```markdown
   ## Resume Context

   **Last Session:** 2024-01-15 14:30
   **Progress:** 45/92 features (48.9%)
   **Next Feature:** ID-46 "Add to cart"
   **Testing Mode:** Standard

   **Recent Work:**
   - Completed cart display features
   - Established Zustand for state

   Continue from here?
   ```

---

## See Also

- `SESSION-BRIDGES.md` - Data flow between sessions
- `PROGRESS-TRACKING.md` - Feature completion tracking
- `SKILL.md` - Core reflect skill definition
- `../implement-features/PHASES.md` - Session phases
