# Claude Forge

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/v/release/rynhardt81/claude-forge)](https://github.com/rynhardt81/claude-forge/releases)
[![GitHub stars](https://img.shields.io/github/stars/rynhardt81/claude-forge)](https://github.com/rynhardt81/claude-forge/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/rynhardt81/claude-forge)](https://github.com/rynhardt81/claude-forge/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/rynhardt81/claude-forge)](https://github.com/rynhardt81/claude-forge/commits/main)
[![Made for Claude Code](https://img.shields.io/badge/Made%20for-Claude%20Code-blueviolet)](https://claude.ai)

A comprehensive framework for AI-assisted software development with Claude Code. Provides structured workflows, specialized agents, task management with dependencies, and reusable skills for autonomous development with human oversight.

---

## Table of Contents

- [Build Autonomous AI Applications](#-build-autonomous-ai-applications-with-structured-workflows)
- - [Why Claude Forge?](#-why-claude-forge)
  -   - [The Problem](#the-problem)
      -   - [The Claude Forge Solution](#the-claude-forge-solution)
          -   - [Real-World Impact](#real-world-impact)
              -   - [Key Features Summary](#-key-features-summary)

- [Overview](#overview)## 🎯 Build Autonomous AI Applications with Structured Workflows

- Claude Forge is a **comprehensive framework for AI-assisted software development** with Claude Code. It enables structured, safe, autonomous development through task management, intelligent dispatch, and reusable skills.

- ### **30-Second Overview**
- - ✅ **Autonomous development** from requirements to deployment
  - - 🎯 **Task management** with dependencies for parallel work
    - - 🔄 **Intelligent dispatch** for automatic sub-agent parallelization
      - - 💾 **Project memory** for persistent institutional knowledge
        - - 🛡️ **Hook enforcement** for mandatory security gates
          - - 👥 **15 specialized agents** for different roles (developer, architect, PM, etc.)
           
            - ---

            ## 🌟 Why Claude Forge?

            Claude Forge solves a critical problem: **keeping AI development structured, safe, and scalable**. Whether you're building new projects or enhancing existing codebases, Claude Forge provides the guardrails and patterns for reliable autonomous development.

            ### **The Problem**
            Without structure, AI development becomes chaotic:
            - ❌ Lost context between sessions
            - - ❌ Duplicate work or conflicting changes
              - - ❌ No visibility into progress or decisions
                - - ❌ Difficulty coordinating parallel work
                  - - ❌ Security and validation gaps
                   
                    ### **The Claude Forge Solution**
                 
                    #### **1. Intelligent Dispatch System** 🔄
                    - Automatically parallelize work without conflicts
                    - - Analyzes task dependencies to find independent work clusters
                      - - Spawns multiple sub-agents to work in parallel
                        - - Detects and prevents scope conflicts (no race conditions)
                          - - Saves 50%+ development time for independent features
                           
                            - **Use Case:** Working on authentication AND dashboard AND payment features simultaneously—all managed automatically.
                           
                            - #### **2. Project Memory** 💾
                            - - Never lose institutional knowledge again
                              - - Persistent storage of bug patterns, design decisions, code patterns, and key facts
                                - - Full-text searchable archive
                                  - - Automatically integrated into new sessions
                                    - - Survives session breaks without context loss
                                     
                                      - **Use Case:** "Why did we choose Postgres?" → Instantly find the decision record and rationale.
                                     
                                      - #### **3. Epic/Task Management with Dependencies** 📊
                                      - - Structure large projects reliably
                                        - - Organize work into epics and atomic tasks
                                          - - Declare explicit dependencies between tasks
                                            - - Automatic task state management (pending → ready → in_progress → completed)
                                              - - Lock management prevents concurrent modifications
                                                - - Supports parallel work on independent tasks
                                                 
                                                  - **Use Case:** Feature A depends on API refactoring (Task 1). While Task 1 runs, work continues on parallel Feature B.
                                                 
                                                  - #### **4. 15 Specialized Agents** 👥
                                                  - - The right person for every role
                                                    - - Developer - Code implementation
                                                      - - Architect - System design and ADRs
                                                        - - Project Manager - Requirements and scope
                                                          - - Security Boss - Auth, payments, security
                                                            - - Quality Engineer - Testing and verification
                                                              - - DevOps - CI/CD, deployment
                                                                - - Performance Enhancer - Profiling and optimization
                                                                  - - ...and 8 more specialized roles
                                                                   
                                                                    - Route work to the perfect agent: `@architect explain this design decision`
                                                                   
                                                                    - #### **5. Reusable Skills** 🎯
                                                                    - - Workflows that actually work
                                                                      - - `/new-project` - Full project initialization with PRD, architecture, tasks
                                                                        - - `/reflect resume` - Seamless session continuation with full context
                                                                          - - `/new-feature` - Add features with PRD, tests, and deployment
                                                                            - - `/fix-bug` - Debug with integrated knowledge base
                                                                              - - `/refactor` - Restructure code safely
                                                                                - - `/create-pr` - Generate polished pull requests
                                                                                  - - `/pdf` - Document processing and manipulation
                                                                                    - - ...more specialized workflows
                                                                                     
                                                                                      - #### **6. Hook Enforcement** 🛡️
                                                                                      - - Mandatory security gates (not just suggestions)
                                                                                        - - Blocks code writes without active session/task registry
                                                                                          - - Prevents modifications to protected files (.env, .git/)
                                                                                            - - Enforces command allowlists
                                                                                              - - Saves context before compaction
                                                                                                - - Non-negotiable project rules
                                                                                                 
                                                                                                  - ---
                   

                                                                                        ### Before Claude Forge
                                                                                        ```
                                                                                        Session 1: Build auth module        → Lost context when session ends
                                                                                        Session 2: "Where did we stop?"      → Re-read all files, duplicate work
                                                                                        Session 3: Payment feature           → Conflicts with in-progress refactoring
                                                                                        Session 4: "Why is this pattern?"    → No decision history
                                                                                        ```

                                                                                        ### With Claude Forge
                                                                                        ```
                                                                                        Session 1: /new-project "E-commerce platform"
                                                                                                   → PRD, ADRs, tasks created automatically
                                                                                                   → 3 agents dispatched in parallel

                                                                                        Session 2: /reflect resume          → Full context restored
                                                                                                   → Only changed files reloaded
                                                                                                   → Ready to continue where you left off

                                                                                        Session 3: /reflect status --dispatch
                                                                                                   → Shows which tasks can run in parallel
                                                                                                   → No conflicts, full coordination

                                                                                        Session 4: /remember search "why postgres"
                                                                                                   → Instantly find the decision and rationale
                                                                                        ```

                                                                                        ---

                                                                                        ## 🚀 Key Features Summary

                                                                                        | Feature | Benefit | Example |
                                                                                        |---------|---------|---------|
                                                                                        | **Autonomous Development** | Go from idea to deployed code | `/new-project "SaaS dashboard"` → full implementation |
                                                                                        | **Task Management** | Never lose track of progress | Organize 50+ tasks with dependencies |
                                                                                        | **Intelligent Dispatch** | Parallel work without chaos | 3 features built simultaneously |
                                                                                        | **Project Memory** | Institutional knowledge persists | Find decisions, patterns, bugs instantly |
                                                                                        | **15 Agents** | Right tool for every job | Route to architect, PM, security expert |
                                                                                        | **Reusable Skills** | Tested workflows | `/new-feature`, `/fix-bug`, `/refactor` |
                                                                                        | **Hook Enforcement** | Safety without sacrifice | Mandatory gates for security and consistency |
                                                                                        | **Session Continuity** | Never start from scratch | Resume exactly where you left off |

                                                                                        ---
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
  - [Dispatch Commands](#dispatch-commands)
  - [Project Memory Commands](#project-memory-commands)
  - [PDF Commands](#pdf-commands)
- [Intelligent Dispatch](#intelligent-dispatch)
  - [Sub-Agent Dispatch](#sub-agent-dispatch)
  - [Intent Detection](#intent-detection)
  - [Configuration](#dispatch-configuration)
- [Project Memory](#project-memory)
- [Setup Guide](#setup-guide)
- [Directory Structure](#directory-structure)
- [Framework Components](#framework-components)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## Overview

**Claude Forge** enables structured, safe, autonomous development by providing:

- **Task Management** - Epic/task tracking with dependencies for parallel work
- **Agent Personas** - 15 specialized agents for different roles (developer, architect, PM, etc.)
- **Skills** - Reusable workflows for common tasks (features, bugs, refactoring, PRs)
- **Templates** - Standardized document formats (PRD, ADR, epics, tasks)
- **Hook Enforcement** - Mandatory gates enforced via Claude Code hooks (not advisory)
- **Security Model** - Safe autonomous operation with command allowlists
- **Session Continuity** - Context preservation and minimal-context resume
- **Autonomous Development** - Full project implementation from idea to code
- **Intelligent Dispatch** - Automatic sub-agent parallelization and intent detection
- **Token Optimization** - On-demand loading of tools and references to preserve context
- **Project Memory** - Persistent institutional knowledge (bugs, decisions, patterns, facts)

---

## Quick Start

### New Project

Start a brand new project with Claude Forge:

```bash
# 1. Create your project directory
mkdir my-new-project && cd my-new-project

# 2. Clone Claude Forge as your .claude directory
git clone https://github.com/rynhardt81/claude-forge.git .claude
rm -rf .claude/.git

# 3. Start Claude Code and initialize
claude
```

Then run in Claude Code:
```
/new-project "My awesome e-commerce app"
```

The `/new-project` command runs a **continuous workflow**:

| Phase | What Happens | Output |
|-------|--------------|--------|
| 0 | Framework setup | `.claude/` structure, CLAUDE.md, memories |
| 1 | Requirements discovery | `docs/prd.md` |
| 2 | Architecture & standards | ADRs, populated reference docs |
| 3 | Task planning | `docs/epics/`, `docs/tasks/registry.json` |

After initialization, start working:
```
/reflect status --ready   # See available tasks
/reflect resume T001      # Start first task
```

---

### Existing Project (No Previous Claude Config)

Add Claude Forge to an existing codebase that doesn't have a `.claude` directory:

```bash
# 1. Navigate to your project
cd /path/to/existing-project

# 2. Clone Claude Forge as .claude
git clone https://github.com/rynhardt81/claude-forge.git .claude
rm -rf .claude/.git

# 3. Start Claude Code
claude
```

Then run in Claude Code:
```
/new-project --current
```

The `--current` flag analyzes your existing codebase:
- **Discovers** your tech stack from package.json, requirements.txt, etc.
- **Identifies** project structure, existing commands, and patterns
- **Presents findings** for your confirmation before proceeding
- **Creates** PRD, architecture docs, and task breakdown based on existing code

---

### Existing Project (Migrating from Previous Claude Config)

If your project already has a `.claude` directory with previous configuration:

**Option 1: Using Migration Script (Recommended)**

```bash
# 1. Clone Claude Forge to any location
git clone https://github.com/rynhardt81/claude-forge.git
cd claude-forge

# 2. Run the migration script
./scripts/migrate.sh              # macOS/Linux
# or
.\scripts\migrate.ps1             # Windows PowerShell

# 3. Follow prompts - enter your project path
# The script will:
#   - Backup your existing .claude/ to .claude_old/
#   - Install Claude Forge to your project's .claude/
#   - Create a restoration script for rollback

# 4. Start Claude Code in your project
cd /path/to/your-project
claude
```

Then run in Claude Code:
```
/migrate
```

The `/migrate` skill:
- Merges your old configuration (memories, settings, project docs)
- Runs brownfield analysis to fill documentation gaps
- Creates missing PRD, ADRs, and task registry
- Preserves your project history

**Option 2: Manual Migration**

```bash
cd /path/to/existing-project
mv .claude .claude_old
git clone https://github.com/rynhardt81/claude-forge.git .claude
rm -rf .claude/.git
claude
# Then run: /migrate
```

---

### Autonomous Development

For full autonomous implementation from idea to code:

```
/new-project "E-commerce platform for handmade crafts" --autonomous
```

This runs Phases 0-5:
- Phases 0-3: Same as standard (PRD, ADRs, tasks)
- Phase 4: MCP server setup, security model
- Phase 5: Kickoff with `/implement-features`

Combine with existing project:
```
/new-project --current --autonomous
```

---

### Minimal Setup

Framework setup only (skip documentation):

```
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
| `/migrate` | Migrate existing project to Claude Forge |
| `/migrate --skip-analysis` | Migrate without brownfield analysis |
| `/implement-features` | Implement features (autonomous mode) |
| `/implement-features --mode=yolo` | Fast mode (lint only) |
| `/implement-features --resume` | Resume from last session |
| `/implement-features --parallel` | Enable parallel feature dispatch |
| `/implement-features --max-agents=5` | Override max parallel agents |

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
| `/reflect status --dispatch` | Show dispatch analysis for ready tasks |
| `/reflect unlock T002` | Force unlock stale task |
| `/reflect config` | Show configuration |
| `/reflect config dispatch` | Show dispatch configuration |
| `/reflect config intent` | Show intent detection configuration |
| `/reflect config lockTimeout 1800` | Update setting |
| `/reflect config --preset balanced` | Apply configuration preset |
| `/reflect on` | Enable auto-reflection |
| `/reflect off` | Disable auto-reflection |

### Dispatch Commands

| Command | Description |
|---------|-------------|
| `/reflect dispatch on` | Enable automatic sub-agent dispatch |
| `/reflect dispatch off` | Disable automatic sub-agent dispatch |
| `/reflect intent on` | Enable intent detection |
| `/reflect intent off` | Disable intent detection |

### Project Memory Commands

| Command | Description |
|---------|-------------|
| `/remember bug "title"` | Record a bug pattern with root cause |
| `/remember decision "title"` | Record a technical decision |
| `/remember fact "label: value"` | Record a key fact |
| `/remember pattern "title"` | Record a code pattern |
| `/remember search "query"` | Search memories (FTS5) |
| `/remember list` | List recent memories |
| `/remember list <category>` | List specific category |

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

## Intelligent Dispatch

The framework includes an **Intelligent Dispatch System** that automatically parallelizes work and detects user intent.

### Sub-Agent Dispatch

Automatically analyzes task dependencies and spawns parallel agents for independent work:

- **At Resume** - Analyzes registry for parallelizable tasks
- **After Task Completion** - Re-analyzes to find newly unblocked tasks
- **After Feature Completion** - Checks for parallelizable features

**Task Registry Dispatch:**
1. Gets all `ready` tasks (dependencies met, not locked)
2. Builds dependency graph to find independent clusters
3. Checks scope conflicts (overlapping files/directories)
4. Spawns sub-agents with isolated scope and context

**Feature Database Dispatch:**
- Different categories can often parallelize
- Same-category features run sequentially (shared files)
- Critical categories (A: Security, P: Payment) never parallelize

### Intent Detection

Detects natural language patterns and suggests appropriate skills:

| Pattern | Suggested Skill |
|---------|-----------------|
| "add feature", "implement", "build" | `/new-feature` |
| "fix bug", "debug", "broken" | `/fix-bug` |
| "refactor", "clean up", "restructure" | `/refactor` |
| "create pr", "pull request" | `/create-pr` |
| "continue", "resume", "pick up where" | `/reflect resume` |
| "design", "think through", "explore" | `brainstorming` |

**Rules:**
- Only suggests when confidence ≥ 0.7
- Always suggests, never auto-invokes (user must confirm)
- Respects explicit commands (if user types `/skill`, skip detection)

### Dispatch Configuration

Location: `.claude/memories/.dispatch-config.json`

| Setting | Default | Description |
|---------|---------|-------------|
| `dispatch.enabled` | true | Enable automatic sub-agent dispatch |
| `dispatch.mode` | "automatic" | "automatic" or "confirm" before spawning |
| `dispatch.maxParallelAgents` | 3 | Max concurrent sub-agents |
| `intentDetection.enabled` | true | Enable natural language skill detection |
| `intentDetection.mode` | "suggest" | "suggest" (always) or "off" |
| `intentDetection.confidenceThreshold` | 0.7 | Minimum confidence to suggest skill |

**Presets:**
| Preset | Description | Settings |
|--------|-------------|----------|
| `careful` | New projects | confirm mode, 2 agents, 0.8 threshold |
| `balanced` | Normal use | automatic mode, 3 agents, 0.7 threshold |
| `aggressive` | Large projects | automatic mode, 5 agents, 0.6 threshold |

Apply with: `/reflect config --preset balanced`

---

## Project Memory

The **Project Memory** system captures institutional knowledge that persists across sessions, preventing "AI project amnesia" where valuable context is lost between conversations.

### Memory Categories

| Category | File | Purpose |
|----------|------|---------|
| **Bugs** | `docs/project-memory/bugs.md` | Bug patterns, root causes, and solutions |
| **Decisions** | `docs/project-memory/decisions.md` | Technical decisions with rationale |
| **Key Facts** | `docs/project-memory/key-facts.md` | Important project facts |
| **Patterns** | `docs/project-memory/patterns.md` | Reusable code patterns |

### How It Works

1. **Recording Memories** - Use `/remember <category> "description"` to capture knowledge
2. **ToC-Based Loading** - Each file has a table of contents for token-efficient scanning
3. **Smart Loading** - `/reflect resume` loads relevant memories based on task context
4. **Bug Integration** - `/fix-bug` automatically checks bugs.md before diagnosis
5. **Full-Text Search** - SQLite FTS5 archive enables searching across all memories

### Usage Examples

```bash
# After fixing a tricky bug
/remember bug "Async test failures were caused by missing await on database cleanup"

# After a technical decision
/remember decision "Chose Postgres over SQLite for production due to concurrent writes"

# Recording key facts
/remember fact "max_connections: 100 (load balanced across 3 DB replicas)"

# Recording patterns
/remember pattern "Use the retry decorator for all external API calls"

# Searching memories
/remember search "database connection"
```

### Adding to Existing Projects

For projects that already have Claude Forge installed:

```bash
# macOS/Linux
./scripts/add-project-memory.sh

# Windows PowerShell
.\scripts\add-project-memory.ps1
```

These scripts:
- Create `docs/project-memory/` with template files
- Install the `/remember` skill
- Update `/fix-bug` and `/reflect` with memory integration
- Create timestamped backups before overwriting existing files

---

## Setup Guide

### Option A: New Project Setup

```bash
# Create project and clone framework
mkdir my-project && cd my-project
git clone https://github.com/rynhardt81/claude-forge.git .claude
rm -rf .claude/.git

# Start Claude Code and initialize
claude
# Run: /new-project "My project description"
```

### Option B: Existing Project Setup

```bash
# Navigate to your project
cd /path/to/existing-project

# Clone framework
git clone https://github.com/rynhardt81/claude-forge.git .claude
rm -rf .claude/.git

# Start Claude Code and analyze codebase
claude
# Run: /new-project --current
```

### Option C: Migration from Previous Claude Config

Use the migration scripts if your project already has a `.claude` directory:

```bash
# Clone framework to a temporary location
git clone https://github.com/rynhardt81/claude-forge.git
cd claude-forge

# Run migration script
./scripts/migrate.sh              # macOS/Linux
.\scripts\migrate.ps1             # Windows

# Follow prompts, then start Claude Code in your project
cd /path/to/your-project
claude
# Run: /migrate
```

### Project Structure After Setup

```
your-project/
├── .claude/                    # Claude Forge framework
│   ├── CLAUDE.md               # Your project's Claude instructions
│   ├── scripts/                # Migration scripts
│   ├── agents/                 # Agent personas
│   ├── skills/                 # Workflow skills
│   ├── templates/              # Document templates
│   ├── reference/              # Architecture doc templates
│   ├── security/               # Security model
│   ├── mcp-servers/            # MCP server implementations
│   ├── memories/               # Session continuity
│   └── ...
├── docs/                       # Project documentation (created by /new-project)
│   ├── prd.md                  # Product requirements
│   ├── tasks/                  # Task registry
│   └── epics/                  # Epic and task files
├── src/                        # Your source code
└── ...
```

### What /new-project Does

The `/new-project` command automatically:
1. Creates `.claude/CLAUDE.md` with your project details
2. Initializes memory structure with session tracking
3. Copies reference templates
4. Creates PRD through requirements discovery
5. Creates ADRs through architecture planning
6. Creates epic/task structure for development

### Manual Setup (Alternative)

If you prefer manual setup:

**Create CLAUDE.md:**
```bash
cp .claude/templates/CLAUDE.template.md .claude/CLAUDE.md
# Then edit .claude/CLAUDE.md with your project details
```

**Initialize memories:**
```bash
mkdir -p .claude/memories/sessions/active
mkdir -p .claude/memories/sessions/completed
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
├── scripts/                     # Setup & migration scripts
│   ├── migrate.sh               # Unix/Mac migration script
│   └── migrate.ps1              # Windows PowerShell migration script
│
├── agents/                      # Full agent personas (15 agents)
│   ├── security-boss.md         # Security, auth, payments
│   ├── architect.md             # System design, ADRs
│   ├── project-manager.md       # PRDs, scope management
│   ├── scrum-master.md          # Sprint planning, task breakdown
│   ├── quality-engineer.md      # Testing, code review
│   ├── developer.md             # Code implementation
│   ├── analyst.md               # Requirements discovery
│   ├── devops.md                # CI/CD, deployment
│   ├── performance-enhancer.md  # Profiling, optimization
│   ├── api-tester.md            # Load testing, API contracts
│   ├── ux-designer.md           # User flows, wireframes
│   ├── visual-mistro.md         # Diagrams, charts
│   ├── whimsy.md                # Animations, micro-interactions
│   ├── ceo.md                   # Strategic decisions
│   └── orchestrator.md          # Workflow coordination
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
│   ├── migrate/                 # Framework migration
│   │   ├── SKILL.md             # Migration workflow
│   │   ├── PHASES.md            # Phase instructions
│   │   ├── MERGE-RULES.md       # Content migration rules
│   │   └── CHECKPOINTS.md       # User confirmation points
│   ├── remember/                # Project memory management
│   │   ├── SKILL.md             # Memory recording workflow
│   │   ├── CATEGORIES.md        # Category definitions
│   │   ├── ARCHIVE.md           # SQLite archive instructions
│   │   └── EXTRACTION.md        # Content extraction rules
│   ├── implement-features/      # Autonomous implementation
│   ├── pdf/                     # PDF processing
│   └── ...
│
├── hooks/                       # Claude Code hooks
│   ├── gate-check.sh            # Blocks code writes without session/registry
│   ├── validate-edit.sh         # Blocks .env, lock files, .git/
│   ├── session-context.sh       # Shows status on session start/resume/compact
│   ├── session-end.sh           # Cleanup on session end
│   ├── pre-compact.sh           # Saves state before context compaction
│   ├── settings.example.json    # Hooks-only settings template
│   └── README.md                # Hook documentation
│
├── templates/                   # Document templates
│   ├── CLAUDE.template.md       # CLAUDE.md template
│   ├── settings.json            # Full settings (hooks + permissions + MCP)
│   ├── prd.md                   # Product Requirements
│   ├── epic-minimal.md          # Epic template
│   ├── task.md                  # Task template
│   ├── task-registry.json       # Registry template
│   ├── config.json              # Config template
│   ├── adr-template.md          # Architecture Decision
│   ├── session.md               # Session file template
│   ├── project-memory/          # Project memory templates
│   │   ├── bugs.md              # Bug pattern template
│   │   ├── decisions.md         # Decision record template
│   │   ├── key-facts.md         # Key facts template
│   │   └── patterns.md          # Code pattern template
│   └── ...
│
├── reference/                   # Architecture doc templates
│   ├── 00-documentation-governance.md
│   ├── 01-system-overview.template.md
│   ├── 10-parallel-sessions.md  # Parallel session coordination
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
│   ├── progress-notes.md        # Session summaries (append-only)
│   └── sessions/
│       ├── active/              # Currently running sessions
│       ├── completed/           # Archived sessions
│       └── latest.md            # Most recent session pointer
│
└── commands/                    # Command definitions
    ├── new-project.md           # /new-project definition
    └── reflect.md               # /reflect definition

docs/                            # Project documentation (created by /new-project)
├── prd.md                       # Product Requirements Document
├── tasks/
│   ├── registry.json            # Master task/epic registry
│   └── config.json              # Project configuration
├── project-memory/              # Institutional knowledge (created by /new-project or add-project-memory script)
│   ├── bugs.md                  # Bug patterns and solutions
│   ├── decisions.md             # Technical decisions with rationale
│   ├── key-facts.md             # Important project facts
│   └── patterns.md              # Reusable code patterns
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
| Migrate | `/migrate` | Migrate existing project to Claude Forge |
| Implement | `/implement-features` | Autonomous feature loop |
| Remember | `/remember` | Project memory management |
| PDF | `/pdf <command>` | PDF processing tasks |

### Agents

Agents are invoked with `@agent-name: [task]`. They are NOT automatic - you must route work to them.

| Agent | Role | When to Use |
|-------|------|-------------|
| @security-boss | Security | Auth, payments, security-sensitive code |
| @architect | System design | Architecture decisions, ADRs |
| @project-manager | Planning | PRDs, scope, requirements |
| @scrum-master | Sprint management | Task breakdown, tracking |
| @quality-engineer | Testing | Test strategy, verification |
| @developer | Implementation | Writing code (default) |
| @analyst | Requirements discovery | User research, problem analysis |
| @devops | Infrastructure | CI/CD, Docker, K8s, deployment |
| @performance-enhancer | Performance | Profiling, optimization |
| @api-tester | API testing | Load testing, API contracts |
| @ux-designer | UX/UI design | User flows, wireframes |
| @visual-mistro | Visuals | Diagrams, charts, architecture visuals |
| @whimsy | Micro-interactions | Animations, delightful touches |
| @ceo | Strategy | Go/no-go decisions, prioritization |
| @orchestrator | Workflow coordination | Unsure which agent to use |

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
| `dispatch.enabled` | true | Enable automatic sub-agent dispatch |
| `dispatch.mode` | "automatic" | "automatic" or "confirm" before spawning |
| `intentDetection.enabled` | true | Enable natural language skill detection |
| `intentDetection.mode` | "suggest" | "suggest" (always) or "off" |
| `intentDetection.confidenceThreshold` | 0.7 | Minimum confidence to suggest skill |

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

### Hooks not enforcing gates

**Check:** Is `settings.json` configured?
```bash
ls -la .claude/settings.json
```

**Fix:** Install hooks:
```bash
chmod +x .claude/hooks/*.sh
cp .claude/templates/settings.json .claude/settings.json
```

**Verify:** Test gate-check (should exit with code 2):
```bash
echo '{"tool_input":{"file_path":"test.js"}}' | bash .claude/hooks/gate-check.sh
```

### Task registry not found

**Check:** Did you run `/new-project`?
```bash
ls docs/tasks/registry.json
```

**Fix:** Run `/new-project` or create manually from template.

---

## Version

**Framework Version:** 1.6.0
**Last Updated:** 2026-01-16

### Changelog

**v1.6.0** (2026-01-16)
- Added Project Memory system for persistent institutional knowledge
- Added `/remember` skill with categories: bugs, decisions, patterns, key-facts
- Added ToC-based loading for token-efficient memory access
- Added SQLite FTS5 archive for full-text memory search
- Updated `/fix-bug` with memory phases (0, 4.5, 5.5)
- Updated `/reflect resume` with smart memory loading
- Updated migration scripts to initialize project memory
- Added `add-project-memory.sh` and `add-project-memory.ps1` for existing installations
- Added `templates/project-memory/` with category templates

**v1.5.0** (2026-01-15)
- Added hook enforcement system for mandatory gates (not advisory)
- Added `templates/settings.json` with hooks, permissions, and MCP servers
- Added all 15 agents to CLAUDE.md routing table
- Added TOKEN OPTIMIZATION section for on-demand loading
- Fixed hooks format for SessionStart/Stop (matcher required)
- Updated `/new-project` and `/migrate` skills to install hooks automatically
- Added `pre-compact.sh` hook for saving state before context compaction
- Added SessionStart matchers for `resume`, `compact`, and `clear` events

**v1.4.0** (2026-01-12)
- Added Intelligent Dispatch System for automatic sub-agent parallelization
- Added Intent Detection for natural language skill suggestions
- Added dispatch configuration with presets (careful, balanced, aggressive)
- Added `/reflect dispatch` and `/reflect intent` toggle commands
- Added `--parallel` and `--max-agents` flags to `/implement-features`
- Added `--dispatch` flag to `/reflect status`

**v1.3.0** (2026-01-11)
- Added `/migrate` skill for migrating existing projects to Claude Forge
- Added `scripts/migrate.sh` and `scripts/migrate.ps1` for automated setup
- Added parallel session support with conflict detection
- Improved session management with active/completed directories

**v1.2.0** (2026-01-09)
- Added epic/task dependency system with parallel work support
- Added progress tracking at each phase checkpoint
- Improved session continuity with structured session files

---

## License

MIT License - See LICENSE file for details.

---

## Contributing

Contributions welcome! Please read the contributing guidelines before submitting PRs.

---

*Claude Forge enables structured, safe, and optional autonomous development with human oversight at key checkpoints.*
