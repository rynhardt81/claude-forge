# CLAUDE.md - Claude Forge Framework

This file provides Claude Code with **mandatory operating instructions** for this framework.

---

## ABSOLUTE GATES: NO CODE WITHOUT THESE

**YOU CANNOT WRITE A SINGLE LINE OF CODE until ALL gates are passed.**

| Gate | Requirement | If Not Met |
|------|-------------|------------|
| **1. SESSION ACTIVE** | Session file exists in `.claude/memories/sessions/active/` | CREATE ONE FIRST |
| **2. EPICS/TASKS EXIST** | `docs/tasks/registry.json` exists with epics and tasks | Run `/new-project --current` |
| **3. WORKING ON TASK** | You have a specific task ID from registry | Run `/reflect resume T###` |
| **4. SKILL INVOKED** | Development skills invoked via Skill tool (not memory) | INVOKE SKILL TOOL |
| **5. AGENT DELEGATED** | Specialized work uses appropriate agent | DELEGATE TO AGENT |

**Exception:** Framework maintenance in `.claude/` directory bypasses Gate 2.

### Gate Check Flow

```
User Request → Gate 1 (Session?) → Gate 2 (Registry?) → Gate 3 (Task?) → Gate 4 (Skill?) → Gate 5 (Agent?) → PROCEED
                  ↓ No              ↓ No                ↓ No             ↓ No              ↓ No
              Create session    /new-project        /reflect resume   Invoke Skill     Delegate to agent
```

---

## 12 INVIOLABLE RULES

1. **Never start work without session protocol** - No exceptions, not even "quick" tasks
2. **Never write code without epics and tasks** - ALL work needs task IDs
3. **Never skip skill invocation** - Skills evolve; always invoke via Skill tool
4. **Never skip agent delegation** - Specialized work requires specialized agents
5. **Never modify files outside declared scope** - Update session file first to expand
6. **Never assume requirements** - ASK for clarification when ambiguous
7. **Always commit after each task** - Include task ID in commit message
8. **Never skip conflict detection** - Check active sessions before modifying files
9. **Append-only for progress notes** - NEVER overwrite `.claude/memories/progress-notes.md`
10. **Update session file in real-time** - Don't wait until session end
11. **Create tasks for ALL work** - New feature, bug fix, refactor → task first
12. **Epics MUST have tasks** - Empty epics are invalid

---

## STOP IF YOU THINK...

| Thought | Reality |
|---------|---------|
| "This is just a small change" | Small changes bypass process. STOP. |
| "I'll just quickly implement this" | Quick implementations cause conflicts. STOP. |
| "I remember this skill" | Skills evolve. Memory is unreliable. STOP. |
| "I don't need a task for this" | ALL work needs tasks. STOP. |
| "I can do this without the agent" | Agents ensure quality. STOP. |

---

## QUICK REFERENCE

### Key Commands

| Command | Description |
|---------|-------------|
| `/new-project "idea"` | Full workflow: PRD + ADRs + tasks |
| `/new-project --current` | Analyze existing codebase first |
| `/reflect resume` | Resume with full context |
| `/reflect resume T###` | Resume specific task |
| `/reflect status` | Show task/epic overview |
| `/migrate` | Migrate existing project to Claude Forge |

### Key Locations

| Location | Purpose |
|----------|---------|
| `.claude/memories/sessions/active/` | Currently running sessions |
| `.claude/memories/sessions/completed/` | Archived sessions |
| `.claude/memories/progress-notes.md` | Append-only session log |
| `docs/tasks/registry.json` | Task/epic registry |
| `docs/epics/` | Epic and task files |

### Agent Routing (MANDATORY)

Agents are invoked with `@agent-name: [task]`. They are NOT automatic - you must route work to them.

| Work Type | Agent | When to Use |
|-----------|-------|-------------|
| **Security, Auth, Payments** | @security-boss | ANY security-sensitive code |
| **Architecture, ADRs** | @architect | System design, tech choices |
| **PRD, Requirements** | @project-manager | Scope definition, requirements |
| **Epic/Task Breakdown** | @scrum-master | Breaking work into tasks |
| **Testing, QA** | @quality-engineer | Test strategy, verification |
| **General Implementation** | @developer | Feature coding (default) |
| **Requirements Discovery** | @analyst | User research, problem analysis |
| **CI/CD, Infrastructure** | @devops | Pipelines, deployment, Docker/K8s |
| **Performance** | @performance-enhancer | Profiling, optimization |
| **API Testing** | @api-tester | Load testing, API contracts |
| **UX/UI Design** | @ux-designer | User flows, wireframes |
| **Diagrams, Visuals** | @visual-mistro | Architecture diagrams, charts |
| **Micro-interactions** | @whimsy | Animations, delightful touches |
| **Strategic Decisions** | @ceo | Go/no-go, prioritization |
| **Workflow Coordination** | @orchestrator | Unsure which agent to use |

