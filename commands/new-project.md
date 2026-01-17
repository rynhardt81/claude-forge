---
name: new-project
description: Initialize a project with Claude Forge framework - creates full documentation (PRD, ADRs, features) for effective AI-assisted development
argument-hint: "project description" [--current] [--autonomous] [--minimal]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite, AskUserQuestion
---

# /new-project Skill

You are initializing a project using the Claude Forge framework. This skill runs a **continuous workflow** that creates all documentation needed for effective AI-assisted development.

## Key Principle

**All projects get full documentation.** The framework's value comes from having PRD, architecture decisions, and feature planning in place. Use `--minimal` to skip documentation phases if only framework setup is needed.

## Arguments Received

**Raw Arguments:** $ARGUMENTS

## Step 1: Parse Arguments and Determine Mode

### 1.1 Parse Flags

Extract from arguments:
- `--current` flag → **Existing Project Mode** (analyze codebase first)
- `--autonomous` flag → **Add feature database** for `/implement-features`
- `--minimal` flag → **Framework only** (skip documentation phases)
- `--mode=yolo|standard|hybrid` → Testing mode (autonomous only)
- Everything else → Project description

### 1.2 Determine Workflow

| Flags | Phases | Output |
|-------|--------|--------|
| (none) | 0-3 | Framework + PRD + ADRs + feature-breakdown.md |
| `--current` | 0-3 | Same, but analyzes existing codebase first |
| `--autonomous` | 0-5 | Above + features.db + MCP setup |
| `--minimal` | 0 only | Framework setup only, no documentation |

---

## Step 2: Gather Project Information

### 2A: For NEW Projects (no --current flag)

