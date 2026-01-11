# Parallel Session Reference

This document explains how multiple Claude sessions can work on the same project simultaneously without conflicts.

---

## Overview

When multiple Claude sessions run in parallel (e.g., in different terminal windows or IDE instances), they must coordinate to avoid:

1. **Race conditions** on shared files
2. **State conflicts** when updating session state
3. **Overlapping work** on the same features
4. **Merge conflicts** from simultaneous changes

The parallel session system provides:

- **Session isolation** with explicit scope boundaries
- **Conflict detection** before work begins
- **Append-only audit trail** for session history
- **Coordination rules** for branch/directory/file access

---

## Directory Structure

```
.claude/memories/
├── progress-notes.md           # Append-only log (NEVER overwrite)
├── general.md                  # Project preferences
├── sessions/
│   ├── active/                 # Currently running sessions
│   │   ├── .gitkeep
│   │   └── session-{id}.md     # Active session files
│   ├── completed/              # Archived sessions
│   │   ├── .gitkeep
│   │   └── session-{id}.md     # Completed session files
│   ├── latest.md               # Points to most recent (single-session compat)
│   └── README.md               # Session management docs
```

### File Tracking

| File | Git Status | Reason |
|------|------------|--------|
| `progress-notes.md` | Tracked | Permanent append-only record |
| `general.md` | Tracked | Project preferences |
| `sessions/active/.gitkeep` | Tracked | Keep directory in git |
| `sessions/active/session-*.md` | **Gitignored** | Transient, session-specific |
| `sessions/completed/.gitkeep` | Tracked | Keep directory in git |
| `sessions/completed/session-*.md` | **Gitignored** | Transient, may contain sensitive info |
| `sessions/latest.md` | Tracked | Single-session compatibility |

---

## Session Lifecycle

### 1. Session Start

```
┌─────────────────────────────────────────────────────────────────┐
│                       SESSION START                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Generate Session ID                                          │
│     Format: {YYYYMMDD-HHMMSS}-{4-random-chars}                  │
│     Example: 20240115-143022-a7x9                               │
│                                                                  │
│  2. Create Session File                                          │
│     Path: .claude/memories/sessions/active/session-{id}.md      │
│     Template: templates/session.md                               │
│                                                                  │
│  3. Declare Scope                                                │
│     - Branch: which git branch                                   │
│     - Directories: which dirs will be modified                   │
│     - Files: specific files (if granular)                        │
│     - Features: what feature areas                               │
│                                                                  │
│  4. Scan for Conflicts                                           │
│     - List all files in active/                                  │
│     - Parse each for scope declarations                          │
│     - Compare for overlap                                        │
│     - Apply conflict resolution rules                            │
│                                                                  │
│  5. Load Context                                                 │
│     - Read progress-notes.md                                     │
│     - Read relevant completed sessions                           │
│     - Check task registry                                        │
│                                                                  │
│  6. Proceed (if no blocking conflicts)                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2. During Session

- Update session file in real-time
- Track "Working On" and "Completed" items
- Record commits and key decisions
- Check for conflicts before modifying files

### 3. Session End

```
┌─────────────────────────────────────────────────────────────────┐
│                       SESSION END                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Update Session File                                          │
│     - Move items from "Working On" to "Completed"                │
│     - Fill in handoff notes                                      │
│     - Set status to "completed"                                  │
│                                                                  │
│  2. Move Session File                                            │
│     From: active/session-{id}.md                                 │
│     To:   completed/session-{id}.md                              │
│                                                                  │
│  3. Append to Progress Notes                                     │
│     - Add session summary with --- separator                     │
│     - Include: branch, scope, completed items, decisions         │
│     - NEVER overwrite existing content                           │
│                                                                  │
│  4. Update latest.md                                             │
│     - ONLY if no other active sessions exist                     │
│     - Point to completed session                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conflict Detection

### How It Works

When a session starts, it must:

1. **List all files** in `.claude/memories/sessions/active/`
2. **Parse each session file** for scope declarations
3. **Compare scopes** for overlap
4. **Apply resolution rules** based on conflict type

### Scope Granularity

Scopes can be declared at different levels:

| Level | Example | Overlap Detection |
|-------|---------|-------------------|
| Branch | `feature/auth` | Exact match = conflict |
| Directory | `src/components/` | Path contains/overlaps = conflict |
| File | `src/config.ts` | Exact match = conflict |
| Feature | `authentication` | Name match = warning |

### Conflict Resolution Matrix

| Conflict Type | Detection | Resolution |
|---------------|-----------|------------|
| **Branch Collision** | Same branch name | **BLOCK** - Cannot proceed |
| **Directory Overlap** | Paths intersect | **WARN** - User confirms |
| **File Collision** | Same file path | **ASK** - User decides |
| **Merge/PR** | Both merging | **QUEUE** - Wait for first |

### Conflict Examples

**Branch Conflict (BLOCK):**
```
Session A: branch = feature/auth
Session B: branch = feature/auth
→ BLOCKED: Same branch. User must choose which continues.
```

