# CLAUDE.md - Claude Forge Framework

This file provides Claude Code with **mandatory operating instructions** for this framework.

---

## ABSOLUTE GATES: NO CODE WITHOUT THESE

**YOU CANNOT WRITE A SINGLE LINE OF CODE until ALL gates are passed.**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MANDATORY GATES                                    │
│                                                                              │
│  Gate 1: SESSION ACTIVE                                                     │
│  ────────────────────────                                                   │
│  A session file MUST exist in .claude/memories/sessions/active/             │
│  If no session file exists → CREATE ONE FIRST                               │
│  You CANNOT proceed without an active session file                          │
│                                                                              │
│  Gate 2: EPICS AND TASKS EXIST                                              │
│  ────────────────────────────                                               │
│  For ANY development work, docs/tasks/registry.json MUST exist              │
│  AND contain epics with tasks. If it doesn't exist:                         │
│    → Run /new-project OR /new-project --current FIRST                       │
│    → This creates PRD, ADRs, Epics, and Tasks                               │
│  You CANNOT write code without a task to work on                            │
│  Exception: Framework maintenance tasks in .claude/ directory               │
│                                                                              │
│  Gate 3: WORKING ON A SPECIFIC TASK                                         │
│  ─────────────────────────────────                                          │
│  You MUST be working on a specific task from the registry                   │
│  Run /reflect resume T### to lock and work on a task                        │
│  You CANNOT implement "features" without a task ID                          │
│                                                                              │
│  Gate 4: SKILL INVOKED (not remembered)                                     │
│  ─────────────────────────────────────                                      │
│  For development workflows, you MUST invoke the Skill tool                  │
│  /new-feature, /fix-bug, /refactor → Use Skill tool                         │
│  You CANNOT "remember" what a skill does and skip invocation                │
│                                                                              │
│  Gate 5: AGENT DELEGATED (for specialized work)                             │
│  ─────────────────────────────────────────────                              │
│  For specialized work, you MUST invoke the appropriate agent:               │
│    - Security/Auth → @security-boss                                         │
│    - Architecture → @architect                                              │
│    - Testing → @quality-engineer                                            │
│    - PRD/Scope → @project-manager                                           │
│    - Task breakdown → @scrum-master                                         │
│  You CANNOT do specialized work without the right agent                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Gate Check Flow

**EVERY time you receive a development request, run this check:**

```
User Request Received
        │
        ▼
┌─────────────────────────┐
│ Gate 1: Session Active? │──No──▶ CREATE SESSION FILE FIRST
└───────────┬─────────────┘        Then return here
            │ Yes
            ▼
┌─────────────────────────┐
│ Gate 2: Registry exists │──No──▶ RUN /new-project FIRST
│ with epics and tasks?   │        Then return here
└───────────┬─────────────┘
            │ Yes
            ▼
┌─────────────────────────┐
│ Gate 3: Working on a    │──No──▶ RUN /reflect resume T### FIRST
│ specific task?          │        Then return here
└───────────┬─────────────┘
            │ Yes
            ▼
┌─────────────────────────┐
│ Gate 4: Skill invoked   │──No──▶ INVOKE SKILL TOOL FIRST
│ (not from memory)?      │        Then return here
└───────────┬─────────────┘
            │ Yes
            ▼
┌─────────────────────────┐
│ Gate 5: Right agent for │──No──▶ DELEGATE TO AGENT FIRST
│ this type of work?      │        Then return here
└───────────┬─────────────┘
            │ Yes
            ▼
        PROCEED WITH WORK
```

---

## CRITICAL: Framework Compliance

**THIS FRAMEWORK IS NON-OPTIONAL. YOU MUST FOLLOW IT.**

When this framework is present in a project's `.claude/` directory, you are **bound by its rules**. You cannot:

