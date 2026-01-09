# CLAUDE.md - Base Claude Framework Instructions

This file provides Claude Code with context about this framework and how to use it effectively.

---

## Framework Overview

**Base Claude** is a framework for AI-assisted software development. It provides:

- **Agent Personas** - Specialized agents for different roles (developer, architect, PM, etc.)
- **Skills** - Reusable workflows for common tasks
- **Templates** - Standardized document formats
- **Security Model** - Safe autonomous operation boundaries
- **Task Management** - Epic/task tracking with dependencies for parallel work
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
| `/pdf <command>` | PDF processing (extract, merge, split, fill, ocr, create) |

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
| `.claude/memories/progress-notes.md` | Session continuity notes |

---

## Project Initialization

### Key Principle

**All projects get full documentation.** The `/new-project` skill runs a continuous workflow that creates PRD, architecture decisions, and task planning. This documentation is what makes AI-assisted development effective.

### Standard Mode (Default)

Use `/new-project` to run the full workflow:

```
/new-project "My project description"
```

This runs through all phases:

| Phase | What Happens | Output |
|-------|--------------|--------|
| 0 | Framework setup | `.claude/` structure, CLAUDE.md, memories |
| 1 | Requirements discovery | `docs/prd.md` |
| 2 | Architecture & standards | ADRs, populated reference docs |
| 3 | Task planning | `docs/epics/`, `docs/tasks/registry.json` |

After Phase 3, your project is ready for development using `/reflect resume T001`.

### Existing Project Mode

Use `--current` to analyze an existing codebase first:

```
/new-project --current
```

This analyzes your project:
- Detects tech stack from package.json, requirements.txt, etc.
- Identifies project structure and existing commands
- Presents findings for confirmation
- Runs the same Phases 0-3 with discovered details

### Autonomous Mode

Add `--autonomous` for automated implementation tracking:

```
/new-project "E-commerce app" --autonomous
/new-project --current --autonomous
```

This adds Phases 4-5:
- Feature database (`features.db`) for MCP server
- MCP server setup for automation
- Ready for `/implement-features`

### Minimal Mode

Use `--minimal` if you only want framework setup without documentation:

```
/new-project --minimal
```

This only runs Phase 0 (framework setup) and stops.

---

## Task Management

### Epic/Task Structure

Projects are organized into epics (major feature areas) containing atomic tasks:

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

Multiple agents can work on independent tasks simultaneously:

```
Agent 1: /reflect resume T001  # Works on authentication setup
Agent 2: /reflect resume T010  # Works on dashboard (if no deps on T001)
```

The registry tracks locks to prevent conflicts.

### Lock Management

Tasks are locked when an agent starts work. If a session crashes:

```
/reflect status --locked       # See locked tasks
/reflect unlock T002           # Force unlock stale task
```

Locks expire after the configured timeout (default: 1 hour).

---

## Session Continuity

### Resume Commands

| Command | What It Does |
|---------|--------------|
| `/reflect resume` | Full context resume (git history, progress notes, registry) |
| `/reflect resume E01` | Resume specific epic, suggests next task |
| `/reflect resume T002` | Resume specific task, loads minimal context |

### Context Budget

Resume operations are optimized to use minimal context:

| Operation | Target | Max |
|-----------|--------|-----|
| General resume | 8k tokens | 15k |
| Epic resume | 5k tokens | 10k |
| Task resume | 3k tokens | 6k |

This leaves 185k+ tokens for actual work.

### State Persistence

State is preserved via:

1. **Task Registry** - `docs/tasks/registry.json`
   - Epic/task status
   - Dependencies
   - Locks

2. **Task Files** - `docs/epics/*/tasks/*.md`
   - Continuation context
   - Resume point
   - Decisions made

3. **Git Commits** - Source control
   - All code changes
   - Task IDs in commit messages

4. **Progress Notes** - `.claude/memories/progress-notes.md`
   - Session summaries
   - Blockers encountered

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

---

## Task Categories

Tasks are organized into 20 categories (A-T):

| Code | Category | Description |
|------|----------|-------------|
| A | Security & Auth | Login, registration, permissions |
| B | Navigation | Routes, menus, breadcrumbs |
| C | Data (CRUD) | Create, read, update, delete |
| D | Workflow | User actions, multi-step processes |
| E | Forms | Input validation, form handling |
| F | Display | Lists, grids, detail views |
| G | Search | Search, filtering, sorting |
| H | Notifications | Toasts, alerts, badges |
| I | Settings | Configuration, preferences |
| J | Integration | External APIs, webhooks |
| K | Analytics | Tracking, reporting |
| L | Admin | Admin panels, management |
| M | Performance | Caching, optimization |
| N | Accessibility | a11y compliance |
| O | Error Handling | Error pages, recovery |
| P | Payment | Checkout, billing |
| Q | Communication | Email, SMS, notifications |
| R | Media | Images, video, files |
| S | Documentation | Help, guides |
| T | UI Polish | Animations, micro-interactions |

---

## Security Model

### Allowlist Approach

All bash commands are validated against an allowlist before execution:

- **Allowed:** npm, yarn, node, git, vite, jest, eslint, etc.
- **Blocked:** Commands not in the allowlist
- **Special Validators:** Extra checks for pkill, chmod, rm, curl, git

### What You Cannot Do

- Delete files recursively (`rm -rf`)
- Kill non-dev processes (`pkill postgres`)
- Force push to main/master
- Change file permissions (except `+x`)
- Access local files via curl (`file://`)

