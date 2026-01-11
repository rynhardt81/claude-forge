# CLAUDE.md - Claude Forge Framework

This file provides Claude Code with **mandatory operating instructions** for this framework.

---

## CRITICAL: Framework Compliance

**THIS FRAMEWORK IS NON-OPTIONAL. YOU MUST FOLLOW IT.**

When this framework is present in a project's `.claude/` directory, you are **bound by its rules**. You cannot:

- Skip the session protocol "just this once"
- Implement code without following the workflow
- Rationalize that "this is a simple task" to bypass requirements
- Decide that the user "probably just wants you to code"
- Trust your memory of skills instead of invoking them

**If you think any of the following, STOP:**

| Thought | Reality | Action |
|---------|---------|--------|
| "This is just a small change" | Small changes bypass process | STOP. Follow protocol. |
| "I'll just quickly implement this" | Quick implementations cause conflicts | STOP. Session protocol first. |
| "The user wants me to code, not plan" | Users expect framework compliance | STOP. Framework is non-negotiable. |
| "I remember this skill" | Skills evolve. Memory is unreliable. | STOP. Invoke the Skill tool. |
| "This project is simple, I don't need all this" | You don't control what the user does | STOP. Follow protocol anyway. |
| "Let me just check one thing first" | One thing leads to scope creep | STOP. Session protocol first. |
| "I can update the session file later" | Delayed updates cause data loss | STOP. Update now. |

---

## Mandatory Session Protocol

**EVERY session MUST complete these steps IN ORDER before ANY other action:**

### Session Start Checklist

```
┌─────────────────────────────────────────────────────────────────┐
│                    SESSION START PROTOCOL                        │
│                                                                  │
│  You MUST complete ALL steps IN ORDER.                          │
│  You CANNOT skip steps.                                         │
│  You CANNOT proceed until all checks pass.                      │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ STEP 1: Generate Session ID                              │   │
│  │         Format: {YYYYMMDD-HHMMSS}-{4-random-chars}       │   │
│  │         Example: 20240115-143022-a7x9                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ STEP 2: Create Session File                              │   │
│  │         Path: .claude/memories/sessions/active/          │   │
│  │         File: session-{id}.md                            │   │
│  │         Use template: templates/session.md               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ STEP 3: Declare Scope                                    │   │
│  │         - Branch you're working on                       │   │
│  │         - Directories you'll modify                      │   │
│  │         - Features/areas you're working on               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ STEP 4: Scan for Conflicts                               │   │
│  │         Read ALL files in active/ directory              │   │
│  │         Compare scopes for overlap                       │   │
│  │         Apply conflict resolution matrix                 │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ STEP 5: Load Context                                     │   │
│  │         - Read progress-notes.md (append-only log)       │   │
│  │         - Read relevant completed/ sessions              │   │
│  │         - Check docs/tasks/registry.json if exists       │   │
│  │         - Check docs/plans/ for existing plans           │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ STEP 6: Confirm Ready                                    │   │
│  │         All conflict checks passed OR user approved      │   │
│  │         Context loaded and understood                    │   │
│  │         Scope is clear and documented                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓                                   │
│                     PROCEED WITH USER REQUEST                    │
└─────────────────────────────────────────────────────────────────┘
```

### Conflict Resolution Matrix

| Conflict Type | Detection | Resolution |
|---------------|-----------|------------|
| **Branch Collision** | Another active session has same branch | **BLOCK.** Cannot proceed. User must choose which session continues. |
| **Directory Overlap** | Scopes intersect (e.g., both touch `src/`) | **WARN.** User must confirm or narrow scope. |
| **File Collision** | Both sessions need same specific file | **ASK.** User decides priority. |
| **Merge Collision** | Both sessions trying to merge/PR | **QUEUE.** First session completes, second waits. |

### Session End Protocol

Before ending a session, you MUST:

1. **Update Session File**
   - Fill in completed work section
   - Add handoff notes for future sessions
   - Update status to `completed`

2. **Move Session File**
   - Move from `active/` to `completed/`

3. **Append to Progress Notes**
   - Append session summary to `progress-notes.md`
   - NEVER overwrite - always append with `---` separator

4. **Update latest.md**
   - ONLY if no other active sessions exist
   - Point to your completed session

---

## Inviolable Rules

**These rules cannot be broken. There are no exceptions.**

### Rule 1: Never Start Work Without Session Protocol

You MUST complete the session start protocol before:
- Writing any code
- Modifying any files
- Creating any plans
- Making any recommendations

**No exceptions.** Not even for "quick" tasks.

### Rule 2: Never Modify Files Outside Declared Scope

If you declared scope as `src/components/`, you CANNOT touch:
- `src/lib/` (not in scope)
- `tests/` (not in scope)
- Any file not in your declared directories

To expand scope: Update session file first, re-check for conflicts.

### Rule 3: Never Assume Requirements

If the user's request is ambiguous:
- ASK for clarification
- Do NOT assume what they meant
- Do NOT implement your interpretation

### Rule 4: Always Invoke Skills Via Tool