- Skip the session protocol "just this once"
- Implement code without following the workflow
- Rationalize that "this is a simple task" to bypass requirements
- Decide that the user "probably just wants you to code"
- Trust your memory of skills instead of invoking them
- Write code without epics and tasks defined first
- Skip agent delegation for specialized work

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
| "I don't need an epic/task for this" | ALL work needs tasks | STOP. Create task first. |
| "I can do this without the agent" | Agents ensure quality | STOP. Delegate to agent. |
| "Let me start coding first" | Documentation before code | STOP. Gates first. |

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
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ STEP 7: Dispatch Analysis (if dispatch enabled)          │   │
│  │         - Check .dispatch-config.json for settings       │   │
│  │         - Analyze task registry for parallelizable work  │   │
│  │         - Propose sub-agent dispatch if applicable       │   │
│  │         - See reference/11-intelligent-dispatch.md       │   │
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

### Rule 2: Never Write Code Without Epics and Tasks

You MUST have `docs/tasks/registry.json` with epics and tasks before:
- Writing any code
- Implementing any feature
- Fixing any bug

If no registry exists → Run `/new-project --current` FIRST.
If no task for this work → @scrum-master creates it FIRST.

### Rule 3: Never Skip Skill Invocation

You MUST invoke skills via the Skill tool:
- `/new-feature` for features
- `/fix-bug` for bugs
- `/refactor` for refactoring

You CANNOT rely on memory. Skills evolve. Always invoke.

### Rule 4: Never Skip Agent Delegation

You MUST delegate to the appropriate agent:
- @security-boss for security/auth/payments
- @architect for architecture decisions
- @project-manager for PRD/scope
- @scrum-master for task breakdown
- @quality-engineer for testing

You CANNOT do specialized work without the right agent.

### Rule 5: Never Modify Files Outside Declared Scope

If you declared scope as `src/components/`, you CANNOT touch:
- `src/lib/` (not in scope)
- `tests/` (not in scope)
- Any file not in your declared directories

To expand scope: Update session file first, re-check for conflicts.

### Rule 6: Never Assume Requirements

If the user's request is ambiguous:
- ASK for clarification
- Do NOT assume what they meant
- Do NOT implement your interpretation

### Rule 7: Always Commit After Each Task

After completing each atomic task:
- Commit the changes
- Include task/feature ID in commit message
- Do NOT batch multiple tasks into one commit

### Rule 8: Never Skip Conflict Detection

Before modifying ANY file:
- Check if another active session claims it
- If conflict exists, STOP and notify user

### Rule 9: Append-Only for Progress Notes

The file `.claude/memories/progress-notes.md`:
- Is APPEND-ONLY
- NEVER overwrite existing content
- Always add new entries with `---` separator

### Rule 10: Update Session File in Real-Time

- Update "Working On" as you start tasks
- Move to "Completed" as you finish
- Do NOT wait until session end

### Rule 11: Create Tasks for ALL Work

Every piece of work MUST have a task ID:
- New feature → Create task first
- Bug fix → Create task first
- Refactor → Create task first

You CANNOT work without a task ID.

### Rule 12: Epics MUST Have Tasks

You CANNOT create an epic without tasks:
- Epic creation → @scrum-master breaks into tasks
- Empty epics are invalid
- Every epic needs at least one task

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
- **Intelligent Dispatch** - Automatic sub-agent parallelization and intent detection

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
| `/reflect config dispatch` | Show dispatch configuration |
| `/reflect config intent` | Show intent detection configuration |
| `/reflect dispatch on/off` | Toggle automatic dispatch |
| `/reflect intent on/off` | Toggle intent detection |
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
| `.claude/memories/.dispatch-config.json` | Intelligent dispatch configuration |

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

## MANDATORY: Epic/Task Creation Before Development

**NO CODE without epics and tasks. This is a HARD GATE.**

### The Rule

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      DOCUMENTATION BEFORE CODE                               │
│                                                                              │
│  Before ANY development work, you MUST have:                                │
│                                                                              │
│  1. docs/prd.md                  ← Product requirements document            │
│  2. docs/tasks/registry.json     ← Task registry with epics and tasks       │
│  3. docs/epics/E##-*/            ← Epic directories with task files         │
│                                                                              │
│  If these don't exist → RUN /new-project --current FIRST                    │
│                                                                              │
│  YOU CANNOT:                                                                 │
│  - "Just add a quick feature" without a task                                │
│  - "Fix this small bug" without a task                                      │
│  - "Make this change" without a task                                        │
│                                                                              │
│  ALL work must be tracked. No exceptions.                                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Epic/Task Creation Flow

