# New Project Skill

## Purpose

The `/new-project` skill fully initializes a project with the Claude Forge framework, creating all required documentation for effective AI-assisted development. It runs a **continuous workflow** through all phases regardless of project type.

## Key Principle

**All projects get full documentation.** The framework's value comes from having PRD, architecture decisions, and feature planning in place. The `--autonomous` flag adds automated implementation tracking, but documentation is always created.

## Invocation

```
/new-project                                          # New project, full workflow
/new-project "project description"                    # New project with description
/new-project --current                                # Existing project, analyzes first
/new-project --autonomous                             # New + feature database for automation
/new-project --current --autonomous                   # Existing + feature database
/new-project --autonomous --mode=yolo                 # Fast autonomous mode
/new-project --minimal                                # Framework only, skip documentation
```

**Parameters:**
- `description` - Brief project description (optional, will prompt if not provided)
- `--current` - Existing project mode: analyze codebase, confirm findings with user
- `--autonomous` - Add feature database for `/implement-features` automation
- `--minimal` - Skip documentation phases (framework setup only)
- `--mode=standard` - Full browser testing (default, autonomous only)
- `--mode=yolo` - Lint only, no browser tests (autonomous only)
- `--mode=hybrid` - Browser tests for critical categories only (autonomous only)

## Mode Comparison

| Feature | Standard | --current | --autonomous | --minimal |
|---------|----------|-----------|--------------|-----------|
| Framework setup | Yes | Yes | Yes | Yes |
| Codebase analysis | No | Yes | If --current | No |
| PRD creation | Yes | Yes | Yes | No |
| Architecture docs | Yes | Yes | Yes | No |
| Feature planning | Yes (manual) | Yes (manual) | Yes (database) | No |
| Feature database | No | No | Yes | No |
| MCP server setup | No | No | Yes | No |

## Workflow Overview

The skill runs through phases **continuously**, guiding the user from start to finish:

```
┌─────────────────────────────────────────────────────────────┐
│ Phase 0: Framework Setup                        (ALL)       │
│ - Initialize .claude/ structure                             │
│ - Create CLAUDE.md from template                            │
│ - Set up memories and references                            │
├─────────────────────────────────────────────────────────────┤
│ Phase 1: Requirements Discovery                 (ALL)       │
│ - @analyst gathers requirements                             │
│ - @project-manager creates PRD                              │
│ - Output: docs/prd.md                                       │
├─────────────────────────────────────────────────────────────┤
│ Phase 2: Architecture & Standards               (ALL)       │
│ - @architect creates ADRs                                   │
│ - Populate reference documents                              │
│ - Output: .claude/reference/06-architecture-decisions.md    │
├─────────────────────────────────────────────────────────────┤
│ Phase 3: Feature Planning                       (ALL)       │
│ - @scrum-master breaks PRD into features                    │
│ - Map to 20 feature categories                              │
│ - Output: docs/feature-breakdown.md (manual tracking)       │
│         OR features.db (if --autonomous)                    │
├─────────────────────────────────────────────────────────────┤
│ Phase 4: Implementation Readiness     (--autonomous only)   │
│ - Set up MCP servers                                        │
│ - Initialize security model                                 │
│ - Configure testing mode                                    │
├─────────────────────────────────────────────────────────────┤
│ Phase 5: Kickoff                      (--autonomous only)   │
│ - Display summary                                           │
│ - Invoke /implement-features                                │
└─────────────────────────────────────────────────────────────┘
```

## Standard Mode (Default)

Creates full documentation for manual development:
- PRD document for requirements
- Architecture decisions documented
- Feature breakdown for tracking progress
- Ready to use `/new-feature`, `/fix-bug`, etc.

## Existing Project Mode (--current)

Same as standard, but starts by analyzing the codebase:
- Detects tech stack, project structure, existing commands
- Presents findings to user for confirmation
- Customizes all documentation based on existing code
- PRD reflects current state + planned enhancements

## Autonomous Mode (--autonomous)

Adds automated implementation tracking:
- Feature database instead of markdown file
- MCP server for feature state management
- Ready for `/implement-features` automation

---

## Phase 0: Project Setup (ALL MODES)

