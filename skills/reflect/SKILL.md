---
name: reflect
description: Session continuity, task management, and skill improvement. Resume work, check status, manage locks, or capture learnings.
---

# Reflect Skill

## Purpose

1. **Session Continuity:** Resume work seamlessly with context
2. **Task Management:** Track epics, tasks, and dependencies
3. **Parallel Session Coordination:** Prevent conflicts between concurrent sessions
4. **Skill Improvement:** Extract learnings to make skills better over time
5. **Intelligent Dispatch:** Configure automatic sub-agent parallelization and intent detection

---

## Command Routing

Based on the command, load the appropriate flow file:

| Command | Flow File |
|---------|-----------|
| `/reflect resume` | [flows/resume.md](flows/resume.md) |
| `/reflect resume E##` | [flows/resume.md](flows/resume.md) |
| `/reflect resume T###` | [flows/resume.md](flows/resume.md) |
| `/reflect status` | [flows/status.md](flows/status.md) |
| `/reflect status --locked` | [flows/status.md](flows/status.md) |
| `/reflect status --ready` | [flows/status.md](flows/status.md) |
| `/reflect status --sessions` | [flows/status.md](flows/status.md) |
| `/reflect status --dispatch` | [flows/status.md](flows/status.md) |
| `/reflect unlock T###` | [flows/unlock.md](flows/unlock.md) |
| `/reflect cleanup` | [flows/unlock.md](flows/unlock.md) |
| `/reflect config` | [flows/config.md](flows/config.md) |
| `/reflect config <key> <value>` | [flows/config.md](flows/config.md) |
| `/reflect config dispatch` | [flows/config.md](flows/config.md) |
| `/reflect config intent` | [flows/config.md](flows/config.md) |
| `/reflect config --preset <name>` | [flows/config.md](flows/config.md) |
| `/reflect dispatch on/off` | [flows/config.md](flows/config.md) |
| `/reflect intent on/off` | [flows/config.md](flows/config.md) |
| `/reflect on/off` | [flows/config.md](flows/config.md) |
| `/reflect` (no args) | [flows/manual-reflection.md](flows/manual-reflection.md) |

**Dispatch flows (load when dispatch is enabled):**

| Trigger | Flow File |
|---------|-----------|
| Task parallelization | [dispatch/task-dispatch.md](dispatch/task-dispatch.md) |
| Feature parallelization | [dispatch/feature-dispatch.md](dispatch/feature-dispatch.md) |
| Intent detection | [dispatch/intent-detection.md](dispatch/intent-detection.md) |

---

## CRITICAL: Session Start Protocol

**Before doing ANY work, you MUST complete the session start protocol.**

This is not optional. This is not negotiable. See CLAUDE.md for full details.

### Quick Reference

```
1. Generate Session ID: {YYYYMMDD-HHMMSS}-{4-random}
2. Create Session File: .claude/memories/sessions/active/session-{id}.md
3. Declare Scope: branch, directories, features
4. Scan for Conflicts: read all files in active/
5. Load Context: progress-notes.md, completed sessions, registry
6. Proceed (only if no blocking conflicts)
```

### Conflict Resolution

| Conflict | Action |
|----------|--------|
| Same branch | **BLOCK** - Cannot proceed |
| Same directory | **WARN** - User must confirm |
| Same file | **ASK** - User decides priority |
| Merge/PR | **QUEUE** - Wait for first to complete |

---

## Task State Machine

```
                    ┌─────────────────────┐
                    │      pending        │
                    │  (deps not met)     │
                    └──────────┬──────────┘
                               │ dependencies complete
                               ▼
                    ┌─────────────────────┐
                    │       ready         │
                    │  (can be started)   │
                    └──────────┬──────────┘
                               │ /reflect resume T00X
                               ▼
                    ┌─────────────────────┐
         ┌─────────│    in_progress      │─────────┐
         │         │     (locked)        │         │
         │         └──────────┬──────────┘         │
         │                    │                    │
    session ends         completed            session crash
    (incomplete)              │               or timeout
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  continuation   │  │    completed    │  │  continuation   │
│ (needs resume)  │  │     (done)      │  │ (stale lock)    │
└────────┬────────┘  └─────────────────┘  └────────┬────────┘
         │                                         │
         └─────────────────────────────────────────┘
                               │
                    /reflect resume T00X
                               │
                               ▼
                    ┌─────────────────────┐
                    │    in_progress      │
                    │     (locked)        │
                    └─────────────────────┘
```

---

## Key Rules

- **Session Protocol First:** Never skip the session start protocol
- **Minimal Context Loading:** Only load what's needed for the specific task/epic
- **Lock Management:** Always acquire lock before starting, release on completion
- **Continuation Context:** When stopping mid-task, populate continuation section
- **Append Only:** Never overwrite progress-notes.md, always append
- **Always Commit:** Commit updates with clear messages
- **Deduplicate:** Check for existing learnings before adding
- **Flag Conflicts:** Surface conflicts for manual review
- **Track Skills:** Use .session-skills to track what was used

---

## Storage Locations

```
.claude/
├── memories/
│   ├── general.md              # General preferences
│   ├── progress-notes.md       # Append-only session log
│   ├── sessions/
│   │   ├── active/             # Currently running sessions
│   │   │   ├── .gitkeep
│   │   │   └── session-{id}.md
│   │   ├── completed/          # Archived sessions
│   │   │   ├── .gitkeep
│   │   │   └── session-{id}.md
│   │   ├── latest.md           # Most recent completed
│   │   └── README.md
│   ├── .reflect-status         # on/off toggle
│   ├── .reflect-config.json    # Reflection config
│   ├── .dispatch-config.json   # Intelligent dispatch config
│   └── .session-skills         # Skills used (temp)
└── skills/
    └── [skill-name]/
        └── SKILL.md            # Learned preferences here

docs/
├── tasks/
│   ├── registry.json           # Master task/epic registry
│   └── config.json             # Project configuration
└── epics/
    └── E01-epic-name/
        ├── E01-epic-name.md    # Epic file
        └── tasks/
            ├── T001-task.md    # Task files
            └── T002-task.md
```

---

## Context Budget

Target context usage for operations:

| Operation | Target | Max |
|-----------|--------|-----|
| Resume (general) | 8k tokens | 15k |
| Resume (epic) | 5k tokens | 10k |
| Resume (task) | 3k tokens | 6k |
| Status | 2k tokens | 4k |

This leaves 185k+ tokens for actual work.

---

## Related Files

- [SIGNALS.md](SIGNALS.md) - Learning signal detection
- [CHECKPOINTS.md](CHECKPOINTS.md) - Review checkpoints
- [UPDATE-RULES.md](UPDATE-RULES.md) - File update rules
