# Claude Forge

A comprehensive framework for AI-assisted software development with Claude Code. Provides structured workflows, specialized agents, and reusable skills for autonomous development with human oversight.

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
  - [New Project](#new-project)
  - [Existing Project](#existing-project)
- [Setup Guide](#setup-guide)
  - [Step 1: Copy Framework](#step-1-copy-framework)
  - [Step 2: Create CLAUDE.md](#step-2-create-claudemd)
  - [Step 3: Configure Reference Docs](#step-3-configure-reference-docs)
  - [Step 4: Initialize Memories](#step-4-initialize-memories)
- [Directory Structure](#directory-structure)
- [Framework Components](#framework-components)
  - [Skills](#skills)
  - [Agents](#agents)
  - [Templates](#templates)
  - [Reference Documentation](#reference-documentation)
- [Usage](#usage)
  - [Starting a Session](#starting-a-session)
  - [Common Commands](#common-commands)
  - [Autonomous Development](#autonomous-development)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## Overview

**Claude Forge** enables structured, safe, autonomous development by providing:

- **Agent Personas** - Specialized agents for different roles (developer, architect, PM, etc.)
- **Skills** - Reusable workflows for common tasks (features, bugs, refactoring, PRs)
- **Templates** - Standardized document formats (PRD, ADR, user stories)
- **Security Model** - Safe autonomous operation with command allowlists
- **Session Continuity** - Context preservation across multiple sessions
- **Autonomous Development** - Full project implementation from idea to code

---

## Quick Start

### Option A: Standard Development (Recommended for most users)

Use this for human-directed development with AI assistance:

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

The `/new-project` command will interactively ask you for:
- **Project name** - What to call your project
- **Description** - What the project does
- **Tech stack** - Choose from common stacks or specify custom

Or provide details inline:
```bash
/new-project "My awesome e-commerce app using Next.js"
```

This sets up:
- `CLAUDE.md` - Customized project instructions
- `.claude/memories/` - Session continuity
- `.claude/reference/` - Architecture documentation

### Option B: Autonomous Development

Use this for full autonomous implementation from idea to code:

```bash
# 1. Create your project directory
mkdir my-new-project
cd my-new-project

# 2. Clone Claude Forge into .claude directory
git clone https://github.com/rynhardt81/claude-forge.git .claude

# 3. Remove the .git from .claude
rm -rf .claude/.git

# 4. Initialize with autonomous mode
/new-project --autonomous
```

You'll be prompted for project details, then the 5-phase workflow begins:
1. **Requirements Discovery** - PRD creation with @analyst and @project-manager
2. **Feature Breakdown** - 50-400+ features with @scrum-master
3. **Technical Planning** - ADRs with @architect
4. **Implementation Readiness** - MCP setup and security
5. **Kickoff** → `/implement-features`

Or provide the idea inline:
```bash
/new-project "E-commerce platform for handmade crafts" --autonomous
```

### Option C: Existing Project

Add Claude Forge to an existing codebase:

```bash
# 1. Navigate to your project root
cd /path/to/existing-project

# 2. Clone Claude Forge into .claude directory
git clone https://github.com/rynhardt81/claude-forge.git .claude

# 3. Remove the .git from .claude
rm -rf .claude/.git

# 4. Initialize the framework with --current flag
/new-project --current
```

The `--current` flag tells Claude to analyze your existing codebase:
- **Discovers** your tech stack from package.json, requirements.txt, etc.
- **Identifies** project structure, existing commands, and patterns
- **Presents findings** for your confirmation before proceeding
- **Customizes** CLAUDE.md with your project's actual details

You can also combine with autonomous mode:
```bash
/new-project --current --autonomous
```

This analyzes your existing project, then creates a full PRD and feature database for continued development.

---

## Setup Guide

### Step 1: Copy Framework

After cloning, your project structure should look like:

```
your-project/
├── .claude/                    # Claude Forge framework
│   ├── agents/                 # Agent personas
│   ├── skills/                 # Workflow skills
│   ├── templates/              # Document templates
│   ├── reference/              # Architecture doc templates
│   ├── sub-agents/             # Specialist agents
│   ├── security/               # Security model
│   ├── mcp-servers/            # MCP server implementations
│   ├── memories/               # Session continuity
│   └── ...
├── CLAUDE.md                   # Your project's Claude instructions
├── src/                        # Your source code
└── ...
```

### Step 2: Create CLAUDE.md

The `CLAUDE.md` file in your project root tells Claude how to work with your codebase.

**Option A: Use the template**
```bash
cp .claude/templates/CLAUDE.template.md ./CLAUDE.md
```

**Option B: Create minimal CLAUDE.md**

Create `CLAUDE.md` in your project root with at minimum:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

**[Your Project Name]** is a [brief description].

**Tech Stack:**
- Backend: [e.g., Node.js, Python, Go]
- Frontend: [e.g., React, Vue, Next.js]
- Database: [e.g., PostgreSQL, MongoDB]

## Essential Commands

```bash
# Development
npm run dev          # Start development server
npm test             # Run tests
npm run build        # Build for production
```

## Framework Reference

This project uses Claude Forge. Key resources:

| Resource | Location |
|----------|----------|
| Skills | `.claude/skills/` |
| Agents | `.claude/agents/` |
| Templates | `.claude/templates/` |
| Reference Docs | `.claude/reference/` |

## Key Commands

| Command | Description |
|---------|-------------|
| `/reflect` | Capture session state |
| `/reflect resume` | Resume from last session |
| `/new-feature` | Start feature development |
| `/fix-bug` | Bug fixing workflow |
| `/create-pr` | Create pull request |
| `/pdf <command>` | PDF processing |
```

**Required sections in CLAUDE.md:**

| Section | Purpose |
|---------|---------|
| Project Overview | What the project does, tech stack |
| Essential Commands | How to run, test, build |
| Framework Reference | Point to .claude/ resources |
| Key Commands | Available skills/commands |

### Step 3: Configure Reference Docs

The `reference/` directory contains architecture documentation templates. For a new project:

```bash
cd .claude/reference/

# Rename templates (remove .template suffix)
for f in *.template.md; do
  cp "$f" "${f%.template.md}.md"
done
```

Then customize each document:

| Document | What to Add |
|----------|-------------|
| `01-system-overview.md` | Project purpose, boundaries, stakeholders |
| `02-architecture-and-tech-stack.md` | Tech choices, system design |
| `03-security-auth-and-access.md` | Auth flows, permissions, security |
| `04-development-standards-and-structure.md` | Code style, project structure |
| `05-operational-and-lifecycle.md` | Deployment, monitoring, CI/CD |
| `06-architecture-decisions.md` | ADRs for key decisions |
| `07-non-functional-requirements.md` | Performance, scalability requirements |

**Tip:** You don't need to fill everything immediately. Start with `01` and `02`, add others as needed.

### Step 4: Initialize Memories

Create initial memory files for session continuity:

```bash
# Ensure memories directory exists
mkdir -p .claude/memories/sessions

# Create general memories file
cat > .claude/memories/general.md << 'EOF'
# General Memories

Project-wide learnings and preferences.

## Preferences

- [Add your preferences as you work]

## Learnings

- [Captured automatically via /reflect]
EOF

# Create latest session file
cat > .claude/memories/sessions/latest.md << 'EOF'
# Latest Session

No previous session recorded.

Use `/reflect` to capture session state.
EOF
```

---

## Directory Structure

```
.claude/
│
├── agents/                      # Full agent personas (15)
│   ├── orchestrator.md          # Workflow coordination
│   ├── analyst.md               # Requirements discovery
│   ├── architect.md             # System design, ADRs
│   ├── developer.md             # Code implementation
│   ├── quality-engineer.md      # Testing, code review
│   ├── security-boss.md         # Security audits
│   ├── devops.md                # CI/CD, deployment
│   ├── project-manager.md       # PRDs, scope management
│   ├── scrum-master.md          # Sprint planning, features
│   ├── ux-designer.md           # User flows, wireframes
│   └── ...
│
├── sub-agents/                  # Focused specialists (7)
│   ├── codebase-analyzer.md     # Project structure analysis
│   ├── pattern-detector.md      # Code conventions
│   ├── requirements-analyst.md  # Requirements extraction
│   ├── tech-debt-auditor.md     # Debt assessment
│   ├── api-documenter.md        # API documentation
│   ├── test-coverage-analyzer.md # Test gap analysis
│   └── document-reviewer.md     # Doc quality review
│
├── skills/                      # Workflow skills (9)
│   ├── reflect/                 # Session continuity
│   ├── new-feature/             # Feature development
│   ├── fix-bug/                 # Bug fixing
│   ├── refactor/                # Code refactoring
│   ├── create-pr/               # Pull request creation
│   ├── release/                 # Version releases
│   ├── new-project/             # Project initialization
│   ├── implement-features/      # Feature implementation loop
│   └── pdf/                     # PDF processing
│
├── templates/                   # Document templates
│   ├── CLAUDE.template.md       # CLAUDE.md template for projects
│   ├── prd.md                   # Product Requirements Document
│   ├── epic.md                  # Epic breakdown
│   ├── user-story.md            # User story format
│   ├── adr-template.md          # Architecture Decision Record
│   ├── feature-spec.md          # Feature specification
│   ├── progress-notes.md        # Session handoff notes
│   └── ...
│
├── reference/                   # Architecture doc templates
│   ├── 00-documentation-governance.md
│   ├── 01-system-overview.template.md
│   ├── 02-architecture-and-tech-stack.template.md
│   └── ...
│
├── security/                    # Security model
│   ├── README.md                # Security overview
│   ├── allowed-commands.md      # Command allowlist
│   ├── command-validators.md    # Special validators
│   └── python/security.py       # Reference implementation
│
├── mcp-servers/                 # MCP server implementations
│   ├── feature-tracking/        # Feature database MCP
│   └── browser-automation/      # Playwright MCP
│
├── memories/                    # Session continuity
│   ├── general.md               # General preferences
│   └── sessions/
│       └── latest.md            # Most recent session
│
├── standards/                   # Coding standards
│   └── documentation-style.md
│
├── features/                    # Feature specifications
├── commands/                    # Custom commands
├── hooks/                       # Hook definitions
└── docs/                        # Additional documentation
```

---

## Framework Components

### Skills

Skills are structured workflows invoked with `/skill-name`.

| Skill | Command | Description |
|-------|---------|-------------|
| Reflect | `/reflect` | Capture session state and learnings |
| Resume | `/reflect resume` | Load previous session context |
| New Feature | `/new-feature` | Full feature development workflow |
| Fix Bug | `/fix-bug` | Bug diagnosis and fixing |
| Refactor | `/refactor` | Code refactoring workflow |
| Create PR | `/create-pr` | Pull request with checklist |
| Release | `/release` | Version release workflow |
| New Project | `/new-project` | Initialize project (prompts for details) |
| New Project | `/new-project --current` | Analyze existing project, confirm findings |
| New Project | `/new-project --autonomous` | Initialize with full autonomous workflow |
| Implement | `/implement-features` | Incremental feature loop |
| PDF | `/pdf <command>` | PDF processing tasks |

**PDF Commands:**
- `/pdf extract <file>` - Extract text or tables
- `/pdf merge <files>` - Merge multiple PDFs
- `/pdf split <file>` - Split into pages
- `/pdf fill <form>` - Fill PDF form
- `/pdf create` - Create new PDF
- `/pdf ocr <file>` - OCR scanned PDF

### Agents

Agents are specialized personas for different tasks. Invoke with `@agent-name`.

| Agent | Role | When to Use |
|-------|------|-------------|
| @orchestrator | Workflow coordination | Complex multi-step tasks |
| @analyst | Requirements discovery | New features, understanding needs |
| @architect | System design | Architecture decisions, ADRs |
| @developer | Implementation | Writing code |
| @quality-engineer | Testing | Code review, test coverage |
| @security-boss | Security | Auth, permissions, audits |
| @devops | Operations | CI/CD, deployment |
| @project-manager | Planning | PRDs, scope, priorities |
| @scrum-master | Sprint management | Feature breakdown, tracking |

**Recommended Flow:**
```
@analyst → @architect → @developer → @quality-engineer → @devops
```

### Templates

Templates provide standardized formats for common documents.

| Template | Purpose | Location |
|----------|---------|----------|
| CLAUDE.template.md | Project CLAUDE.md | `templates/` |
| prd.md | Product Requirements | `templates/` |
| epic.md | Epic breakdown | `templates/` |
| user-story.md | User stories | `templates/` |
| adr-template.md | Architecture decisions | `templates/` |
| feature-spec.md | Feature specs | `templates/` |
| progress-notes.md | Session handoff | `templates/` |

**Usage:**
```
Create a PRD using templates/prd.md as the format
```

### Reference Documentation

Reference docs define project architecture. Templates are in `reference/`.

| Document | Defines |
|----------|---------|
| 00-documentation-governance.md | Document hierarchy rules |
| 01-system-overview.md | What/why, boundaries |
| 02-architecture-and-tech-stack.md | How it's built |
| 03-security-auth-and-access.md | Security model |
| 04-development-standards-and-structure.md | Code standards |
| 05-operational-and-lifecycle.md | Deployment, ops |
| 06-architecture-decisions.md | ADR log |
| 07-non-functional-requirements.md | Performance, scale |
| 08-security-model.md | Autonomous operation security |
| 09-autonomous-development.md | Long-running agent patterns |

---

## Usage

### Starting a Session

**First time:**
```
Read .claude/CLAUDE.md and the project CLAUDE.md to understand the framework.
```

**Resuming work:**
```
/reflect resume
```

**Ending a session:**
```
/reflect
```

### Common Commands

| Task | Command |
|------|---------|
| Start new feature | `/new-feature add user authentication` |
| Fix a bug | `/fix-bug login fails on mobile` |
| Refactor code | `/refactor extract payment logic` |
| Create PR | `/create-pr` |
| Review progress | `/reflect` |

### Autonomous Development

For full autonomous project development:

**1. Initialize Project:**
```
/new-project --autonomous
```

Or with description:
```
/new-project "E-commerce platform for handmade crafts" --autonomous
```

This creates:
- PRD document (via @analyst and @project-manager)
- 50-400+ features in database (via @scrum-master)
- Architecture Decision Records (via @architect)
- MCP server setup

**2. Implement Features:**
```
/implement-features              # Standard mode (full testing)
/implement-features --mode=yolo  # Fast mode (lint only)
/implement-features --resume     # Resume from last session
```

**3. Checkpoint Protocol:**

Every 10 features, you'll see:
```
## Checkpoint: 30/92 Features

Options:
1. Continue - Resume implementation
2. Pause - Save and exit
3. Adjust - Change priorities
4. Review - Inspect features
```

---

## Customization

### What to Customize

| Item | Action | Location |
|------|--------|----------|
| CLAUDE.md | **Required** - Add project details | Project root |
| Reference docs | **Recommended** - Fill architecture | `.claude/reference/` |
| Memories | **Optional** - Pre-seed preferences | `.claude/memories/` |

### What NOT to Modify

| Item | Reason |
|------|--------|
| `00-documentation-governance.md` | Universal framework rules |
| `sub-agents/` | Generic specialists |
| `skills/` (core files) | Framework workflows |

### Adding Custom Content

**Custom agents:**
```bash
# Create project-specific agent
cat > .claude/agents/my-custom-agent.md << 'EOF'
# My Custom Agent

## Role
[Description]

## Capabilities
- [List capabilities]

## When to Use
[Guidance]
EOF
```

**Custom skills:**
```bash
mkdir -p .claude/skills/my-skill
# Add SKILL.md and supporting files
```

---

## Troubleshooting

### Claude doesn't see the framework

**Check:** Is `.claude/` in your project root?
```bash
ls -la .claude/
```

**Check:** Is `CLAUDE.md` in your project root?
```bash
ls -la CLAUDE.md
```

### Skills not working

**Check:** Reference the skill location in your CLAUDE.md:
```markdown
## Framework Reference

| Resource | Location |
|----------|----------|
| Skills | `.claude/skills/` |
```

### Session not resuming

**Check:** Memories directory exists:
```bash
ls -la .claude/memories/sessions/
```

**Fix:** Create the files:
```bash
mkdir -p .claude/memories/sessions
touch .claude/memories/sessions/latest.md
touch .claude/memories/general.md
```

### Reference docs not found

**Check:** Did you copy templates?
```bash
ls .claude/reference/*.md
```

**Fix:** Copy and rename:
```bash
cd .claude/reference/
for f in *.template.md; do
  cp "$f" "${f%.template.md}.md"
done
```

---

## Version

**Framework Version:** 1.1.0
**Last Updated:** 2025-01-09

---

## License

MIT License - See LICENSE file for details.

---

## Contributing

Contributions welcome! Please read the contributing guidelines before submitting PRs.

---

*Claude Forge enables structured, safe, autonomous development with human oversight at key checkpoints.*