This phase runs for ALL projects:

### 0.1 Gather Project Information

**New Project (no --current):**
- Prompt user for project name, description, tech stack
- Use AskUserQuestion tool with options for common stacks
- Parse description if provided to infer details

**Existing Project (--current):**
- Analyze codebase structure using Glob and Read tools
- Detect tech stack from dependency files
- Extract project name from config files or directory
- Discover existing commands (npm scripts, Makefile, etc.)
- **Present findings to user for confirmation**
- Allow corrections before proceeding

### 0.2 Check Prerequisites

- Verify we're in a valid project directory
- Check for existing `.claude/CLAUDE.md` (warn if overwriting)

### 0.3 Initialize CLAUDE.md

- Read `.claude/templates/CLAUDE.template.md`
- Customize with gathered information:
  - Replace `[Project Name]` placeholder
  - Replace `[brief description]` placeholder
  - Update tech stack section
- Write to `.claude/CLAUDE.md`

### 0.4 Initialize Memories Structure

```
.claude/memories/
├── sessions/
│   └── latest.md
├── general.md
└── progress-notes.md
```

### 0.5 Initialize Project Memory Structure

Create the project memory system for capturing bugs, decisions, and patterns.

**Actions:**

1. Create directory:
```bash
mkdir -p docs/project-memory
```

2. Copy templates:
```bash
cp templates/project-memory/bugs.md docs/project-memory/
cp templates/project-memory/decisions.md docs/project-memory/
cp templates/project-memory/key-facts.md docs/project-memory/
cp templates/project-memory/patterns.md docs/project-memory/
```

3. Optionally populate key-facts.md with discovered project information:
   - Environment URLs
   - Detected conventions from existing code
   - Key dependencies

**Note:** The archive.db is NOT created here - it's created on first use via `/remember archive` or `/remember init-archive`.

### 0.6 Initialize Reference Documents

- Copy templates from `.claude/reference/` removing `.template` suffix
- **Delete the original `.template.md` files after copying**

```bash
# Example: For each template file
cp .claude/reference/01-system-overview.template.md .claude/reference/01-system-overview.md
rm .claude/reference/01-system-overview.template.md
```

This ensures only the active documents remain, avoiding confusion between templates and project-specific content.

### 0.7 Install Enforcement Hooks (CRITICAL)

**This step is CRITICAL for framework enforcement. Do NOT skip it.**

The hooks system enforces the mandatory gates defined in CLAUDE.md. Without hooks, gates are advisory only.

**Steps:**

1. **Ensure hooks scripts are executable:**
```bash
chmod +x .claude/hooks/*.sh
```

2. **Create settings.json from template:**
```bash
# Use the comprehensive template (includes hooks, permissions, MCP servers)
cp .claude/templates/settings.json .claude/settings.json

# Or use the hooks-only template if you want to customize permissions separately
# cp .claude/hooks/settings.example.json .claude/settings.json
```

3. **Verify hooks are correctly configured:**

The `.claude/settings.json` should contain:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/gate-check.sh\"",
            "timeout": 5
          },
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/validate-edit.sh\"",
            "timeout": 5
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "type": "command",
        "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/session-context.sh\"",
        "timeout": 5
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/session-end.sh\"",
        "timeout": 10
      }
    ]
  }
}
```

**What the hooks do:**

| Hook | Trigger | Effect |
|------|---------|--------|
| `gate-check.sh` | Before Edit/Write | Blocks code writes if no session or no registry |
| `validate-edit.sh` | Before Edit/Write | Blocks edits to protected files (.env, locks, etc.) |
| `session-context.sh` | Session start | Outputs compact status (session, tasks, gates) |
| `session-end.sh` | Session end | Updates session file, moves to completed/ |

**If hooks fail to install:**
- Framework will still work, but gates will be advisory only
- Claude may skip session protocol without being blocked
- Document the issue and proceed with verbal enforcement

### 0.8 Initialize Git (if not exists)

- `git init`
- Initial commit with framework files

### 0.9 Update Progress Notes

After Phase 0 completes, update `.claude/memories/progress-notes.md`:

```markdown
# Progress Notes: [Project Name]

**Last Updated:** [current date/time]
**Current Phase:** Phase 0 Complete