**Directory Overlap (WARN):**
```
Session A: directories = [src/backend/]
Session B: directories = [src/backend/auth/]
→ WARNING: B is subset of A. User must confirm or narrow scope.
```

**File Conflict (ASK):**
```
Session A: files = [src/config.ts]
Session B: files = [src/config.ts]
→ ASK USER: Both need same file. Who has priority?
```

---

## Resolution Strategies

When conflicts occur, use these strategies:

### 1. Branch Isolation (Preferred)

Each session uses its own branch:

```
Session A: feature/auth-login
Session B: feature/auth-registration
```

Benefits:
- No conflicts possible
- Easy to merge later
- Clear ownership

### 2. Directory Partitioning

Divide codebase into non-overlapping areas:

```
Session A: src/backend/
Session B: src/frontend/
```

Benefits:
- Parallel work on same branch
- Clear boundaries
- Reduced merge conflicts

### 3. Time Slicing

One session pauses while other completes:

```
Session A: Working (active)
Session B: Blocked (waiting for A)
```

Use when:
- Same files needed
- Work is sequential by nature

### 4. Merge Coordination

Both complete work, then user merges:

```
Session A: feature/component-a → PR
Session B: feature/component-b → PR
User: Merges both PRs, resolves any conflicts
```

---

## Session ID Format

Session IDs are structured for:
- **Sortability** - Timestamp prefix
- **Uniqueness** - Random suffix
- **Readability** - Human-parseable

Format: `{YYYYMMDD-HHMMSS}-{4-random-chars}`

Examples:
- `20240115-143022-a7x9`
- `20240115-150045-k2m3`

---

## Progress Notes Format

The `progress-notes.md` file is **append-only**. Each session adds an entry:

```markdown
---
### Session 20240115-143022-a7x9 - 2024-01-15 14:30
**Branch**: feature/auth
**Scope**: src/auth/, src/middleware/
**Status**: completed
**Duration**: 2h 15m

**Completed**:
- Implement login endpoint (commit: abc123)
- Add JWT validation middleware (commit: def456)
- Write auth unit tests (commit: ghi789)

**Key Decisions**:
- Chose JWT over sessions for statelessness
- Used bcrypt with cost factor 12

**Handoff**:
- Registration endpoint ready to implement
- Need to add rate limiting to auth routes
---
```

### Rules for Progress Notes

1. **NEVER overwrite** existing content
2. **Always append** with `---` separator
3. **Include** at minimum: session ID, branch, completed items
4. **Keep summaries concise** - this is a log, not detailed documentation

---

## Single-Session Compatibility

If only one session is active:

- System behaves exactly like before
- `latest.md` is updated normally
- Conflict checks still run (but pass)
- No user intervention needed

The parallel session system is **fully backwards compatible** with single-session usage.

---

## Stale Session Cleanup

Sessions may become orphaned if:
- Claude session crashes
- User closes terminal without cleanup
- Network disconnection

### Detection

A session is **stale** if:
- File timestamp > `sessionStaleTimeout` (default: 24 hours)
- No corresponding Claude process

### Cleanup

```
/reflect status --locked      # See all active sessions with timestamps
/reflect cleanup              # Remove stale sessions (with confirmation)
```

Manual cleanup:
1. Read the stale session file
2. Note any uncommitted work
3. Move to `completed/` with status `abandoned`
4. Append summary to `progress-notes.md`

---

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `sessionStaleTimeout` | 86400 | Seconds before session is stale (24h) |
| `maxParallelAgents` | 3 | Max concurrent active sessions |
| `allowManualUnlock` | true | Allow force cleanup of stale sessions |

---

## Troubleshooting

### "Branch conflict detected"

**Problem:** Another session is using the same branch.

**Solution:**
1. Check which session has priority
2. Either: other session switches branches, or this session waits

### "Directory overlap warning"

**Problem:** Your scope intersects with another session.

**Solution:**
1. Narrow your scope to non-overlapping directories
2. Or: confirm you understand the overlap risk
3. Coordinate with other session on file changes

### "Stale session blocking work"

**Problem:** An old session file is in `active/` but no Claude is running.

**Solution:**
```
/reflect status --locked      # Verify it's stale
/reflect cleanup              # Clean up stale sessions
```

### "Progress notes seem wrong"

**Problem:** Data in progress notes doesn't match reality.

**Solution:**
1. Progress notes are append-only for a reason
2. Add a correction entry, don't edit history
3. Use git blame to find when incorrect entry was added

---

## Best Practices

1. **Declare narrow scopes** - Only claim what you'll actually modify
2. **Use branch isolation** - Safest strategy for parallel work
3. **Update session files in real-time** - Don't wait until end
4. **Complete sessions cleanly** - Always run end protocol
5. **Check for conflicts before file modifications** - Not just at start
6. **Keep progress note entries concise** - Summary, not essay

---

*This reference documents the parallel session system for Claude Forge.*