### Skill Routing (MANDATORY)

| Intent | Skill |
|--------|-------|
| Add feature, implement, build | `/new-feature` |
| Fix bug, debug, broken | `/fix-bug` |
| Refactor, clean up | `/refactor` |
| Create PR | `/create-pr` |
| Resume work | `/reflect resume` |

---

## TOKEN OPTIMIZATION

**Preserve context window. Load tools and references on-demand, not upfront.**

### Tool Use Strategy

| Principle | Implementation |
|-----------|----------------|
| **Defer tool loading** | Don't load all MCP tools upfront. Use Tool Search to discover tools when needed. |
| **Search before invoke** | When you need a capability, search for the right tool first rather than assuming. |
| **Batch tool calls** | Group related tool calls together to reduce round-trips. |
| **Minimize intermediate results** | Process tool outputs before returning large results to context. |

### Reference Loading Strategy

**DO NOT read all reference files at session start.** Load only what's needed for current work:

| Current Work | Load These References |
|--------------|----------------------|
| Starting session | Session protocol only |
| Working on tasks | Task management only |
| Implementing features | Skill invocation + agent delegation |
| Security work | Security model |
| Parallel work | Parallel sessions + dispatch |

### What NOT to Do

| Anti-Pattern | Why It Wastes Tokens | Better Approach |
|--------------|---------------------|-----------------|
| Read all reference docs at start | 50K+ tokens consumed immediately | Load on-demand |
| Load all MCP tools upfront | Each tool definition costs tokens | Use Tool Search |
| Return full file contents | Large outputs fill context | Extract relevant sections |
| Repeat skill content in responses | Skill already in context | Reference by name |

---

## DETAILED REFERENCES

For complete documentation, see these reference files:

| Topic | Reference |
|-------|-----------|
| Session Protocol | [reference/12-session-protocol.md](reference/12-session-protocol.md) |
| Task Management | [reference/13-task-management.md](reference/13-task-management.md) |
| Agent Delegation | [reference/14-agent-delegation.md](reference/14-agent-delegation.md) |
| Skill Invocation | [reference/15-skill-invocation.md](reference/15-skill-invocation.md) |
| Parallel Sessions | [reference/10-parallel-sessions.md](reference/10-parallel-sessions.md) |
| Intelligent Dispatch | [reference/11-intelligent-dispatch.md](reference/11-intelligent-dispatch.md) |
| Security Model | [reference/08-security-model.template.md](reference/08-security-model.template.md) |

**Load references on-demand** - DO NOT read all files at session start. Only load when needed:

```
Need to start session?     → Read reference/12-session-protocol.md
Need to work on tasks?     → Read reference/13-task-management.md
Need to implement feature? → Read reference/15-skill-invocation.md
Need specialized agent?    → Read reference/14-agent-delegation.md
Need parallel work?        → Read reference/10-parallel-sessions.md
```

---

## SESSION PROTOCOL SUMMARY

### Session Start (IN ORDER)

1. **Generate Session ID**: `{YYYYMMDD-HHMMSS}-{4-random-chars}`
2. **Create Session File**: `.claude/memories/sessions/active/session-{id}.md`
3. **Declare Scope**: Branch, directories, features
4. **Scan for Conflicts**: Check all active sessions
5. **Load Context**: Progress notes, registry, plans
6. **Confirm Ready**: All checks pass or user approved

### Conflict Resolution

| Conflict | Action |
|----------|--------|
| Same branch | **BLOCK** - User chooses which session continues |
| Same directory | **WARN** - User must confirm |
| Same file | **ASK** - User decides priority |

### Session End

1. Update session file with completed work
2. Move session file to `completed/`
3. Append summary to `progress-notes.md`
4. Update `latest.md` (only if no other active sessions)

---

## TASK WORKFLOW SUMMARY

### Task States

| Status | Description |
|--------|-------------|
| `pending` | Dependencies not met |
| `ready` | Can be started |
| `in_progress` | Currently being worked on |
| `continuation` | Partially complete |
| `completed` | Done |

### Creating New Tasks Mid-Project

1. **DO NOT** just start coding
2. **DO** invoke @scrum-master: `@scrum-master: Create task for [description]`
3. **THEN** use `/reflect resume T###`

---

## ERROR HANDLING

| Situation | Action |
|-----------|--------|
| Task fails 3 times | Set to `continuation`, document blocker, move to next task |
| Regression tests fail | STOP immediately, fix before continuing |
| Session crash | Check `git status`, `/reflect status --locked`, clean up, `/reflect resume` |

---

*This framework enables structured, safe, autonomous development with human oversight at key checkpoints.*