## Session Summary

Framework initialized for [PROJECT_NAME].

## Completed

- [x] Phase 0: Framework Setup
  - .claude/ structure created
  - CLAUDE.md customized with project details
  - Memories structure initialized
  - Reference document templates ready

## In Progress

- [ ] Phase 1: Requirements Discovery (next)

## Next Steps

1. Gather requirements via @analyst
2. Create PRD via @project-manager
3. Continue to architecture and feature planning
```

### 0.10 Phase 0 Checkpoint

Display checkpoint:
```
## Phase 0 Complete: Framework Initialized

✅ .claude/ structure created
✅ CLAUDE.md customized
✅ Memories initialized
✅ Project memory structure created (docs/project-memory/)
✅ Reference templates ready
✅ Enforcement hooks installed
✅ Progress notes updated

**Hooks Status:**
- gate-check.sh: Active (blocks code writes without session/registry)
- validate-edit.sh: Active (protects .env, lock files)
- session-context.sh: Active (provides status on session start)
- session-end.sh: Active (cleanup on session end)

**Next: Phase 1 - Requirements Discovery**

The framework is set up with ENFORCEMENT enabled.
Claude will be BLOCKED from writing code without:
1. An active session file
2. A task registry with tasks

Continue to create PRD and architecture documentation?
```

**If `--minimal` flag: STOP HERE.** Otherwise continue to Phase 1.

---

## Phase 1: Requirements Discovery (ALL MODES)

This phase creates the Product Requirements Document.

### 1.1 Invoke @analyst

- For **new projects**: Interview user about requirements
- For **existing projects (--current)**: Analyze codebase + ask about planned enhancements

Questions to gather:
- Core functionality and user goals
- Target users and use cases
- Key features and priorities
- Non-functional requirements (performance, security)
- Constraints and limitations

### 1.2 Invoke @project-manager

- Transform gathered requirements into structured PRD
- Use template: `.claude/templates/prd.md`
- Include: vision, goals, user stories, success criteria

### 1.3 Output

- Save PRD to: `docs/prd.md`
- This becomes a **Tier 2 master document**

### 1.4 Update Progress Notes

Append to `.claude/memories/progress-notes.md`:

```markdown
## Phase 1 Complete: [current date/time]

- [x] Phase 1: Requirements Discovery
  - @analyst gathered requirements
  - @project-manager created PRD
  - PRD saved to docs/prd.md
  - [X] user stories identified
  - [Key features listed]

## In Progress

- [ ] Phase 2: Architecture & Standards (next)

## Next Steps

1. Create ADRs via @architect
2. Populate reference documents
3. Continue to feature planning
```

### 1.5 Checkpoint

```
## Phase 1 Complete: PRD Created

📄 docs/prd.md created
✅ Progress notes updated

**Summary:**
- [X user stories identified]
- [Key features listed]
- [Success criteria defined]

Review the PRD and confirm to continue to Architecture phase?
```

---

## Phase 2: Architecture & Standards (ALL MODES)

This phase documents technical decisions and fills reference docs.

### 2.1 Invoke @architect

Based on PRD and tech stack, create Architecture Decision Records:
- ADR-001: Frontend framework choice
- ADR-002: Backend/API approach
- ADR-003: Database selection
- ADR-004: Authentication strategy
- ADR-005: Deployment approach

### 2.2 Populate Reference Documents

Update the reference templates with project-specific content:
- `01-system-overview.md` - From PRD summary
- `02-architecture-and-tech-stack.md` - From ADRs
- `03-security-auth-and-access.md` - Security decisions
- `04-development-standards-and-structure.md` - Coding standards

### 2.3 UX Planning (if UI project)

- Invoke @ux-designer for key user flows
- Create wireframe descriptions or diagrams
- Document in `docs/ux/` or reference docs

### 2.4 Output

- ADRs in: `.claude/reference/06-architecture-decisions.md`
- Reference docs populated with project specifics

### 2.5 Update Progress Notes

Append to `.claude/memories/progress-notes.md`:

```markdown
## Phase 2 Complete: [current date/time]

