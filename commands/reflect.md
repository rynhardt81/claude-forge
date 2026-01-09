---
name: reflect
description: Session continuity, task management, and skill improvement. Resume work, check status, manage locks, or capture learnings.
argument-hint: "[resume [E01|T002]] [status [--locked|--ready]] [unlock <id>] [config [key value]] [on|off]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite, AskUserQuestion
---

# /reflect Command

Manages session continuity, task tracking, and skill improvement.

## Quick Reference

| Command | Description |
|---------|-------------|
| `/reflect` | Capture session learnings |
| `/reflect resume` | Resume from last session |
| `/reflect resume E01` | Resume specific epic |
| `/reflect resume T002` | Resume specific task |
| `/reflect status` | Show task/epic overview |
| `/reflect status --locked` | Show locked tasks |
| `/reflect status --ready` | Show available tasks |
| `/reflect unlock T002` | Force unlock a task |
| `/reflect config` | Show configuration |
| `/reflect config lockTimeout 1800` | Update setting |
| `/reflect on` | Enable auto-reflection |
| `/reflect off` | Disable auto-reflection |

## Arguments

**Raw Arguments:** $ARGUMENTS

## Argument Parsing

Parse the arguments to determine which subcommand to execute:

```
/reflect                     → Manual reflection (capture learnings)
/reflect resume              → General resume (full context)
/reflect resume E##          → Resume specific epic
/reflect resume T###         → Resume specific task
/reflect status              → Show all status
/reflect status --locked     → Show only locked
/reflect status --ready      → Show only ready
/reflect unlock T###         → Unlock specific task
/reflect config              → Show config
/reflect config <key> <val>  → Update config
/reflect on                  → Enable auto-reflect
/reflect off                 → Disable auto-reflect
```

## Execution

Based on parsed arguments, follow the corresponding section in the skill file:

**Skill Location:** `skills/reflect/SKILL.md`

### For `resume` commands:
- Read "Resume Commands" section
- Follow the flow for general, epic, or task resume
- Load minimal context (stay under token budget)
- Present context and confirm before continuing

### For `status` commands:
- Read "Status Commands" section
- Query `docs/tasks/registry.json` for current state
- Format output based on flags (--locked, --ready, or all)

### For `unlock` command:
- Read "Unlock Commands" section
- Validate the task ID exists and is locked
- Check if stale, warn if not
- Update registry and task file on confirmation

### For `config` commands:
- Read "Config Commands" section
- If no key/value: show current config
- If key/value provided: validate and update

### For `on`/`off`:
- Toggle auto-reflection in `.claude/memories/.reflect-status`

### For no arguments (manual reflection):
- Read "Manual Reflection Flow" section
- Scan conversation for learning signals
- Present proposed updates for approval

## Key Files

| File | Purpose |
|------|---------|
| `docs/tasks/registry.json` | Master task/epic registry |
| `docs/tasks/config.json` | Project configuration |
| `.claude/memories/sessions/latest.md` | Last session state |
| `.claude/memories/progress-notes.md` | Work summaries |
| `.claude/memories/.reflect-status` | Auto-reflect toggle |
| `.claude/memories/.reflect-config.json` | Reflect settings |

## Context Budget

Keep resume context minimal to leave room for work:

| Operation | Target | Max |
|-----------|--------|-----|
| General resume | 8k tokens | 15k |
| Epic resume | 5k tokens | 10k |
| Task resume | 3k tokens | 6k |
| Status | 2k tokens | 4k |

## Examples

### Resume from last session
```
/reflect resume
```
Loads git history, memory files, and task registry. Shows combined context and asks to continue.

### Resume specific task
```
/reflect resume T014
```
Loads only T014's task file, continuation context if any, and acquires lock.

### Check what's available
```
/reflect status --ready
```
Shows tasks with all dependencies met that aren't locked.

### Unlock crashed session
```
/reflect unlock T022
```
Clears stale lock, sets status to continuation, records in lock history.

### Change lock timeout
```
/reflect config lockTimeout 1800
```
Sets lock timeout to 30 minutes (1800 seconds).