When user asks for development work and no registry exists:

```
User: "Add dark mode to the app"
      │
      ▼
Check: Does docs/tasks/registry.json exist?
      │
      ├─ NO → "I need to set up the project structure first.
      │        Running /new-project --current to create PRD,
      │        architecture docs, and task breakdown."
      │        Then invoke /new-project skill
      │
      └─ YES → Check: Is there a task for this work?
               │
               ├─ NO → "I need to create a task for this work.
               │        @scrum-master: Add task for dark mode to registry"
               │
               └─ YES → Proceed with /reflect resume T###
```

### Epics Cannot Be Empty

**Every epic MUST have tasks. Epics without tasks are invalid.**

```
VALID:
docs/epics/E01-authentication/
├── E01-authentication.md
└── tasks/
    ├── T001-setup-auth.md      ← At least one task
    ├── T002-login-form.md
    └── T003-session-mgmt.md

INVALID:
docs/epics/E01-authentication/
└── E01-authentication.md       ← No tasks directory = INVALID
```

### Task Structure

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

### Creating New Tasks Mid-Project

When new work arises that doesn't fit existing tasks:

1. **DO NOT** just start coding
2. **DO** invoke @scrum-master to create the task:
   ```
   @scrum-master: Create new task for [description] in [epic]
   ```
3. **THEN** use /reflect resume T### to work on it

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

## Intelligent Dispatch System

The framework includes an **Intelligent Dispatch System** that automatically parallelizes work and detects user intent. This is a framework behavior, not a skill - it runs automatically based on configuration.

### Core Components

| Component | Purpose |
|-----------|---------|
| **Sub-Agent Dispatch** | Analyzes task dependencies, spawns parallel agents for independent work |
| **Intent Detection** | Detects natural language patterns, suggests appropriate skills |

### Dispatch Triggers

Automatic dispatch analysis occurs at these points:

1. **At Resume** (`/reflect resume`) - Analyze registry for parallelizable tasks
2. **After Task Completion** - Re-analyze to find newly unblocked tasks
3. **After Feature Completion** - Check for parallelizable features

### Dispatch Flow

```
Session Start / Task Complete
        │
        ▼
┌─────────────────────────┐
│ Analyze Dependencies    │
│ - Task Registry: graph  │
│ - Features: categories  │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│ Found parallelizable    │────▶│ Config: dispatch.mode?  │
│ work items              │     └───────────┬─────────────┘
└─────────────────────────┘                 │
                              ┌─────────────┴─────────────┐
                              │                           │
                         "automatic"                  "confirm"
                              │                           │
                              ▼                           ▼
                    ┌─────────────────┐       ┌─────────────────────┐
                    │ Spawn agents    │       │ "I can parallelize: │
                    │ immediately     │       │  - T005, T006, T008 │
                    └─────────────────┘       │ Proceed?" [Y/n]     │
                                              └─────────────────────┘
```

### Task Registry Dispatch Rules

For tasks in `registry.json`:

1. **Get all `ready` tasks** - Dependencies met, not locked
2. **Build dependency graph** - Find independent clusters
3. **Check scope conflicts** - Exclude tasks with overlapping files/directories
4. **Rank by priority** - Higher priority tasks first
5. **Spawn sub-agents** - Each gets isolated scope and context

### Feature Database Dispatch Rules

For features in the feature database:

1. **Category Independence** - Different categories can often parallelize
2. **Same-Category Serialization** - Same category features share files, must serialize
3. **Critical Category Lock** - Categories A (Security) and P (Payment) never parallelize
4. **Priority Constraints** - Priority 1 features always sequential

### Intent Detection

**Trigger:** Every user message, before any other action.

When you receive a user message:

1. **Check for patterns** matching known skills
2. **Calculate confidence** based on keywords and context
3. **If confidence ≥ 0.7**, suggest the skill:

```
User: "Let's add dark mode to the app"
        │
        ▼
"This looks like a new feature request.
 Use `/new-feature` workflow? [Y/n]"
```