- [x] Phase 2: Architecture & Standards
  - @architect created ADRs
  - Reference documents populated
  - ADRs saved to .claude/reference/06-architecture-decisions.md
  - Key decisions:
    - ADR-001: [decision]
    - ADR-002: [decision]
    - ...

## In Progress

- [ ] Phase 3: Feature Planning (next)

## Next Steps

1. Break PRD into features via @scrum-master
2. Map features to 20 categories
3. Create feature tracking (markdown or database)
```

### 2.6 Checkpoint

```
## Phase 2 Complete: Architecture Documented

📐 ADRs created:
- ADR-001: [decision]
- ADR-002: [decision]
- ...

📚 Reference docs updated
✅ Progress notes updated

Review architecture decisions and continue to Feature Planning?
```

---

## Phase 3: Task Planning (ALL MODES)

This phase breaks down the PRD into epics and atomic tasks with dependencies.

### 3.1 Invoke @scrum-master

- Break PRD into epics (major feature areas)
- Break epics into atomic tasks (completable in one session)
- Define dependencies between tasks and epics
- Ensure no circular dependencies

**Key Principle: Atomic Tasks**

Each task must be completable in a single session to avoid context window exhaustion. If a task seems too large, break it into smaller tasks with dependencies.

### 3.2 Create Epic/Task Structure

#### 3.2.1 Initialize Task Registry

Create `docs/tasks/registry.json` using template `templates/task-registry.json`:

```json
{
  "project": "[PROJECT_NAME]",
  "version": "1.0.0",
  "lastUpdated": "[TIMESTAMP]",
  "settings": {
    "lockTimeoutSeconds": 3600,
    "allowManualUnlock": true,
    "maxParallelAgents": 3,
    "autoAssignNext": true
  },
  "stats": {
    "epics": { "total": 0, "completed": 0, "in_progress": 0, "blocked": 0 },
    "tasks": { "total": 0, "completed": 0, "in_progress": 0, "continuation": 0, "ready": 0, "pending": 0 }
  },
  "epics": [],
  "tasks": []
}
```

#### 3.2.2 Create Project Config

Create `docs/tasks/config.json` using template `templates/config.json`:
- Configure task management settings
- Set testing mode preferences
- Define category mappings

#### 3.2.3 Create Epic Files

For each epic, create a file structure:

```
docs/epics/
├── E01-authentication/
│   ├── E01-authentication.md      # Epic file
│   └── tasks/
│       ├── T001-setup-auth.md     # Task files
│       ├── T002-login-form.md
│       └── T003-session-mgmt.md
├── E02-dashboard/
│   ├── E02-dashboard.md
│   └── tasks/
│       ├── T004-layout.md
│       └── T005-charts.md
```

Use templates:
- `templates/epic-minimal.md` for epic files
- `templates/task.md` for task files

#### 3.2.4 Define Dependencies

**Epic-Level Dependencies:**
- E02 (Dashboard) depends on E01 (Authentication) completing
- Epic can't start until all dependencies complete

**Task-Level Dependencies:**
- T002 (Login Form) depends on T001 (Auth Setup)
- T003 (Session Mgmt) depends on T001 and T002
- Tasks within an epic often form a chain

**Cross-Epic Dependencies:**
- T010 (Dashboard Charts) may depend on T003 (Session Mgmt) from E01
- Tracked in task's `dependencies` array

**Validate No Circular Dependencies:**
- A → B → C → A is invalid
- Check during planning, reject if found

### 3.3 Map to Categories

Map each task to one of 20 categories (see `FEATURE-CATEGORIES.md`):
- A: Security & Auth
- B: Navigation
- C: Data (CRUD)
- ... through T: UI Polish

Categories help with:
- Priority ordering (Security first)
- Testing mode decisions (critical categories get full tests)
- Parallel work assignment

### 3.4 Calculate Ready Tasks

After defining all dependencies, calculate which tasks are "ready":

```
For each task:
  If all dependencies are "completed":
    Set status to "ready"
  Else:
    Set status to "pending"