When a skill applies:
- Use the Skill tool to invoke it
- NEVER rely on memory of what a skill says
- NEVER paraphrase or summarize skill content

### Rule 5: Always Commit After Each Task

After completing each atomic task:
- Commit the changes
- Include task/feature ID in commit message
- Do NOT batch multiple tasks into one commit

### Rule 6: Never Skip Conflict Detection

Before modifying ANY file:
- Check if another active session claims it
- If conflict exists, STOP and notify user

### Rule 7: Append-Only for Progress Notes

The file `.claude/memories/progress-notes.md`:
- Is APPEND-ONLY
- NEVER overwrite existing content
- Always add new entries with `---` separator

### Rule 8: Update Session File in Real-Time

- Update "Working On" as you start tasks
- Move to "Completed" as you finish
- Do NOT wait until session end

---

## Framework Overview

**Claude Forge** is a framework for AI-assisted software development. It provides:

- **Agent Personas** - Specialized agents for different roles
- **Skills** - Reusable workflows for common tasks
- **Templates** - Standardized document formats
- **Security Model** - Safe autonomous operation boundaries
- **Task Management** - Epic/task tracking with dependencies
- **Session Management** - Parallel session support with conflict detection
- **Autonomous Development** - Full project implementation from idea to code

---

## Quick Reference

### Key Commands

| Command | Description |
|---------|-------------|
| `/new-project "idea"` | Full workflow: framework + PRD + ADRs + tasks |
| `/new-project --current` | Same, but analyzes existing codebase first |
| `/new-project --autonomous` | Add feature database for automated implementation |
| `/new-project --minimal` | Framework setup only (skip documentation) |
| `/migrate` | Migrate existing project to Claude Forge framework |
| `/migrate --skip-analysis` | Migrate without running brownfield analysis |
| `/reflect` | Capture session learnings and context |
| `/reflect resume` | Resume from last session with full context |
| `/reflect resume E01` | Resume specific epic |
| `/reflect resume T002` | Resume specific task |
| `/reflect status` | Show task/epic status overview |
| `/reflect status --ready` | Show tasks available to work on |
| `/reflect status --locked` | Show locked tasks |
| `/reflect unlock T002` | Force unlock a stale task |
| `/reflect config` | Show/update configuration |
| `/implement-features` | Implement features from database (autonomous mode) |

### Key Locations

| Location | Purpose |
|----------|---------|
| `agents/` | Agent persona definitions |
| `skills/` | Workflow skill definitions |
| `templates/` | Document templates |
| `reference/` | Architecture documentation |
| `security/` | Security model and allowlist |
| `mcp-servers/` | MCP server implementations |
| `docs/tasks/registry.json` | Task/epic registry |
| `docs/epics/` | Epic and task files |
| `.claude/memories/sessions/active/` | Currently running sessions |
| `.claude/memories/sessions/completed/` | Archived sessions |
| `.claude/memories/progress-notes.md` | Append-only session log |

---

## Parallel Session Support

### Directory Structure

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

### Session File Format

See `templates/session.md` for the full template. Key sections:

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

### Coordination Rules

| Scenario | Rule | Action |
|----------|------|--------|
| Same branch | **BLOCK** | Cannot proceed - user must choose which session continues |
| Same directory | **WARN** | Alert user, require explicit confirmation |
| Same file | **ASK** | Must get user approval before proceeding |
| Merge/PR | **EXCLUSIVE** | Only one session can merge at a time |

### Progress Notes Format (Append-Only)

Every session appends an entry like this:

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

---

## Project Initialization

### Key Principle

**All projects get full documentation.** The `/new-project` skill runs a continuous workflow that creates PRD, architecture decisions, and task planning.

### Standard Mode (Default)

```
/new-project "My project description"
```

Runs through all phases:

| Phase | What Happens | Output |
|-------|--------------|--------|
| 0 | Framework setup | `.claude/` structure, CLAUDE.md, memories |
| 1 | Requirements discovery | `docs/prd.md` |
| 2 | Architecture & standards | ADRs, populated reference docs |
| 3 | Task planning | `docs/epics/`, `docs/tasks/registry.json` |

### Existing Project Mode

```
/new-project --current
```

Analyzes your existing project first, then runs Phases 0-3.

### Autonomous Mode

```
/new-project "E-commerce app" --autonomous
```

Adds Phases 4-5 for feature database and MCP server setup.

### Minimal Mode

```
/new-project --minimal
```

Only runs Phase 0 (framework setup).

---

## Task Management

### Epic/Task Structure

```
docs/epics/
├── E01-authentication/
│   ├── E01-authentication.md      # Epic file
│   └── tasks/
│       ├── T001-setup-auth.md     # Task files
│       ├── T002-login-form.md
│       └── T003-session-mgmt.md
├── E02-dashboard/
│   └── ...
```

### Task States

| Status | Description |
|--------|-------------|
| `pending` | Dependencies not met yet |
| `ready` | All dependencies complete, can be started |
| `in_progress` | Currently being worked on (locked) |
| `continuation` | Partially complete, needs resume |
| `completed` | Done |

### Dependencies