### Detected Skills

| Skill | Trigger Patterns |
|-------|------------------|
| `/new-feature` | "add feature", "implement", "build", "create new" |
| `/fix-bug` | "fix bug", "debug", "broken", "not working", "error in" |
| `/refactor` | "refactor", "clean up", "restructure", "improve code" |
| `/create-pr` | "create pr", "pull request", "ready for review" |
| `/release` | "release", "new version", "cut release", "publish" |
| `/reflect resume` | "continue", "resume", "pick up where", "last session" |
| `brainstorming` | "design", "think through", "explore options", "how should we" |
| `systematic-debugging` | "why is this", "investigate", "root cause", "diagnose" |
| `writing-plans` | "write plan", "implementation plan", "break down into steps" |

### Intent Detection Rules

- **Threshold:** Only suggest when confidence ≥ 0.7
- **Mode:** Always suggest, never auto-invoke (user must confirm)
- **Explicit commands:** If user types `/skill`, honor it - skip detection
- **Questions:** "How do I...?" is a question, not a request - answer directly
- **Negation:** "Don't create a PR" - detect negation, don't suggest
- **In workflow:** If already in a skill workflow, don't interrupt

### Configuration

Location: `.claude/memories/.dispatch-config.json`

```json
{
  "dispatch": {
    "enabled": true,
    "mode": "automatic",
    "maxParallelAgents": 3
  },
  "intentDetection": {
    "enabled": true,
    "mode": "suggest",
    "confidenceThreshold": 0.7
  }
}
```

| Setting | Options | Default |
|---------|---------|---------|
| `dispatch.enabled` | true/false | true |
| `dispatch.mode` | "automatic", "confirm" | "automatic" |
| `dispatch.maxParallelAgents` | 1-10 | 3 |
| `intentDetection.enabled` | true/false | true |
| `intentDetection.mode` | "suggest", "off" | "suggest" |
| `intentDetection.confidenceThreshold` | 0.5-1.0 | 0.7 |

### Quick Toggles

```
/reflect dispatch on       # Enable automatic dispatch
/reflect dispatch off      # Disable automatic dispatch
/reflect intent on         # Enable intent detection
/reflect intent off        # Disable intent detection
/reflect config --preset balanced  # Apply preset configuration
```

### Presets

| Preset | Description | Settings |
|--------|-------------|----------|
| `careful` | New projects | confirm mode, 2 agents, threshold 0.8 |
| `balanced` | Normal use | automatic mode, 3 agents, threshold 0.7 |
| `aggressive` | Large projects | automatic mode, 5 agents, threshold 0.6 |

### Sub-Agent Coordination

When spawning sub-agents:

1. **Session naming:** `{parent-session-id}-agent-{n}`
2. **Scope isolation:** Each agent gets non-overlapping directories
3. **Registry updates:** Agents update registry on completion
4. **Continuous check:** Parent re-analyzes after each completion

### Inviolable Dispatch Rules

1. **Never parallelize Security (A) or Payment (P)** - These require full attention
2. **Never exceed maxParallelAgents** - Respect the configured limit
3. **Always check scope conflicts** - Don't spawn if scopes would overlap
4. **Intent detection never auto-invokes** - Always suggests, user confirms

See `reference/11-intelligent-dispatch.md` for detailed algorithms and patterns.

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

## MANDATORY: Agent Delegation

**You MUST delegate to the appropriate agent. This is NOT optional.**

### Agent Routing Table (MANDATORY)

| Work Type | Agent | You MUST Delegate |
|-----------|-------|-------------------|
| Security, Auth, Payments | @security-boss | **YES - ALWAYS** |
| Architecture decisions, ADRs | @architect | **YES - ALWAYS** |
| PRD, requirements, scope | @project-manager | **YES - ALWAYS** |
| Epic/task breakdown | @scrum-master | **YES - ALWAYS** |
| Testing, QA, verification | @quality-engineer | **YES - ALWAYS** |
| UI/UX decisions | @ux-designer | **YES - ALWAYS** |
| Performance optimization | @performance-enhancer | **YES - ALWAYS** |
| API testing, integration | @api-tester | **YES - ALWAYS** |
| General implementation | @developer | YES (default) |

