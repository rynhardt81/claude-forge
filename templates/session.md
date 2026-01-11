# Session {id}

**Started**: {YYYY-MM-DD HH:MM}
**Branch**: {branch-name}
**Scope**: {brief description}
**Status**: active

---

## Scope Declaration

**Branch**: `{branch-name}`

**Directories**:
- `{path/to/dir1}`
- `{path/to/dir2}`

**Files** (if specific):
- `{path/to/specific/file}`

**Features/Areas**:
- {feature area 1}
- {feature area 2}

---

## Conflict Check

Complete ALL checks before proceeding:

- [ ] Scanned `.claude/memories/sessions/active/` directory
- [ ] No branch conflicts (no other session on same branch)
- [ ] No directory conflicts (or user approved overlap)
- [ ] No file conflicts (or user approved overlap)

### Conflict Detection Results

| Check | Result | Notes |
|-------|--------|-------|
| Branch | {PASS/WARN/BLOCK} | {details} |
| Directories | {PASS/WARN} | {details} |
| Files | {PASS/ASK} | {details} |

### Other Active Sessions Found

| Session ID | Branch | Scope | Conflict? |
|------------|--------|-------|-----------|
| {none or list} | | | |

---

## Context Loaded

- [ ] Read `.claude/memories/progress-notes.md`
- [ ] Read relevant `completed/` sessions
- [ ] Checked `docs/tasks/registry.json` (if exists)
- [ ] Checked `docs/plans/` for existing plans

### Summary of Context

{Brief summary of what was learned from context loading}

---

## Working On

Current tasks in progress:

- [ ] {task description}

---

## Completed

Tasks completed this session:

_None yet_

---

## Blocked By

Dependencies or issues blocking progress:

_None_

---

## Key Decisions

| Decision | Context | Choice | Rationale |
|----------|---------|--------|-----------|
| | | | |

---

## Files Modified

| File | Change |
|------|--------|
| | |

---

## Commits Made

| Hash | Message |
|------|---------|
| | |

---

## Handoff Notes

Context for future sessions:

_To be filled at session end_

---

## Session End Checklist

Before closing this session:

- [ ] All "Working On" items moved to "Completed" or documented as blocked
- [ ] Handoff notes written
- [ ] All changes committed
- [ ] Session file moved to `completed/`
- [ ] Summary appended to `progress-notes.md`
- [ ] `latest.md` updated (only if no other active sessions)

---

## Lock History

| Action | Time | Reason |
|--------|------|--------|
| created | {timestamp} | Session started |