- **Epic-Level:** E02 depends on E01 completing first
- **Task-Level:** T002 depends on T001 within same epic
- **Cross-Epic:** T010 may depend on T003 from different epic

### Parallel Work

Multiple sessions can work on independent tasks simultaneously:

```
Session 1: /reflect resume T001  # Works on authentication setup
Session 2: /reflect resume T010  # Works on dashboard (if no deps on T001)
```

The registry and session files prevent conflicts.

---

## Session Continuity

### Resume Commands

| Command | What It Does |
|---------|--------------|
| `/reflect resume` | Full context resume (git history, progress notes, registry) |
| `/reflect resume E01` | Resume specific epic, suggests next task |
| `/reflect resume T002` | Resume specific task, loads minimal context |

### Context Budget

| Operation | Target | Max |
|-----------|--------|-----|
| General resume | 8k tokens | 15k |
| Epic resume | 5k tokens | 10k |
| Task resume | 3k tokens | 6k |

### State Persistence

1. **Session Files** - `.claude/memories/sessions/active/` and `completed/`
2. **Progress Notes** - `.claude/memories/progress-notes.md` (append-only)
3. **Task Registry** - `docs/tasks/registry.json`
4. **Git Commits** - Task IDs in commit messages

---

## Security Model

### Allowlist Approach

All bash commands are validated against an allowlist:

- **Allowed:** npm, yarn, node, git, vite, jest, eslint, etc.
- **Blocked:** Commands not in the allowlist
- **Special Validators:** Extra checks for pkill, chmod, rm, curl, git

### What You Cannot Do

- Delete files recursively (`rm -rf`)
- Kill non-dev processes
- Force push to main/master
- Change file permissions (except `+x`)
- Access local files via curl

See `security/` directory for full documentation.

---

## Agent Personas

| Agent | Description | When to Use |
|-------|-------------|-------------|
| @developer | Implementation, coding | Feature development |
| @architect | System design, ADRs | Technical decisions |
| @project-manager | PRD, scope, priorities | Project planning |
| @scrum-master | Task breakdown, tracking | Sprint planning |
| @quality-engineer | Testing, browser automation | Verification |
| @security-boss | Security features, audits | Auth, payments |

Invoke with `@agent-name`:
```
@developer implement the login form
@architect review this design decision
```

---

## Skills System

**CRITICAL: Always use the Skill tool to invoke skills. Never rely on memory.**

| Skill | Purpose |
|-------|---------|
| `/reflect` | Session management and continuity |
| `/new-project` | Project initialization |
| `/migrate` | Migrate existing project to Claude Forge |
| `/new-feature` | Feature development workflow |
| `/fix-bug` | Bug fixing workflow |
| `/refactor` | Code refactoring workflow |
| `/create-pr` | Pull request creation |
| `/release` | Version release |
| `/implement-features` | Autonomous feature implementation |

---

## Error Handling

### Task Implementation Failure

If a task fails after 3 attempts:
1. Set status to `continuation`
2. Document blocker in task file
3. Move to next ready task

### Regression Failure

If regression tests fail:
1. **STOP implementation immediately**
2. Identify the regression
3. Fix before continuing
4. Never proceed with failing regressions

### Session Crash

On unexpected termination:
1. Check for uncommitted changes (`git status`)
2. Check for stale locks (`/reflect status --locked`)
3. Check for orphaned active sessions
4. Unlock/clean up if needed
5. Resume (`/reflect resume`)

---

## Best Practices

### Do

- Complete tasks atomically (one at a time)
- Commit after each task
- Run regression tests
- Update session file in real-time
- Respect checkpoint pauses
- Append to progress notes (never overwrite)

### Don't

- Skip session protocol
- Leave sessions in `active/` when done
- Work outside declared scope
- Ignore conflict warnings
- Batch multiple tasks without commits
- Trust memory instead of invoking skills

---

## Configuration

### View Configuration

```
/reflect config
```

### Update Settings

```
/reflect config lockTimeout 1800        # 30 minute lock timeout
/reflect config maxParallelAgents 5     # Allow 5 concurrent workers
/reflect config autoAssignNextTask false
```

### Configuration Options

| Setting | Default | Description |
|---------|---------|-------------|
| `lockTimeout` | 3600 | Seconds before lock is stale |
| `allowManualUnlock` | true | Allow /reflect unlock |
| `maxParallelAgents` | 3 | Max concurrent task locks |
| `autoAssignNextTask` | true | Auto-suggest next task |
| `sessionStaleTimeout` | 86400 | Seconds before active session is stale (24h) |

---

## Documentation Reference

| Document | Location |
|----------|----------|
| System Overview | `reference/01-system-overview.template.md` |
| Architecture | `reference/02-architecture-and-tech-stack.template.md` |
| Security (App) | `reference/03-security-auth-and-access.template.md` |
| Development Standards | `reference/04-development-standards-and-structure.template.md` |
| Security Model | `reference/08-security-model.template.md` |
| Autonomous Dev | `reference/09-autonomous-development.template.md` |
| Parallel Sessions | `reference/10-parallel-sessions.md` |

---

*This framework enables structured, safe, autonomous development with human oversight at key checkpoints.*