### How to Delegate

```markdown
@agent-name: [task description]

Example:
@security-boss: Review and implement the authentication flow for T001
@architect: Create ADR for database selection
@scrum-master: Break down E01 into atomic tasks
```

### Agent Delegation Violations

**These are violations. You MUST NOT:**

| Violation | Why It's Wrong | Correct Action |
|-----------|----------------|----------------|
| Implementing auth without @security-boss | Security requires expert review | @security-boss: implement auth |
| Creating ADRs without @architect | Architecture decisions need rigor | @architect: create ADR |
| Breaking down work without @scrum-master | Tasks may not be atomic | @scrum-master: break down epic |
| Doing QA without @quality-engineer | Testing needs structured approach | @quality-engineer: verify feature |
| Writing PRD without @project-manager | Scope needs proper definition | @project-manager: create PRD |

---

## MANDATORY: Skill Invocation

**You MUST invoke skills via the Skill tool. You CANNOT rely on memory.**

### Skill Invocation Rules

1. **ALWAYS use the Skill tool** - Never paraphrase or summarize skills
2. **Skills must be invoked, not remembered** - Skills evolve, memory is stale
3. **Skill content guides execution** - Follow the skill exactly as invoked

### Skill Routing Table (MANDATORY)

| User Intent | Skill to Invoke | Via Tool |
|-------------|-----------------|----------|
| "Add a feature", "implement", "build" | `/new-feature` | Skill tool |
| "Fix bug", "debug", "broken" | `/fix-bug` | Skill tool |
| "Refactor", "clean up", "restructure" | `/refactor` | Skill tool |
| "Create PR", "pull request" | `/create-pr` | Skill tool |
| "Release", "new version" | `/release` | Skill tool |
| "Resume", "continue work" | `/reflect resume` | Skill tool |
| "New project", "initialize" | `/new-project` | Skill tool |
| "Implement features" | `/implement-features` | Skill tool |

### Skill Invocation Violations

**These are violations. You MUST NOT:**

| Violation | Why It's Wrong | Correct Action |
|-----------|----------------|----------------|
| "I know how /new-feature works" | Skills evolve. Memory is unreliable. | Invoke Skill tool |
| Implementing without invoking skill | Skill provides workflow | Invoke skill FIRST |
| Paraphrasing skill content | You may miss steps | Read invoked skill exactly |
| Skipping skill "for simple tasks" | All tasks need workflow | Invoke skill regardless |

### Skill vs Agent Relationship

```
User Request
      │
      ▼
┌─────────────────────┐
│ Invoke Skill First  │  ← /new-feature, /fix-bug, etc.
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Skill Invokes Agent │  ← Skill tells you which agent
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Agent Does Work     │  ← @developer, @security-boss, etc.
└─────────────────────┘
```

---

## Skills Reference

| Skill | Purpose | Agents Used |
|-------|---------|-------------|
| `/reflect` | Session management and continuity | - |
| `/new-project` | Project initialization | @analyst, @project-manager, @architect, @scrum-master |
| `/migrate` | Migrate existing project to Claude Forge | @analyst |
| `/new-feature` | Feature development workflow | @developer, specialized agents as needed |
| `/fix-bug` | Bug fixing workflow | @developer, @quality-engineer |
| `/refactor` | Code refactoring workflow | @developer, @quality-engineer |
| `/create-pr` | Pull request creation | @developer |
| `/release` | Version release | @developer |
| `/implement-features` | Autonomous feature implementation | Multiple agents by category |

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
| `dispatch.enabled` | true | Enable automatic sub-agent dispatch |
| `dispatch.mode` | "automatic" | "automatic" or "confirm" before spawning |
| `intentDetection.enabled` | true | Enable natural language intent detection |
| `intentDetection.mode` | "suggest" | "suggest" or "off" |
| `intentDetection.confidenceThreshold` | 0.7 | Minimum confidence to suggest skill |

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
| Intelligent Dispatch | `reference/11-intelligent-dispatch.md` |

---

*This framework enables structured, safe, autonomous development with human oversight at key checkpoints.*
