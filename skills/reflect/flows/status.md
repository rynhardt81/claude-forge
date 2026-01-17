# Status Flow

Handles `/reflect status` and its variants.

---

## `/reflect status`

Show overview of all epics, tasks, and active sessions.

**Output:**

```markdown
## Project Status

**Epics:** 4 total (1 completed, 2 in_progress, 1 pending)
**Tasks:** 32 total (12 completed, 2 in_progress, 8 ready, 10 pending)
**Active Sessions:** 2

### Active Sessions
| Session ID | Branch | Scope | Started |
|------------|--------|-------|---------|
| 20240115-143022-a7x9 | feature/auth | src/auth/ | 2h ago |
| 20240115-150045-k2m3 | feature/dashboard | src/dashboard/ | 30m ago |

### Epic Overview
| ID | Name | Status | Progress |
|----|------|--------|----------|
| E01 | Authentication | completed | 8/8 |
| E02 | Dashboard | in_progress | 5/10 |
| E03 | Reports | in_progress | 2/8 |
| E04 | Admin Panel | pending | 0/6 |

### Ready Tasks (available to work on)
| ID | Epic | Name | Priority |
|----|------|------|----------|
| T015 | E02 | Add chart component | 1 |
| T016 | E02 | Implement filters | 2 |
| T021 | E03 | Create report template | 1 |

### In Progress
| ID | Name | Locked By | Since |
|----|------|-----------|-------|
| T014 | Dashboard layout | session-abc | 2h ago |
```

---

## `/reflect status --sessions`

Show detailed information about active parallel sessions.

**Output:**

```markdown
## Active Sessions

| Session ID | Branch | Scope | Started | Status |
|------------|--------|-------|---------|--------|
| 20240115-143022-a7x9 | feature/auth | src/auth/, src/middleware/ | 2h ago | active |
| 20240115-150045-k2m3 | feature/dashboard | src/dashboard/ | 30m ago | active |

### Session Details

#### 20240115-143022-a7x9
**Branch:** feature/auth
**Directories:** src/auth/, src/middleware/
**Working On:** Implement JWT validation
**Commits:** 3

#### 20240115-150045-k2m3
**Branch:** feature/dashboard
**Directories:** src/dashboard/
**Working On:** Dashboard layout component
**Commits:** 1

### Potential Conflicts
None detected.
```

---

## `/reflect status --locked`

Show only locked tasks.

**Output:**

```markdown
## Locked Tasks

| ID | Name | Locked By | Since | Stale? |
|----|------|-----------|-------|--------|
| T014 | Dashboard layout | session-abc | 2h ago | No |
| T022 | Report export | session-xyz | 5h ago | YES |

**Stale locks** (> 1h) can be unlocked with `/reflect unlock <id>`
```

---

## `/reflect status --ready`

Show tasks ready to work on (all dependencies met, not locked).

**Output:**

```markdown
## Ready Tasks

| ID | Epic | Name | Priority | Category |
|----|------|------|----------|----------|
| T015 | E02 | Add chart component | 1 | F-Display |
| T016 | E02 | Implement filters | 2 | G-Search |
| T021 | E03 | Create report template | 1 | F-Display |

Use `/reflect resume T015` to start working on a task.
```

---

## `/reflect status --dispatch`

Show dispatch analysis for currently ready tasks.

**Output:**

```markdown
## Dispatch Analysis

### Ready Tasks
| ID | Name | Priority | Scope | Can Parallelize |
|----|------|----------|-------|-----------------|
| T015 | Add chart component | 1 | src/components/charts/ | Yes |
| T016 | Implement filters | 2 | src/components/filters/ | Yes |
| T021 | Create report template | 1 | src/reports/ | Yes |
| T017 | Update chart styles | 3 | src/components/charts/ | No (scope conflict with T015) |

### Parallelization Proposal
Based on dependency analysis and scope checking:

**Main Agent:**
- T015: Add chart component (Priority 1)

**Sub-Agent 1:**
- T016: Implement filters (no scope overlap)

**Sub-Agent 2:**
- T021: Create report template (no scope overlap)

**Deferred (scope conflict):**
- T017: Update chart styles (shares scope with T015)

### Configuration
- Mode: automatic
- Max agents: 3
- Would spawn: 2 sub-agents

Start with this plan? [Y/n]
```

---

## Context Budget

| Operation | Target | Max |
|-----------|--------|-----|
| Status | 2k tokens | 4k |
