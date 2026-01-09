# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 1. Purpose of This File

This file provides **execution and workflow guidance** to Claude Code when working with this repository.

It defines:

* How to run commands
* How to test and validate changes
* How to follow the development workflow
* How Claude should coordinate with the **authoritative master documentation**

This file is **Tier 4** (Execution Guidance) in the documentation hierarchy.
It **does not define architecture, security policy, or system design**.
Those are defined in the master documents and override this file if conflicts arise.

---

## 2. Authority & Document Hierarchy

Claude **must respect the following authority order**:

| Tier | Authority | Location |
|------|-----------|----------|
| 1 | Governance | `.claude/reference/00-documentation-governance.md` |
| 2 | Master Source-of-Truth | `.claude/reference/01-*.md` through `07-*.md` |
| 3 | Processed Supporting Docs | `docs/processed/` |
| 4 | Execution Guidance | This file (`CLAUDE.md`), `.claude/*` |

If guidance in this file conflicts with any master document, **the master document wins**.

---

## 3. Project Overview

<!-- CUSTOMIZE: Replace this section with your project description -->

**[Project Name]** is a [brief description of what the project does].

**Core Tech Stack:**
<!-- CUSTOMIZE: List your tech stack -->
* Backend: [e.g., FastAPI, Node.js, Go]
* Frontend: [e.g., React, Vue, Next.js]
* Database: [e.g., PostgreSQL, MongoDB]
* Infrastructure: [e.g., Docker, Kubernetes]

---

## 4. Essential Commands

<!-- CUSTOMIZE: Add your project's essential commands -->

### Development

```bash
# Start development
# make up / npm run dev / etc.

# Run tests
# make test / npm test / etc.

# Build
# make build / npm run build / etc.
```

### Testing

```bash
# Unit tests
# pytest tests/unit -v

# Integration tests
# pytest tests/integration -v

# All tests
# make test-all
```

### Code Quality

```bash
# Linting
# npm run lint / ruff check .

# Type checking
# npm run type-check / mypy app/

# Formatting
# npm run format / black app/
```

### Database

```bash
# Run migrations
# make db-migrate / alembic upgrade head

# Create migration
# make db-revision / alembic revision --autogenerate -m "description"
```

---

## 5. Architecture Summary

<!-- CUSTOMIZE: Provide high-level architecture overview or reference your docs -->

Refer to `.claude/reference/02-architecture-and-tech-stack.md` for detailed architecture.

### Project Structure

```
<!-- CUSTOMIZE: Add your project structure -->
project/
├── src/               # Source code
├── tests/             # Test files
├── docs/              # Documentation
└── .claude/           # Claude Code configuration
```

### Key Patterns

<!-- CUSTOMIZE: List architectural patterns used -->
* [Pattern 1]: [Brief description]
* [Pattern 2]: [Brief description]

---

## 6. Workflow Instructions (MANDATORY)

### Session Continuity

Use the `/reflect` skill for session management and continuity:

| Command | Purpose |
|---------|---------|
| `/reflect resume` | Load last session context and continue |
| `/reflect` | Capture learnings and session state |
| `/reflect on` | Enable auto-reflection at session end |

**Storage locations:**

| File | Purpose |
|------|---------|
| `.claude/memories/sessions/latest.md` | Most recent session state |
| `.claude/memories/sessions/YYYY-MM-DD.md` | Date-stamped session archives |
| `.claude/memories/general.md` | General preferences and learnings |
| `.claude/memories/progress-notes.md` | Ongoing work summaries and blockers |

**What gets captured:**
* Session summaries and context
* Decisions made and rationale
* Blockers encountered
* Tasks in progress

### Workflow for Non-Trivial Changes

1. **Start**: Run `/reflect resume` to load previous session context
2. **Plan**: Use TodoWrite tool to track tasks
3. **Confirm**: Check in with user before implementation
4. **Execute**: Work in small, isolated steps; mark progress via TodoWrite
5. **Complete**: Run `/reflect` to capture learnings and session state

### SIMPLE Method of Programming

* **S** – Small changes only
* **I** – Isolate the impact
* **M** – Minimize code touched
* **P** – Prefer clarity over cleverness
* **L** – Leave the code cleaner
* **E** – Eliminate bugs by reducing complexity

> **Find root causes. No temporary fixes.**

---

## 7. Skills System

Skills provide structured workflows for common tasks. Invoke with `/skill-name`.

### Available Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `/reflect` | Session continuity | Start/end sessions |
| `/new-feature` | Feature development | Adding new functionality |
| `/fix-bug` | Bug fixing | Debugging and fixes |
| `/refactor` | Code refactoring | Improving code structure |
| `/create-pr` | Pull request creation | Ready to open PR |
| `/release` | Version release | Publishing new versions |
| `/critique-progress` | Progress review | Evaluating current state |

### Skill Priority

When multiple skills could apply:
1. **Process skills first** (brainstorming, debugging) - determine HOW to approach
2. **Implementation skills second** (feature, refactor) - guide execution

---

## 8. Agent System

Specialized agents live in `.claude/agents/`. Use via Task tool with `subagent_type`.

### Available Agents

