# CLAUDE.md

This file provides **mandatory operating instructions** to Claude Code when working with this repository.

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
│  │         Use template: .claude/templates/session.md       │   │
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

## 1. Authority & Document Hierarchy

Claude **must respect the following authority order**:

| Tier | Authority | Location |
|------|-----------|----------|
| 1 | Governance | `.claude/reference/00-documentation-governance.md` |
| 2 | Master Source-of-Truth | `.claude/reference/01-*.md` through `07-*.md` |
| 3 | Processed Supporting Docs | `docs/processed/` |
| 4 | Execution Guidance | This file (`CLAUDE.md`), `.claude/*` |

If guidance in this file conflicts with any master document, **the master document wins**.

---

## 2. Project Overview

<!-- CUSTOMIZE: Replace this section with your project description -->

**[Project Name]** is a [brief description of what the project does].

**Core Tech Stack:**
<!-- CUSTOMIZE: List your tech stack -->
* Backend: [e.g., FastAPI, Node.js, Go]
* Frontend: [e.g., React, Vue, Next.js]
* Database: [e.g., PostgreSQL, MongoDB]
* Infrastructure: [e.g., Docker, Kubernetes]

---

## 3. Essential Commands

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

---

## 4. Session Continuity

Use the `/reflect` skill for session management and continuity:

| Command | Purpose |
|---------|---------|
| `/reflect resume` | Load last session context and continue |
| `/reflect` | Capture learnings and session state |
| `/reflect status` | Show task/epic status overview |
| `/reflect status --sessions` | Show active parallel sessions |
| `/reflect cleanup` | Clean up stale sessions |

---

## 5. Skills System

**CRITICAL: Always use the Skill tool to invoke skills. Never rely on memory.**

| Skill | Purpose |
|-------|---------|
| `/reflect` | Session management and continuity |
| `/new-project` | Project initialization |
| `/new-feature` | Feature development workflow |
| `/fix-bug` | Bug fixing workflow |
| `/refactor` | Code refactoring workflow |
| `/create-pr` | Pull request creation |
| `/release` | Version release |
| `/implement-features` | Autonomous feature implementation |

### Skill Priority

When multiple skills could apply:
1. **Process skills first** (brainstorming, debugging) - determine HOW to approach
2. **Implementation skills second** (feature, refactor) - guide execution

---

## 6. Agent System

Specialized agents live in `.claude/agents/`. Use via Task tool with `subagent_type`.

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

---

## 7. Parallel Session Support

### Directory Structure

```
.claude/memories/
├── progress-notes.md           # Append-only log (NEVER overwrite)
├── general.md                  # Project preferences
├── sessions/
│   ├── active/                 # Currently running sessions
│   ├── completed/              # Archived sessions
│   └── latest.md               # Points to most recent
```

### Coordination Rules

| Scenario | Rule | Action |
|----------|------|--------|
| Same branch | **BLOCK** | Cannot proceed - user must choose |
| Same directory | **WARN** | Alert user, require confirmation |
| Same file | **ASK** | Must get user approval |
| Merge/PR | **EXCLUSIVE** | Only one session can merge at a time |

See `.claude/reference/10-parallel-sessions.md` for full documentation.

---

## 8. Referenced Master Documentation

Claude **must consult these documents when relevant**:

| Document | Scope |
|----------|-------|
| `01-system-overview.md` | What/why, boundaries |
| `02-architecture-and-tech-stack.md` | How it's built |
| `03-security-auth-and-access.md` | Security contract |
| `04-development-standards-and-structure.md` | How code is written |
| `05-operational-and-lifecycle.md` | How it runs |
| `06-architecture-decisions.md` | ADRs, why decisions |
| `07-non-functional-requirements.md` | Quality constraints |
| `10-parallel-sessions.md` | Multi-session coordination |

---

## 9. Machine-Enforceable Rules (JSON)

> **Claude must obey the following rules exactly.**

```json
{
  "document_id": "CLAUDE",
  "document_type": "claude_execution_contract",
  "authority_level": "operational",
  "version": "2.0.0",

  "governed_by": ".claude/reference/00-documentation-governance.md",

  "master_documents_location": ".claude/reference/",
  "feature_specs_location": ".claude/features/",

  "session_enforcement": {
    "protocol_required": true,
    "session_file_required": true,
    "scope_declaration_required": true,
    "conflict_check_required": true,
    "append_only_progress_notes": true
  },

  "workflow_enforcement": {
    "planning_required": true,
    "planning_file": ".claude/memories/sessions/active/session-{id}.md",
    "user_confirmation_required": true,
    "small_changes_only": true,
    "step_by_step_processing": true
  },

  "parallel_session_rules": {
    "branch_collision": "BLOCK",
    "directory_overlap": "WARN",
    "file_collision": "ASK",
    "merge_collision": "QUEUE"
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

## 10. Quick Reference

### Common Tasks

| Task | Command/Skill |
|------|---------------|
| Start session | Session protocol (automatic) |
| Resume work | `/reflect resume` |
| End session | `/reflect` |
| Check status | `/reflect status` |
| New feature | `/new-feature` |
| Fix bug | `/fix-bug` |
| Create PR | `/create-pr` |

### File Locations

| Content | Location |
|---------|----------|
| Master docs | `.claude/reference/` |
| Feature specs | `.claude/features/` |
| Skills | `.claude/skills/` |
| Agents | `.claude/agents/` |
| Sessions | `.claude/memories/sessions/` |
| Progress notes | `.claude/memories/progress-notes.md` |

---

<!-- CUSTOMIZE: Add any project-specific sections below -->
