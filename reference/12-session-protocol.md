# Session Protocol

This document provides the complete session management protocol for Claude Forge.

---

## Session Start Protocol

**EVERY session MUST complete these steps IN ORDER before ANY other action.**

### Step 1: Generate Session ID

Format: `{YYYYMMDD-HHMMSS}-{4-random-chars}`

Example: `20240115-143022-a7x9`

### Step 2: Create Session File

- **Path**: `.claude/memories/sessions/active/`
- **File**: `session-{id}.md`
- **Template**: `templates/session.md`

### Step 3: Declare Scope

Document in session file:
- Branch you're working on
- Directories you'll modify
- Features/areas you're working on
- Specific files (if applicable)

### Step 4: Scan for Conflicts

1. Read ALL files in `active/` directory
2. Compare scopes for overlap
3. Apply conflict resolution matrix (see below)

### Step 5: Load Context

Load in order:
1. `.claude/memories/progress-notes.md` (append-only log)
2. Relevant `completed/` sessions
3. `docs/tasks/registry.json` (if exists)
4. `docs/plans/` for existing plans

### Step 6: Confirm Ready

Verify:
- All conflict checks passed OR user approved
- Context loaded and understood
- Scope is clear and documented

### Step 7: Dispatch Analysis (Optional)

If dispatch is enabled:
1. Check `.dispatch-config.json` for settings
2. Analyze task registry for parallelizable work
3. Propose sub-agent dispatch if applicable

---

## Conflict Resolution Matrix

| Conflict Type | Detection | Resolution |
|---------------|-----------|------------|
| **Branch Collision** | Another active session has same branch | **BLOCK.** Cannot proceed. User must choose which session continues. |
| **Directory Overlap** | Scopes intersect (e.g., both touch `src/`) | **WARN.** User must confirm or narrow scope. |
| **File Collision** | Both sessions need same specific file | **ASK.** User decides priority. |
| **Merge Collision** | Both sessions trying to merge/PR | **QUEUE.** First session completes, second waits. |

### Conflict Detection Flow

```
For each file in active/:
    Read session file
    Extract: branch, directories, files
    Compare with my declared scope

    If same branch:
        BLOCK → "Session {id} is already on branch {branch}"

    If directory overlap:
        WARN → "Session {id} is working in {dirs}. Proceed? [y/N]"

    If file overlap:
        ASK → "Session {id} is modifying {file}. Who has priority?"
```

---

## Session End Protocol

Before ending a session, you MUST complete:

### 1. Update Session File

- Fill in completed work section
- Add handoff notes for future sessions
- Update status to `completed`

### 2. Move Session File

Move from `active/` to `completed/`:
```
.claude/memories/sessions/active/session-{id}.md
    → .claude/memories/sessions/completed/session-{id}.md
```

### 3. Append to Progress Notes

Append session summary to `.claude/memories/progress-notes.md`:

```markdown
---
### Session {id} - YYYY-MM-DD HH:MM
**Branch**: {branch}
**Scope**: {scope}
**Status**: completed
**Duration**: {time}

**Completed**:
- {task 1} (commit: {hash})
- {task 2} (commit: {hash})

**Key Decisions**:
- {decision}

**Handoff**:
- {next steps}
---
```

**CRITICAL**: NEVER overwrite progress-notes.md. Always APPEND with `---` separator.

### 4. Update latest.md

**ONLY** if no other active sessions exist:
- Point to your completed session
- This maintains single-session compatibility

---

## Directory Structure

```
.claude/memories/
├── progress-notes.md           # Append-only log (NEVER overwrite)
├── general.md                  # Project preferences
├── sessions/
│   ├── active/                 # Currently running sessions
│   │   ├── .gitkeep
│   │   └── session-{id}.md     # Your session file
│   ├── completed/              # Archived sessions
│   │   ├── .gitkeep
│   │   └── session-{id}.md     # Completed sessions
│   └── latest.md               # Points to most recent (single-session compat)
```

---

## Session File Format

Key sections in a session file:

```markdown
# Session {id}

**Started**: YYYY-MM-DD HH:MM
**Branch**: {git-branch}
**Scope**: {declared working area}
**Status**: active | completed | blocked

## Scope Declaration
- **Branch**: `feature/my-feature`
- **Directories**: [`src/components/`, `src/lib/utils/`]
- **Files**: [`src/config.ts`] (if specific)
- **Features**: [Feature areas being worked on]

## Conflict Check
- [ ] Scanned active/ directory
- [ ] No branch conflicts
- [ ] No directory conflicts (or user approved)
- [ ] No file conflicts (or user approved)

## Working On
- [ ] Current task

## Completed
- [x] Done item (commit: abc123)

## Handoff Notes
Context for future sessions...
```

See `templates/session.md` for the full template.

---

## Scope Management

### Expanding Scope

If you need to modify files outside declared scope:

1. Update session file with new scope
2. Re-run conflict detection
3. Wait for any new conflicts to be resolved
4. Then proceed with modifications

### Scope Violation

If you declared scope as `src/components/`, you CANNOT touch:
- `src/lib/` (not in scope)
- `tests/` (not in scope)
- Any file not in your declared directories

This is **Rule 5** of the inviolable rules.

---

## Real-Time Updates

### Rule 10: Update Session File in Real-Time

You MUST update the session file as you work:

- Update "Working On" when you START a task
- Move to "Completed" when you FINISH a task
- Do NOT wait until session end
- Do NOT batch updates

This ensures:
- Other sessions see what you're working on
- Progress is not lost on crash
- Handoff is always current

---

## Session Recovery

### On Unexpected Termination

1. Check for uncommitted changes: `git status`
2. Check for stale locks: `/reflect status --locked`
3. Check for orphaned active sessions
4. Unlock/clean up if needed
5. Resume: `/reflect resume`

### Stale Session Detection

A session is considered stale if:
- `sessionStaleTimeout` (default 24h) has passed
- No commits from that session
- No updates to session file

Stale sessions can be cleaned up manually.

---

## Coordination with Parallel Sessions

| Scenario | Rule | Action |
|----------|------|--------|
| Same branch | **BLOCK** | Cannot proceed - user must choose |
| Same directory | **WARN** | Alert user, require explicit confirmation |
| Same file | **ASK** | Must get user approval |
| Merge/PR | **EXCLUSIVE** | Only one session can merge at a time |

See [10-parallel-sessions.md](10-parallel-sessions.md) for more details.

---

## Configuration Options

| Setting | Default | Description |
|---------|---------|-------------|
| `sessionStaleTimeout` | 86400 | Seconds before active session is stale (24h) |

Configure via `/reflect config`.
