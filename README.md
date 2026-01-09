# Claude Forge

A comprehensive framework for AI-assisted software development with Claude Code. Provides structured workflows, specialized agents, task management with dependencies, and reusable skills for autonomous development with human oversight.

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
  - [New Project](#new-project)
  - [Existing Project](#existing-project)
  - [Autonomous Development](#autonomous-development)
- [Task Management](#task-management)
  - [Epic/Task Structure](#epictask-structure)
  - [Task States](#task-states)
  - [Dependencies](#dependencies)
  - [Parallel Work](#parallel-work)
- [Commands Reference](#commands-reference)
  - [Project Commands](#project-commands)
  - [Reflect Commands](#reflect-commands)
  - [PDF Commands](#pdf-commands)
- [Setup Guide](#setup-guide)
- [Directory Structure](#directory-structure)
- [Framework Components](#framework-components)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## Overview

**Claude Forge** enables structured, safe, autonomous development by providing:

- **Task Management** - Epic/task tracking with dependencies for parallel work
- **Agent Personas** - Specialized agents for different roles (developer, architect, PM, etc.)
- **Skills** - Reusable workflows for common tasks (features, bugs, refactoring, PRs)
- **Templates** - Standardized document formats (PRD, ADR, epics, tasks)
- **Security Model** - Safe autonomous operation with command allowlists
- **Session Continuity** - Context preservation and minimal-context resume
- **Autonomous Development** - Full project implementation from idea to code

---

## Quick Start

### Option A: New Project (Recommended)

```bash
# 1. Create your project directory
mkdir my-new-project
cd my-new-project

# 2. Clone Claude Forge into .claude directory
git clone https://github.com/rynhardt81/claude-forge.git .claude

# 3. Remove the .git from .claude (it's now part of your project)
rm -rf .claude/.git

# 4. Initialize the project with Claude Code
/new-project
```

The `/new-project` command runs a **continuous workflow**:

| Phase | What Happens | Output |
|-------|--------------|--------|
| 0 | Framework setup | `.claude/` structure, CLAUDE.md, memories |
| 1 | Requirements discovery | `docs/prd.md` |
| 2 | Architecture & standards | ADRs, populated reference docs |
| 3 | Task planning | `docs/epics/`, `docs/tasks/registry.json` |

Or provide details inline:
```bash
/new-project "My awesome e-commerce app using Next.js"
```

After initialization, start working:
```bash
/reflect status --ready   # See available tasks
/reflect resume T001      # Start first task
```

### Option B: Existing Project

Add Claude Forge to an existing codebase:

```bash
# 1. Navigate to your project root
cd /path/to/existing-project

# 2. Clone Claude Forge into .claude directory
git clone https://github.com/rynhardt81/claude-forge.git .claude

# 3. Remove the .git from .claude
rm -rf .claude/.git

# 4. Initialize with --current flag
/new-project --current
```

The `--current` flag analyzes your existing codebase:
- **Discovers** your tech stack from package.json, requirements.txt, etc.
- **Identifies** project structure, existing commands, and patterns
- **Presents findings** for your confirmation before proceeding
- **Creates** PRD, architecture docs, and task breakdown based on existing code

### Option C: Autonomous Development

For full autonomous implementation from idea to code:

```bash
/new-project "E-commerce platform for handmade crafts" --autonomous
```

This runs Phases 0-5:
- Phases 0-3: Same as standard (PRD, ADRs, tasks)
- Phase 4: MCP server setup, security model
- Phase 5: Kickoff with `/implement-features`

Combine with existing project:
```bash
/new-project --current --autonomous
```

### Option D: Minimal Setup

Framework setup only (skip documentation):

```bash
/new-project --minimal
```

---

## Task Management

### Epic/Task Structure

Projects are organized into **epics** (major feature areas) containing **atomic tasks**:

```
docs/
├── tasks/
│   ├── registry.json          # Master task/epic registry
│   └── config.json            # Project configuration
└── epics/
    ├── E01-authentication/
    │   ├── E01-authentication.md   # Epic file
    │   └── tasks/
    │       ├── T001-setup-auth.md  # Task files
    │       ├── T002-login-form.md
    │       └── T003-session-mgmt.md
    └── E02-dashboard/
        └── ...
```

### Task States

| Status | Description | When |
|--------|-------------|------|
| `pending` | Dependencies not met | Task waiting for other tasks |
| `ready` | Can be started | All dependencies complete |
| `in_progress` | Being worked on | Agent has acquired lock |
| `continuation` | Partially complete | Session ended mid-task |
| `completed` | Done | Task finished and verified |

### State Flow

```
pending → ready → in_progress → completed
                       ↓
                  continuation
                       ↓
                  in_progress → completed
```

### Dependencies

**Task-Level:** T002 depends on T001
```json
{
  "id": "T002",
  "dependencies": ["T001"]
}
```

**Epic-Level:** E02 depends on E01
```json
{
  "id": "E02",
  "dependencies": ["E01"]
}
```

**Cross-Epic:** T010 (E02) depends on T003 (E01)
```json
{
  "id": "T010",
  "epic": "E02",
  "dependencies": ["T003"]
}
```

### Parallel Work

Multiple agents can work on independent tasks simultaneously:

```
Terminal 1: /reflect resume T001  # Authentication setup
Terminal 2: /reflect resume T010  # Dashboard layout (no deps on T001)
Terminal 3: /reflect resume T020  # API integration (no deps on T001, T010)
```

The registry tracks locks to prevent conflicts. Default max: 3 parallel agents.

### Lock Management

Tasks are locked when an agent starts work:

```bash
/reflect status --locked   # See all locked tasks
/reflect unlock T002       # Force unlock stale task
```

**Lock timeout:** 1 hour (configurable)

---

## Commands Reference

### Project Commands

| Command | Description |
|---------|-------------|
| `/new-project` | Full workflow: PRD + ADRs + tasks |
| `/new-project "description"` | With inline description |
| `/new-project --current` | Analyze existing codebase first |
| `/new-project --autonomous` | Add feature database for automation |
| `/new-project --minimal` | Framework setup only |
| `/implement-features` | Implement features (autonomous mode) |
| `/implement-features --mode=yolo` | Fast mode (lint only) |
| `/implement-features --resume` | Resume from last session |

### Reflect Commands

| Command | Description |
|---------|-------------|
| `/reflect` | Capture session learnings |
| `/reflect resume` | Resume with full context |
| `/reflect resume E01` | Resume specific epic |
| `/reflect resume T002` | Resume specific task |
| `/reflect status` | Show task/epic overview |
| `/reflect status --ready` | Show available tasks |
| `/reflect status --locked` | Show locked tasks |
| `/reflect unlock T002` | Force unlock stale task |
| `/reflect config` | Show configuration |
| `/reflect config lockTimeout 1800` | Update setting |
| `/reflect on` | Enable auto-reflection |
| `/reflect off` | Disable auto-reflection |

### PDF Commands

| Command | Description |
|---------|-------------|
| `/pdf extract <file>` | Extract text or tables |
| `/pdf merge <files>` | Merge multiple PDFs |
| `/pdf split <file>` | Split into pages |
| `/pdf fill <form>` | Fill PDF form |
| `/pdf create` | Create new PDF |
| `/pdf ocr <file>` | OCR scanned PDF |
| `/pdf info <file>` | Show PDF metadata |

---

## Setup Guide

### Step 1: Copy Framework

After cloning, your project structure:

```
your-project/
├── .claude/                    # Claude Forge framework
│   ├── CLAUDE.md               # Your project's Claude instructions
│   ├── agents/                 # Agent personas
│   ├── skills/                 # Workflow skills
│   ├── templates/              # Document templates
│   ├── reference/              # Architecture doc templates
│   ├── security/               # Security model
│   ├── mcp-servers/            # MCP server implementations
│   ├── memories/               # Session continuity
│   └── ...
├── docs/                       # Project documentation
│   ├── prd.md                  # Product requirements
│   ├── tasks/                  # Task registry
│   └── epics/                  # Epic and task files
├── src/                        # Your source code
└── ...
```

### Step 2: Initialize with /new-project

The recommended approach is to use `/new-project`:

```bash
/new-project "My project description"
```

This automatically:
1. Creates `.claude/CLAUDE.md` with your project details
2. Initializes memory structure
3. Copies reference templates
4. Creates PRD through requirements discovery
5. Creates ADRs through architecture planning
6. Creates epic/task structure for development

### Step 3: Manual Setup (Alternative)

If you prefer manual setup:

**Create CLAUDE.md:**
```bash
cp .claude/templates/CLAUDE.template.md .claude/CLAUDE.md
# Then edit .claude/CLAUDE.md with your project details
```

**Initialize memories:**
```bash
mkdir -p .claude/memories/sessions
echo "No previous session recorded." > .claude/memories/sessions/latest.md
echo "# General Memories" > .claude/memories/general.md
echo "# Progress Notes" > .claude/memories/progress-notes.md
```

**Copy reference templates:**
```bash
cd .claude/reference/
for f in *.template.md; do
  cp "$f" "${f%.template.md}.md"
done
```

---

## Directory Structure

```
.claude/
├── CLAUDE.md                    # Project instructions
│
├── agents/                      # Full agent personas
│   ├── orchestrator.md          # Workflow coordination
│   ├── analyst.md               # Requirements discovery
│   ├── architect.md             # System design, ADRs
│   ├── developer.md             # Code implementation
│   ├── quality-engineer.md      # Testing, code review
│   ├── security-boss.md         # Security audits
│   ├── devops.md                # CI/CD, deployment
│   ├── project-manager.md       # PRDs, scope management
│   ├── scrum-master.md          # Sprint planning, features
│   └── ux-designer.md           # User flows, wireframes
│
├── skills/                      # Workflow skills
│   ├── reflect/                 # Session continuity & task mgmt
│   │   ├── SKILL.md             # Main skill definition
│   │   ├── SIGNALS.md           # Learning signals
│   │   └── ...
│   ├── new-project/             # Project initialization
│   │   ├── SKILL.md             # Phase workflow
│   │   ├── PHASES.md            # Detailed phase instructions
│   │   └── FEATURE-CATEGORIES.md # 20 categories
│   ├── implement-features/      # Autonomous implementation
│   ├── pdf/                     # PDF processing
│   └── ...
│
├── templates/                   # Document templates
│   ├── CLAUDE.template.md       # CLAUDE.md template
│   ├── prd.md                   # Product Requirements
│   ├── epic-minimal.md          # Epic template
│   ├── task.md                  # Task template
│   ├── task-registry.json       # Registry template
│   ├── config.json              # Config template
│   ├── adr-template.md          # Architecture Decision
│   └── ...
│
├── reference/                   # Architecture doc templates
│   ├── 00-documentation-governance.md
│   ├── 01-system-overview.template.md
│   └── ...
│
├── security/                    # Security model
│   ├── README.md                # Security overview
│   ├── allowed-commands.md      # Command allowlist
│   └── command-validators.md    # Special validators
│
├── mcp-servers/                 # MCP server implementations
│   ├── feature-tracking/        # Feature database MCP
│   └── browser-automation/      # Playwright MCP
│
├── memories/                    # Session continuity
│   ├── general.md               # General preferences
│   ├── progress-notes.md        # Session summaries
│   └── sessions/
│       └── latest.md            # Most recent session
│
└── commands/                    # Command definitions
    ├── new-project.md           # /new-project definition
    └── reflect.md               # /reflect definition

docs/                            # Project documentation (created by /new-project)
├── prd.md                       # Product Requirements Document
├── tasks/
│   ├── registry.json            # Master task/epic registry
│   └── config.json              # Project configuration
└── epics/
    ├── E01-epic-name/
    │   ├── E01-epic-name.md     # Epic file
    │   └── tasks/
    │       ├── T001-task.md     # Task files
    │       └── ...
    └── ...
```

---

## Framework Components

### Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Reflect | `/reflect` | Capture session state and learnings |
| Resume | `/reflect resume` | Load previous session context |
| Status | `/reflect status` | View task/epic status |
| New Project | `/new-project` | Initialize project |
| Implement | `/implement-features` | Autonomous feature loop |
| PDF | `/pdf <command>` | PDF processing tasks |

### Agents

| Agent | Role | When to Use |
|-------|------|-------------|
| @orchestrator | Workflow coordination | Complex multi-step tasks |
| @analyst | Requirements discovery | New features, understanding needs |
| @architect | System design | Architecture decisions, ADRs |
| @developer | Implementation | Writing code |
| @quality-engineer | Testing | Code review, test coverage |
| @security-boss | Security | Auth, permissions, audits |
| @project-manager | Planning | PRDs, scope, priorities |
| @scrum-master | Sprint management | Task breakdown, tracking |

### Templates

| Template | Purpose |
|----------|---------|
| `prd.md` | Product Requirements Document |
| `epic-minimal.md` | Epic with task list and dependencies |
| `task.md` | Task with continuation context |
| `task-registry.json` | Master task/epic registry |
| `config.json` | Project configuration |
| `adr-template.md` | Architecture Decision Record |

---

## Configuration

### View Configuration

```bash
/reflect config
```

### Update Settings

```bash
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
| `maxContextTokens` | 200000 | Total context budget |
| `targetResumeTokens` | 8000 | Target for resume context |

---

## Customization

### What to Customize

| Item | Action | Location |
|------|--------|----------|
| CLAUDE.md | **Required** - Add project details | `.claude/CLAUDE.md` |
| Reference docs | **Recommended** - Fill architecture | `.claude/reference/` |
| Config | **Optional** - Adjust settings | `docs/tasks/config.json` |

### What NOT to Modify

| Item | Reason |
|------|--------|
| `templates/` | Framework templates |
| `skills/` (core files) | Framework workflows |
| `00-documentation-governance.md` | Universal rules |

---

## Troubleshooting

### Tasks not showing as ready

**Check:** Are dependencies complete?
```bash
/reflect status
```

**Fix:** Complete dependent tasks first, or check for circular dependencies.

### Lock stuck on task

**Check:** Is the lock stale?
```bash
/reflect status --locked
```

**Fix:** Force unlock:
```bash
/reflect unlock T002
```

### Session not resuming

**Check:** Do memory files exist?
```bash
ls -la .claude/memories/sessions/
```

**Fix:** Create the files:
```bash
mkdir -p .claude/memories/sessions
echo "No previous session." > .claude/memories/sessions/latest.md
```

### Claude doesn't see the framework

**Check:** Is `.claude/` in your project root?
```bash
ls -la .claude/CLAUDE.md
```

### Task registry not found

**Check:** Did you run `/new-project`?
```bash
ls docs/tasks/registry.json
```

**Fix:** Run `/new-project` or create manually from template.

---

## Version

**Framework Version:** 1.2.0
**Last Updated:** 2026-01-09

---

## License

MIT License - See LICENSE file for details.

---

## Contributing

Contributions welcome! Please read the contributing guidelines before submitting PRs.

---

*Claude Forge enables structured, safe, and optional autonomous development with human oversight at key checkpoints.*