**If no project description was provided (or it's empty/just flags):**

Use the AskUserQuestion tool to gather essential project information:

```
Question 1: "What is your project name?"
  - Header: "Project"
  - Options: [Free text input via "Other"]

Question 2: "Briefly describe what this project does"
  - Header: "Description"
  - Options: [Free text input via "Other"]

Question 3: "What is the primary tech stack?"
  - Header: "Tech Stack"
  - Options:
    - "Next.js + React (Recommended)" - Full-stack React framework
    - "Node.js + Express" - Backend API server
    - "Python + FastAPI" - Modern Python web framework
    - "Other" - Specify custom stack
```

**If project description WAS provided:**

Parse the description to extract:
- Project name (infer from description or ask)
- Brief description (use provided text)
- Tech stack (infer from keywords like "React", "Python", "Node", etc., or ask)

---

### 2B: For EXISTING Projects (--current flag)

**Analyze the existing codebase to discover project details:**

#### 2B.1 Discover Project Structure

Use Glob and Read tools to analyze:

```
1. Check for package.json, requirements.txt, go.mod, Cargo.toml, etc.
2. Identify project structure (src/, app/, lib/, etc.)
3. Look for existing README.md or documentation
4. Check for existing tests (tests/, __tests__/, spec/)
5. Identify frameworks from dependencies
```

#### 2B.2 Detect Tech Stack

Analyze dependency files to determine:

| File | Indicates |
|------|-----------|
| `package.json` | Node.js project - check for React, Next.js, Express, etc. |
| `requirements.txt` / `pyproject.toml` | Python - check for FastAPI, Django, Flask |
| `go.mod` | Go project |
| `Cargo.toml` | Rust project |
| `pom.xml` / `build.gradle` | Java project |
| `*.csproj` | .NET project |

#### 2B.3 Extract Project Name

Look for project name in:
1. `package.json` → `name` field
2. `pyproject.toml` → `[project] name`
3. Directory name as fallback
4. Existing README.md title

#### 2B.4 Present Findings for Confirmation

Display discovered information to user:

```markdown
## Existing Project Analysis

I've analyzed your codebase and found:

**Project Name:** [discovered name]
**Description:** [from README or inferred]

**Tech Stack:**
- **Frontend:** [React/Vue/Angular/None detected]
- **Backend:** [Express/FastAPI/Django/None detected]
- **Database:** [PostgreSQL/MongoDB/SQLite/None detected]
- **Testing:** [Jest/Pytest/None detected]

**Project Structure:**
```
[show directory tree]
```

**Key Files Found:**
- [list important files]

**Existing Commands:** (from package.json scripts or Makefile)
- `npm run dev` - Start development
- `npm test` - Run tests
- ...
```

#### 2B.5 User Confirmation

Use AskUserQuestion to confirm or correct:

```
Question 1: "Is this analysis correct?"
  - Header: "Confirm"
  - Options:
    - "Yes, proceed with these details" - Continue with discovered info
    - "Partially correct" - Let me make corrections
    - "No, let me provide details manually" - Fall back to manual input

Question 2 (if "Partially correct"): "What needs correction?"
  - Header: "Corrections"
  - Options: [Free text via "Other"]
```

---

## Step 3: Store Project Information

After gathering (new project) or confirming (existing project):

- `PROJECT_NAME` - The project name
- `PROJECT_DESCRIPTION` - What the project does
- `TECH_STACK` - Primary technologies (frontend, backend, database)
- `PROJECT_TYPE` - "new" or "existing"
- `EXISTING_COMMANDS` - (existing only) Commands found in project

---

## Phase 0: Framework Setup (ALL MODES)

This phase runs for ALL projects. Complete these steps:

### 0.1 Check Prerequisites

```
- Verify we're in a project directory (not the framework itself)
- Check if .claude/CLAUDE.md already exists (warn if overwriting)
- Verify .claude/ directory exists (should exist from clone)
```

### 0.2 Initialize CLAUDE.md

1. Read the template: `.claude/templates/CLAUDE.template.md`
2. Customize the template using gathered/discovered information:
   - Replace `[Project Name]` with `PROJECT_NAME`
   - Replace `[brief description of what the project does]` with `PROJECT_DESCRIPTION`
   - Update Section 3 (Project Overview) with tech stack:
     - Backend: (from TECH_STACK)
     - Frontend: (from TECH_STACK)
     - Database: (from TECH_STACK or infer)
   - **For existing projects (--current):**
     - Update Section 4 (Essential Commands) with `EXISTING_COMMANDS`
     - Update Section 5 (Architecture Summary) with discovered structure
3. Write customized content to: `.claude/CLAUDE.md`

### 0.3 Initialize Memories Structure

Create the following files if they don't exist:

```
.claude/memories/
├── sessions/
│   └── latest.md       # "No previous session recorded."
├── general.md          # "# General Memories\n\nProject-wide learnings."
└── progress-notes.md   # "# Progress Notes\n\n## Current Status\nProject initialized."
```

### 0.4 Initialize Reference Documents

1. Copy reference templates (remove .template suffix)
2. **Delete the original .template.md files after copying**

```bash
# For each template file:
cp .claude/reference/01-system-overview.template.md .claude/reference/01-system-overview.md
rm .claude/reference/01-system-overview.template.md
# Repeat for all template files
```

Files to create:
```
.claude/reference/
├── 01-system-overview.md
├── 02-architecture-and-tech-stack.md
├── 03-security-auth-and-access.md
├── 04-development-standards-and-structure.md
├── 05-operational-and-lifecycle.md
├── 06-architecture-decisions.md
└── 07-non-functional-requirements.md
```

### 0.5 Initialize Git (if needed)

```bash
# Only if .git doesn't exist
git init
git add .claude/CLAUDE.md .claude/
git commit -m "chore: Initialize Claude Forge framework

- Add CLAUDE.md project instructions
- Initialize .claude/ framework structure
- Set up memories and reference docs

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 0.6 Update Progress Notes

After Phase 0, update `.claude/memories/progress-notes.md` with:
- Project name and description
- Phase 0 completion status
- Next steps (Phase 1)

This ensures `/reflect resume` has context if the workflow is interrupted.

### 0.7 Phase 0 Checkpoint

Display:

```
## Phase 0 Complete: Framework Initialized

✅ .claude/ structure created
✅ CLAUDE.md customized
✅ Memories initialized
✅ Reference templates ready
✅ Progress notes updated

**Next: Phase 1 - Requirements Discovery**

Continue to create PRD and architecture documentation?
```

**If `--minimal` flag: STOP HERE and display minimal completion message.**

---

## Phase 1: Requirements Discovery (ALL except --minimal)

### 1.1 Invoke @analyst

- For **new projects**: Interview user about requirements
- For **existing projects (--current)**: Analyze codebase + ask about planned enhancements

Use Task tool to invoke analyst agent for requirements gathering.

Questions to gather:
- Core functionality and user goals
- Target users and use cases
- Key features and priorities
- Non-functional requirements (performance, security)
- Constraints and limitations

### 1.2 Invoke @project-manager

Use Task tool to invoke project-manager agent to create PRD.

- Transform gathered requirements into structured PRD
- Use template: `.claude/templates/prd.md`
- Include: vision, goals, user stories, success criteria

### 1.3 Save PRD

- Create `docs/` directory if it doesn't exist
- Save PRD to: `docs/prd.md`
- This becomes a **Tier 2 master document**

### 1.4 Update Progress Notes

Append to `.claude/memories/progress-notes.md`:
- Phase 1 completion with PRD summary
- Number of user stories identified
- Next steps (Phase 2)

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

## Phase 2: Architecture & Standards (ALL except --minimal)

### 2.1 Invoke @architect

Use Task tool to invoke architect agent.

Based on PRD and tech stack, create Architecture Decision Records:
- ADR-001: Frontend framework choice
- ADR-002: Backend/API approach
- ADR-003: Database selection
- ADR-004: Authentication strategy
- ADR-005: Deployment approach

### 2.2 Populate Reference Documents

Update the reference docs with project-specific content:
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
- Phase 2 completion with ADR summary
- Key architecture decisions made
- Next steps (Phase 3)

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

## Phase 3: Task Planning (ALL except --minimal)

**CRITICAL: Phase 3 must survive context compaction.** All progress is tracked in `.claude/memories/phase3-progress.json` to enable resume.

### 3.0 Check for Incomplete Phase 3 (MUST DO FIRST)

Before starting Phase 3, check if there's incomplete work:

```bash
# Check for existing phase3-progress.json
if [ -f ".claude/memories/phase3-progress.json" ]; then
  status=$(grep '"status"' .claude/memories/phase3-progress.json | head -1)
  if [[ "$status" == *"in_progress"* ]]; then
    echo "INCOMPLETE PHASE 3 DETECTED - Resume required"
  fi
fi
```

**If incomplete Phase 3 found:**
1. Read `.claude/memories/phase3-progress.json`
2. Compare `createdEpics` vs `plannedEpics`
3. Compare `createdTasks` vs `plannedTasks`
4. Resume from first uncreated epic/task
5. DO NOT re-invoke @scrum-master (plan already exists)

### 3.1 Invoke @scrum-master (First Time Only)

**Skip if resuming from incomplete Phase 3.**

Use Task tool to invoke scrum-master agent.

- Break PRD into epics (major feature areas)
- Break epics into atomic tasks (completable in one session)
- Define dependencies between tasks and epics
- Ensure no circular dependencies

**Key Principle:** Each task must be completable in a single session to avoid context window exhaustion.

### 3.2 Initialize Phase 3 Progress Tracking

**IMMEDIATELY after @scrum-master returns the plan, BEFORE creating any files:**

Create `.claude/memories/phase3-progress.json`:

```json
{
  "phase": "3",
  "phaseName": "Task Planning",
  "status": "in_progress",
  "startedAt": "[TIMESTAMP]",
  "lastUpdatedAt": "[TIMESTAMP]",
  "completedAt": null,

  "plannedEpics": [
    {"id": "E01", "name": "Authentication", "taskCount": 3},
    {"id": "E02", "name": "Dashboard", "taskCount": 2}
  ],
  "createdEpics": [],

  "plannedTasks": [
    {"id": "T001", "epic": "E01", "name": "Setup auth"},
    {"id": "T002", "epic": "E01", "name": "Login form"},
    {"id": "T003", "epic": "E01", "name": "Session mgmt"},
    {"id": "T004", "epic": "E02", "name": "Layout"},
    {"id": "T005", "epic": "E02", "name": "Charts"}
  ],
  "createdTasks": [],

  "currentEpic": null,
  "currentTask": null,

  "summary": {
    "epicsPlanned": 2,
    "epicsCreated": 0,
    "tasksPlanned": 5,
    "tasksCreated": 0
  },

  "checkpoints": [],
  "resumeInstructions": "Resume from first uncreated epic"
}
```

**This file is the source of truth for Phase 3 progress.** It survives context compaction.

### 3.3 Create Epic/Task Structure (With Incremental Tracking)

#### 3.3.1 Initialize Task Registry

Create `docs/tasks/registry.json` using template `templates/task-registry.json`.

#### 3.3.2 Create Project Config

Create `docs/tasks/config.json` using template `templates/config.json`.

#### 3.3.3 Create Epic Files (ONE AT A TIME with Progress Updates)

**CRITICAL: Update progress file after EACH epic and task creation.**

For each epic in `plannedEpics`:

1. **Update currentEpic** in phase3-progress.json:
   ```json
   "currentEpic": "E01"
   ```

2. **Create epic directory and file:**
   ```
   docs/epics/E01-authentication/
   ├── E01-authentication.md
   └── tasks/
   ```
   Use template: `templates/epic-minimal.md`

3. **Create all tasks for this epic (one at a time):**

   For each task in this epic:
   - Update `currentTask` in phase3-progress.json
   - Create task file using `templates/task.md`
   - **IMMEDIATELY** add task to `createdTasks` array
   - Update `summary.tasksCreated`
   - Update `lastUpdatedAt`

4. **Mark epic complete:**
   - Add epic to `createdEpics` array
   - Update `summary.epicsCreated`
   - Set `currentEpic` to null
   - Add checkpoint entry

5. **Repeat for next epic**

**Example progress after creating T001:**
```json
{
  "createdTasks": [
    {"id": "T001", "epic": "E01", "name": "Setup auth", "createdAt": "..."}
  ],
  "currentEpic": "E01",
  "summary": {"epicsPlanned": 2, "epicsCreated": 0, "tasksPlanned": 5, "tasksCreated": 1},
  "checkpoints": [{"timestamp": "...", "action": "Created T001", "progress": "1/5 tasks"}]
}
```

#### 3.3.4 Define Dependencies

- **Epic-Level:** E02 depends on E01 completing
- **Task-Level:** T002 depends on T001
- **Cross-Epic:** T010 may depend on T003 from another epic
- **Validate:** No circular dependencies (A → B → C → A is invalid)

### 3.4 Map to Categories

Map each task to one of 20 categories (see `.claude/skills/new-project/FEATURE-CATEGORIES.md`):
- A: Security & Auth
- B: Navigation
- C: Data (CRUD)
- D: Workflow
- E: Forms
- F: Display
- G: Search
- H: Notifications
- I: Settings
- J: Integration
- K: Analytics
- L: Admin
- M: Performance
- N: Accessibility
- O: Error Handling
- P: Payment
- Q: Communication
- R: Media
- S: Documentation
- T: UI Polish

### 3.5 Calculate Ready Tasks

After defining dependencies, mark tasks as "ready" if all dependencies are completed.

### 3.6 Output (varies by mode)

**Standard Mode (no --autonomous):**
- Create epic/task file structure in `docs/epics/`
- Create `docs/tasks/registry.json` for tracking
- Use with `/reflect resume T001` for implementation

**Autonomous Mode (--autonomous):**
- Same epic/task structure
- Also create `features.db` for MCP server compatibility
- Ready for `/implement-features` automation

### 3.7 Mark Phase 3 Complete

**ONLY mark complete after ALL epics and tasks are created:**

1. **Verify completion:**
   - `summary.epicsCreated === summary.epicsPlanned`
   - `summary.tasksCreated === summary.tasksPlanned`

2. **Update phase3-progress.json:**
   ```json
   {
     "status": "completed",
     "completedAt": "[TIMESTAMP]",
     "resumeInstructions": null
   }
   ```

3. **Append to progress-notes.md:**
   - Phase 3 completion with task summary
   - Number of epics and tasks created
   - Number of ready tasks (no dependencies)
   - Project status (initialization complete)

### 3.8 Update Latest Session

Update `.claude/memories/sessions/latest.md` with:
- Current date/time
- What was accomplished (Phases 0-3)
- Task summary (total epics, tasks, ready count)
- Key documents created
- Next steps

This ensures `/reflect resume` can pick up where initialization left off.

### 3.9 Checkpoint

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
✅ Phase 3 progress file marked complete

[If not autonomous]:
Project ready for development!

**Quick Start:**
- /reflect status         # See all tasks
- /reflect status --ready # See available tasks
- /reflect resume T001    # Start first task

Multiple agents can work on independent tasks in parallel.

[If autonomous]:
Continue to Implementation Readiness?
```

**If NOT `--autonomous`: STOP HERE.** Project is ready for manual development.

---

## Phase 4: Implementation Readiness (--autonomous only)

Read and follow: `.claude/skills/new-project/PHASES.md` (Phase 4 section)

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

Read and follow: `.claude/skills/new-project/PHASES.md` (Phase 5 section)

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

---

## Reference Documents

For detailed phase instructions, read:
- `.claude/skills/new-project/PHASES.md`
- `.claude/skills/new-project/FEATURE-CATEGORIES.md`
- `.claude/skills/new-project/TESTING-MODES.md`

For templates, use:
- `.claude/templates/prd.md`
- `.claude/templates/adr-template.md`
- `.claude/templates/feature-spec.md`