```

Update registry stats with counts.

### 3.5 Output (varies by mode)

**Standard Mode (no --autonomous):**
- Create epic/task file structure in `docs/epics/`
- Create `docs/tasks/registry.json` for tracking
- Use with `/reflect resume T001` for implementation
- Agents work on tasks via `/reflect resume`

**Autonomous Mode (--autonomous):**
- Same epic/task structure
- Also create `features.db` for MCP server compatibility
- Ready for `/implement-features` automation

### 3.6 Update Progress Notes

Append to `.claude/memories/progress-notes.md`:

```markdown
## Phase 3 Complete: [current date/time]

- [x] Phase 3: Task Planning
  - @scrum-master created epic/task structure
  - [X] epics identified
  - [Y] total tasks created
  - [Z] tasks ready to start (no dependencies)
  - Tasks mapped to [N] categories
  - Output: docs/epics/, docs/tasks/registry.json

## Project Status

**Initialization Complete** (Phases 0-3)

- PRD: docs/prd.md
- ADRs: .claude/reference/06-architecture-decisions.md
- Task Registry: docs/tasks/registry.json
- Epics: docs/epics/

## Epic Overview

| ID | Name | Tasks | Ready | Status |
|----|------|-------|-------|--------|
| E01 | [Name] | X | Y | pending |
| E02 | [Name] | X | 0 | pending (depends: E01) |
| ... |

## Ready For

[If not autonomous]:
- Manual development using /reflect resume T001
- Multiple agents can work on independent ready tasks
- Use /reflect status to see available work

[If autonomous]:
- Phase 4: Implementation Readiness
- Phase 5: Kickoff with /implement-features
```

### 3.7 Update Latest Session

Also update `.claude/memories/sessions/latest.md` with current state:

```markdown
# Latest Session

**Date:** [current date/time]
**Phase Completed:** Phase 3 - Task Planning

## What Was Done

- Initialized Claude Forge framework
- Created PRD with [X] user stories
- Documented [Y] architecture decisions
- Broke down into [Z] atomic tasks across [N] epics

## Current State

Project initialization complete. Ready for [manual development | autonomous implementation].

## Task Summary

- **Total Epics:** [X]
- **Total Tasks:** [Y]
- **Ready Tasks:** [Z] (can start immediately)
- **Blocked Tasks:** [W] (waiting on dependencies)

## Key Documents

- PRD: docs/prd.md
- ADRs: .claude/reference/06-architecture-decisions.md
- Task Registry: docs/tasks/registry.json
- Epic Files: docs/epics/

## Next Steps

[If manual]:
- Run /reflect status to see available tasks
- Run /reflect resume T001 to start first task
- Multiple agents can work on independent tasks in parallel

[If autonomous]:
- Continue to Phase 4-5 for MCP setup and kickoff
```

### 3.8 Checkpoint

```
## Phase 3 Complete: Tasks Planned

📋 Task breakdown complete:
- [X] epics created
- [Y] total tasks
- [Z] tasks ready to start
- Mapped to [N] categories

**Task structure:**
- docs/epics/ - Epic and task files
- docs/tasks/registry.json - Master registry

**Dependencies validated:** No circular dependencies found

✅ Progress notes updated
✅ Session state saved

[If not autonomous]:
Project ready for development!

**Quick Start:**
- /reflect status         # See all tasks
- /reflect status --ready # See available tasks
- /reflect resume T001    # Start first task

Multiple agents can work on independent tasks in parallel.

[If autonomous]: Continue to Implementation Readiness?
```

**If NOT `--autonomous`: STOP HERE.** Project is ready for manual development.

---

## Phase 4: Implementation Readiness (--autonomous only)

This phase sets up automated implementation infrastructure.

### 4.1 Set up MCP Servers

- Feature tracking MCP server
- Browser automation MCP (if standard/hybrid testing mode)

### 4.2 Initialize Security Model

- Create/verify `.claude/security/allowed-commands.md`
- Configure command validators for project type

### 4.3 Configure Testing Mode

Based on `--mode` flag:
- `standard`: Full browser automation testing
- `yolo`: Lint and type-check only
- `hybrid`: Browser tests for critical categories only

### 4.4 Create init.sh

Development server startup script based on tech stack.

---

## Phase 5: Kickoff (--autonomous only)

### 5.1 Display Summary

```
## Project Ready for Autonomous Implementation

