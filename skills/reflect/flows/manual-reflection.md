# Manual Reflection Flow

Handles `/reflect` (no arguments) for session end and learning capture.

---

## `/reflect`

When `/reflect` is called without arguments:

1. **Complete Session End Protocol** (see below)
2. Scan current conversation for learning signals (see [SIGNALS.md](../SIGNALS.md))
3. Identify skills used during session
4. Categorize findings by confidence (High/Medium/Low)
5. Match learnings to relevant skills or general memories
6. Present batch review of proposed changes (see [CHECKPOINTS.md](../CHECKPOINTS.md))
7. On approval, update files per [UPDATE-RULES.md](../UPDATE-RULES.md)
8. Commit changes with descriptive message

---

## Auto-Reflection Flow

When enabled (`/reflect on`) and session ends:

1. Hook checks if skills were used this session
2. If yes, triggers reflection automatically
3. Same flow as manual, respects approval mode in config
4. Batch mode: presents review before applying
5. Auto mode: applies high confidence, queues others for review

---

## Session End Protocol

When ending a session (either `/reflect` or natural completion):

### 1. Update Session File

```markdown
# Session {id}

**Started**: 2024-01-15 14:30
**Ended**: 2024-01-15 16:45
**Branch**: feature/auth
**Scope**: src/auth/, src/middleware/
**Status**: completed
**Duration**: 2h 15m

## Completed
- [x] Implement login endpoint (commit: abc123)
- [x] Add JWT validation (commit: def456)
- [x] Write auth tests (commit: ghi789)

## Handoff Notes
- Registration endpoint ready to implement next
- Rate limiting should be added to auth routes
```

### 2. Move Session File

```bash
mv .claude/memories/sessions/active/session-{id}.md \
   .claude/memories/sessions/completed/session-{id}.md
```

### 3. Append to Progress Notes

**CRITICAL: APPEND ONLY. Never overwrite existing content.**

```markdown
---
### Session {id} - 2024-01-15 14:30
**Branch**: feature/auth
**Scope**: src/auth/, src/middleware/
**Status**: completed
**Duration**: 2h 15m

**Completed**:
- Implement login endpoint (commit: abc123)
- Add JWT validation (commit: def456)
- Write auth tests (commit: ghi789)

**Key Decisions**:
- Chose JWT over sessions for statelessness

**Handoff**:
- Registration endpoint ready to implement
- Add rate limiting to auth routes
---
```

### 4. Update latest.md

**Only if no other active sessions exist:**

```markdown
# Latest Session

**Session ID**: {id}
**Completed**: 2024-01-15 16:45

See `completed/session-{id}.md` for full details.

## Quick Summary
- Branch: feature/auth
- Completed 3 tasks
- Ready for: registration endpoint
```

---

## Key Rules

- **Append Only:** Never overwrite progress-notes.md, always append
- **Always Commit:** Commit updates with clear messages
- **Deduplicate:** Check for existing learnings before adding
- **Flag Conflicts:** Surface conflicts for manual review
- **Track Skills:** Use .session-skills to track what was used