| Agent | Purpose |
|-------|---------|
| `orchestrator` | Workflow coordination |
| `analyst` | Discovery & requirements |
| `architect` | Architecture & ADRs |
| `developer` | Code implementation |
| `quality-engineer` | Testing & code reviews |
| `security-boss` | Security audits |
| `devops` | CI/CD & deployment |
| `project-manager` | PRDs & scope |
| `scrum-master` | Sprint planning |
| `ux-designer` | User flows & wireframes |
| `performance-enhancer` | Profiling & optimization |

### Sub-Agents (Focused Specialists)

Smaller, focused agents in `.claude/sub-agents/` for specific tasks:

| Sub-Agent | Purpose | Use When |
|-----------|---------|----------|
| `codebase-analyzer` | Project structure analysis | Onboarding, documentation |
| `pattern-detector` | Code conventions | Ensuring consistency |
| `requirements-analyst` | Requirements extraction | Feature planning |
| `tech-debt-auditor` | Debt assessment | Planning refactoring |
| `api-documenter` | API documentation | Creating API docs |
| `test-coverage-analyzer` | Test gap analysis | Improving coverage |
| `document-reviewer` | Doc quality review | Before publishing |

### Recommended Flow (New Features)

```
@analyst → @architect → @developer → @quality-engineer → @devops
```

For detailed agent commands and handoff protocols, see `.claude/agentworkflow.md`.

---

## 9. Referenced Master Documentation

Claude **must consult these documents when relevant**:

### Governance (Tier 1)

* `.claude/reference/00-documentation-governance.md`

### Source of Truth (Tier 2)

| Document | Scope |
|----------|-------|
| `01-system-overview.md` | What/why, boundaries |
| `02-architecture-and-tech-stack.md` | How it's built |
| `03-security-auth-and-access.md` | Security contract |
| `04-development-standards-and-structure.md` | How code is written |
| `05-operational-and-lifecycle.md` | How it runs |
| `06-architecture-decisions.md` | ADRs, why decisions |
| `07-non-functional-requirements.md` | Quality constraints |

### Standards

* `.claude/standards/documentation-style.md` — Writing standards

### Feature Specifications

Detailed feature documentation lives in `.claude/features/`.

---

## 10. Machine-Enforceable Rules (JSON)

> **Claude must obey the following rules exactly.**

```json
{
  "document_id": "CLAUDE",
  "document_type": "claude_execution_contract",
  "authority_level": "operational",
  "version": "1.0.0",

  "governed_by": ".claude/reference/00-documentation-governance.md",

  "master_documents_location": ".claude/reference/",
  "feature_specs_location": ".claude/features/",

  "workflow_enforcement": {
    "planning_required": true,
    "planning_file": ".claude/memories/sessions/latest.md",
    "user_confirmation_required": true,
    "small_changes_only": true,
    "step_by_step_processing": true
  },

  "documentation_processing": {
    "active_docs_path": "docs/",
    "processed_docs_path": "docs/processed/",
    "reuse_policy": "forbidden_without_explicit_reference"
  },

  "conflict_resolution": {
    "precedence_order": [
      "governance",
      "master_documents",
      "processed_docs",
      "execution_guidance"
    ],
    "rule": "governance_and_master_documents_override_execution_guidance"
  }
}
```

---

## 11. Autonomous Development (Optional)

<!-- CUSTOMIZE: Remove this section if not using autonomous development features -->

### Creating a New Project

Use `/new-project` to go from idea to implementation-ready:

```
/new-project "Your project idea here"
```

This triggers a 5-phase workflow:
1. **Requirements Discovery** - @analyst and @project-manager create PRD
2. **Feature Breakdown** - @scrum-master creates features in database
3. **Technical Planning** - @architect creates ADRs
4. **Implementation Readiness** - Setup MCP servers and security
5. **Kickoff** - User approval, start implementation

### Implementing Features

Use `/implement-features` to implement the feature database:

```
/implement-features              # Standard mode (full testing)
/implement-features --mode=yolo  # Fast mode (lint only)
/implement-features --resume     # Resume from last session
```

### State Persistence (Autonomous Mode)

In addition to the core session continuity (Section 6), autonomous mode adds:

1. **Feature Database** - `.claude/features/features.db`
   - Tracks which features are complete/pending
   - Priority and ordering
   - Test steps for each feature

2. **Feature IDs in Commits** - Git integration
   - Each commit references its feature ID
   - Enables traceability from code to requirements

### Resuming Autonomous Work

After a session ends, resume with:

```
/implement-features --resume
```

This will:
1. Read progress notes for context (from Section 6)
2. Query feature database for current state
3. Review recent git commits
4. Continue implementing from where you left off

> **Note:** For standard development, use `/reflect resume` instead (see Section 6).

---

## 12. Quick Reference

### Common Tasks

| Task | Command/Skill |
|------|---------------|
| Start session | `/reflect resume` |
| End session | `/reflect` |
| New feature | `/new-feature` |
| Fix bug | `/fix-bug` |
| Create PR | `/create-pr` |
| Release | `/release` |

### File Locations

| Content | Location |
|---------|----------|
| Master docs | `.claude/reference/` |
| Feature specs | `.claude/features/` |
| Skills | `.claude/skills/` |
| Agents | `.claude/agents/` |
| Sub-agents | `.claude/sub-agents/` |
| Standards | `.claude/standards/` |
| Sessions | `.claude/memories/sessions/` |

---

<!-- CUSTOMIZE: Add any project-specific sections below -->