📊 Summary:
- Total features: [X]
- Categories: [Y]
- Testing mode: [standard/yolo/hybrid]

📋 First 5 features to implement:
1. [Feature name] (Category)
2. [Feature name] (Category)
3. ...

Ready to begin implementation with /implement-features?
```

### 5.2 Start Implementation

If user approves, invoke `/implement-features` to begin the automated loop.

## Execution Flow

```mermaid
graph TD
    A[/new-project invoked] --> B{--current flag?}
    B -->|Yes| C[Analyze existing codebase]
    B -->|No| D[Prompt for project details]
    C --> E[Present findings for confirmation]
    D --> F[Phase 0: Framework Setup]
    E --> F

    F --> G[Initialize .claude/ structure]
    G --> H[Create CLAUDE.md]
    H --> I[Set up memories & references]
    I --> J[Git init if needed]
    J --> K{--minimal flag?}
    K -->|Yes| L[STOP: Framework only]
    K -->|No| M[Phase 1: Requirements Discovery]

    M --> N[@analyst: Gather requirements]
    N --> O[@project-manager: Create PRD]
    O --> P[Save docs/prd.md]
    P --> Q[Checkpoint: Review PRD]

    Q --> R[Phase 2: Architecture & Standards]
    R --> S[@architect: Create ADRs]
    S --> T[Populate reference docs]
    T --> U{UI project?}
    U -->|Yes| V[@ux-designer: UX planning]
    U -->|No| W[Skip UX]
    V --> W
    W --> X[Checkpoint: Review architecture]

    X --> Y[Phase 3: Feature Planning]
    Y --> Z[@scrum-master: Break into features]
    Z --> AA[Map to 20 categories]
    AA --> AB{--autonomous flag?}
    AB -->|No| AC[Create feature-breakdown.md]
    AC --> AD[STOP: Ready for manual dev]
    AB -->|Yes| AE[Create features.db]

    AE --> AF[Phase 4: Implementation Readiness]
    AF --> AG[Set up MCP servers]
    AG --> AH[Initialize security model]
    AH --> AI[Configure testing mode]

    AI --> AJ[Phase 5: Kickoff]
    AJ --> AK[Display summary]
    AK --> AL{User approves?}
    AL -->|Yes| AM[Invoke /implement-features]
    AL -->|No| AN[Save state, exit]
```

## Phase Details

See companion files:
- `PHASES.md` - Detailed phase instructions
- `PRD-TEMPLATE.md` - PRD structure
- `FEATURE-CATEGORIES.md` - 20 category definitions
- `CHECKPOINTS.md` - User approval points
- `TESTING-MODES.md` - Standard vs YOLO vs Hybrid
- `MCP-SETUP.md` - MCP server configuration

## Integration Points

### Feature Database
- Uses `feature_create_bulk(features)` MCP tool
- Schema: id, priority, category, name, description, steps, passes, in_progress
- Persistence: `{project_root}/features.db`

### Security Model
- Reads: `.claude/security/allowed-commands.md`
- Validates all bash commands before execution
- Configurable per-project

### Documentation Hierarchy
- PRD becomes Tier 2 master document
- ADRs in `.claude/reference/06-architecture-decisions.md`
- Feature DB is source of truth for implementation scope

### Session Continuity
- Progress tracked in feature DB
- Git commits for code persistence
- Progress notes in `.claude/memories/progress-notes.md`

## Success Criteria

By the end of this skill:
- ✅ PRD document exists and is comprehensive
- ✅ Feature database contains 50-400+ features
- ✅ All features have testable acceptance criteria
- ✅ Architecture decisions documented
- ✅ Security model initialized
- ✅ MCP servers configured
- ✅ Ready for `/implement-features` skill

## Error Handling

### If project already initialized
- Check for existing `features.db`
- If exists: Error message, suggest `/implement-features` instead
- If PRD exists but no DB: Resume from Phase 2

### If user cancels mid-workflow
- Save current phase state
- Document in progress notes
- User can resume with `/new-project --resume`

### If MCP server setup fails
- Continue without MCP (degraded mode)
- Features tracked in JSON file instead of DB
- Warn user: "Manual verification required"

## Related Skills

- `/implement-features` - Incremental feature implementation (invoked after this skill)
- `/reflect` - Session continuity (used throughout)
- `/create-pr` - PR creation (used after feature batches)

## Examples

### Example 1: Standard Mode (Full Testing)
```
User: /new-project "E-commerce platform with user auth and Stripe payments"