### Security Documentation

See `security/` directory for:
- `README.md` - Security overview
- `allowed-commands.md` - Full command allowlist
- `command-validators.md` - Special validator rules
- `python/security.py` - Reference implementation

---

## Agent Personas

### Primary Agents

| Agent | Description | When to Use |
|-------|-------------|-------------|
| @developer | Implementation, coding | Feature development |
| @architect | System design, ADRs | Technical decisions |
| @project-manager | PRD, scope, priorities | Project planning |
| @scrum-master | Task breakdown, tracking | Sprint planning |
| @quality-engineer | Testing, browser automation | Verification |
| @security-boss | Security features, audits | Auth, payments |

### Invoking Agents

Use `@agent-name` to invoke a specific persona:

```
@developer implement the login form
@architect review this design decision
@security-boss audit the authentication flow
```

---

## Templates

### Task System Templates (used by /new-project Phase 3)

| Template | Purpose | Used By |
|----------|---------|---------|
| `epic-minimal.md` | Epic with task list, dependencies | Phase 3 task planning |
| `task.md` | Task with continuation context | Phase 3 task planning |
| `task-registry.json` | Master task/epic registry | Phase 3 initialization |
| `config.json` | Project configuration | Phase 3 initialization |

### Documentation Templates

| Template | Purpose | Used By |
|----------|---------|---------|
| `prd.md` | Product Requirements Document | Phase 1 @project-manager |
| `adr-template.md` | Architecture Decision Record | Phase 2 @architect |
| `feature-spec.md` | Detailed feature specification | Complex features |
| `user-story.md` | User story with acceptance criteria | PRD creation |
| `epic-full.md` | Full enterprise epic (business planning) | Large-scale projects |

### Session Templates

| Template | Purpose |
|----------|---------|
| `progress-notes.md` | Session handoff notes |
| `session-summary.md` | Session summary format |
| `CLAUDE.template.md` | Project CLAUDE.md template |

### Using Templates

Templates are in `templates/` directory. The `/new-project` skill automatically uses the correct templates during Phase 3.

For manual use:
```
Create an epic using templates/epic-minimal.md as the format
```

---

## PDF Processing

The `/pdf` skill handles PDF manipulation tasks.

### PDF Commands

| Command | Description |
|---------|-------------|
| `/pdf extract <file>` | Extract text or tables from PDF |
| `/pdf merge <files>` | Merge multiple PDFs into one |
| `/pdf split <file>` | Split PDF into individual pages |
| `/pdf fill <form>` | Fill a PDF form |
| `/pdf create` | Create a new PDF |
| `/pdf ocr <file>` | OCR a scanned PDF |

### PDF Documentation

See `skills/pdf/` for detailed guides:
- `SKILL.md` - Main workflow
- `FORMS.md` - Form filling
- `REFERENCE.md` - Advanced features
- `TOOLS.md` - Tool selection guide
- `OCR.md` - Scanned PDF handling

---

## Autonomous Mode (--autonomous)

### Implementing Features

Use `/implement-features` to implement the feature database:

```
/implement-features              # Standard mode (full testing)
/implement-features --mode=yolo  # Fast mode (lint only)
/implement-features --mode=hybrid # Critical features tested only
/implement-features --resume     # Resume from last session
```

### Testing Modes

| Mode | Testing | Speed | Use Case |
|------|---------|-------|----------|
| Standard | Full browser automation | ~5-10 min/feature | Production |
| YOLO | Lint + type-check only | ~1-2 min/feature | Prototyping |
| Hybrid | Critical features only | ~3-5 min/feature | Internal tools |

### Checkpoint Protocol

During implementation, checkpoints occur every 10 features:

```markdown
## Checkpoint: 50/92 Features

Options:
1. Continue - Resume implementation
2. Pause - Save and exit
3. Adjust - Change priorities
4. Review - Inspect features
```

Always respect checkpoints - they're for human oversight.

---

## Error Handling

### Task Implementation Failure

If a task fails after 3 attempts:
1. Set status to `continuation`
2. Document blocker in task file
3. Move to next ready task

### Regression Failure

If regression tests fail:
1. STOP implementation immediately
2. Identify the regression
3. Fix before continuing
4. Never proceed with failing regressions

### Session Crash

On unexpected termination:
1. Check for uncommitted changes (`git status`)
2. Check for stale locks (`/reflect status --locked`)
3. Unlock if needed (`/reflect unlock T002`)
4. Resume (`/reflect resume`)

---

## Best Practices

### Do

- Complete tasks atomically (one at a time)
- Commit after each task
- Run regression tests
- Update continuation context if stopping mid-task
- Respect checkpoint pauses

### Don't

- Skip regression testing
- Leave tasks `in_progress` at session end without continuation context
- Force through blockers
- Ignore test failures
- Work on tasks with unmet dependencies

---

## Documentation Reference

For detailed documentation, see:

| Document | Location |
|----------|----------|
| System Overview | `reference/01-system-overview.template.md` |
| Architecture | `reference/02-architecture-and-tech-stack.template.md` |
| Security (App) | `reference/03-security-auth-and-access.template.md` |
| Development Standards | `reference/04-development-standards-and-structure.template.md` |
| Security Model | `reference/08-security-model.template.md` |
| Autonomous Dev | `reference/09-autonomous-development.template.md` |

---

## Getting Help

- `/help` - Show available commands
- `/reflect status` - See current task status

---

*This framework enables structured, safe, autonomous development with human oversight at key checkpoints.*