Phase 1: Requirements Discovery
├─ @analyst interviews user about requirements
├─ @project-manager creates PRD
└─ PRD saved to docs/prd.md (15 pages)

Phase 2: Feature Breakdown
├─ @scrum-master breaks into 5 epics:
│  ├─ Epic 1: User Authentication (18 stories)
│  ├─ Epic 2: Product Catalog (25 stories)
│  ├─ Epic 3: Shopping Cart (15 stories)
│  ├─ Epic 4: Stripe Payments (22 stories)
│  └─ Epic 5: Admin Dashboard (12 stories)
├─ Maps 92 stories to 20 categories
├─ Creates 92 features in database
└─ Feature database initialized with 92 features

Phase 3: Technical Planning
├─ @architect creates ADRs:
│  ├─ ADR-001: Next.js + React for frontend
│  ├─ ADR-002: PostgreSQL for database
│  ├─ ADR-003: Stripe SDK for payments
│  ├─ ADR-004: NextAuth.js for authentication
│  └─ ADR-005: Vercel for deployment
└─ @ux-designer creates wireframes (12 screens)

Phase 4: Implementation Readiness
├─ Set up feature-tracking MCP server
├─ Set up Playwright MCP server
├─ Initialize security model (Node.js + Git + npm allowed)
└─ Create init.sh: npm run dev

Phase 5: Kickoff
├─ Project Summary:
│  ├─ Total features: 92
│  ├─ Categories: 20
│  ├─ Estimated complexity: Medium-High
│  ├─ Testing mode: Standard (full browser tests)
│  └─ Estimated sessions: 15-20
├─ First 5 features:
│  1. [Security] User can register with email/password
│  2. [Security] User can login with email/password
│  3. [Security] User session persists across page refreshes
│  4. [Navigation] User can view homepage with product grid
│  5. [Navigation] User can navigate to product detail page
└─ User approves ✓

Invoking /implement-features...
```

### Example 2: YOLO Mode (Rapid Prototyping)
```
User: /new-project "Simple blog with markdown posts" --mode=yolo

Phase 1-3: [Same as above, but simpler project]
├─ PRD created (5 pages)
├─ 35 features across 12 categories
└─ ADRs: Next.js, Markdown, SQLite

Phase 4: Implementation Readiness
├─ Set up feature-tracking MCP server
├─ SKIP Playwright MCP (YOLO mode)
├─ Initialize security model
└─ Create init.sh: npm run dev

Phase 5: Kickoff
├─ Testing mode: YOLO (lint only, no browser tests)
├─ Implementation will be ~5x faster
├─ Manual testing recommended after completion
└─ User approves ✓

Invoking /implement-features --mode=yolo...
```

### Example 3: Hybrid Mode (Critical Features Only)
```
User: /new-project "Internal admin dashboard" --mode=hybrid

Phase 4: Implementation Readiness
├─ Browser tests ONLY for categories:
│  ├─ Security & Access Control (full testing)
│  ├─ Payment & Financial Operations (full testing)
│  └─ Data Integrity (full testing)
├─ Lint only for categories:
│  ├─ UI Polish & Aesthetics
│  ├─ Help & Documentation
│  └─ Settings & Preferences

Balances speed and quality for internal tools
```

## Notes

- This skill works for **both new and existing projects**
- Use `--current` flag to analyze existing codebase first
- Use `--minimal` to skip documentation phases (framework setup only)
- Use `--autonomous` to add feature database for automated implementation
- The full workflow (Phases 0-3) takes 15-30 minutes depending on complexity
- Each phase has a checkpoint for user review and approval
- User can pause at any checkpoint and resume later
- Template files are deleted after reference docs are created

## See Also

- `../implement-features/SKILL.md` - Incremental implementation workflow
- `../../agents/orchestrator.md` - Overall workflow coordination
- `../../reference/09-autonomous-development.md` - Long-running agent patterns
