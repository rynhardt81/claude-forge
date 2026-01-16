---
name: fix-bug
description: Orchestrates disciplined bug fixing from diagnosis through verification. Infers severity and adapts approach - fast triage for critical bugs, scientific method for normal bugs. Prevents jumping to fixes and tracks context. Use when fixing any bug, error, or test failure.
---

# Fix Bug Workflow

## Invocation

User runs: `/fix-bug <description>`

Examples:
- `/fix-bug test_webhook_delivery failing with ConnectionResetError`
- `/fix-bug 500 error on /api/users endpoint in production`
- `/fix-bug TypeError: Cannot read property 'id' of undefined`

## Step 1: Analyze and Propose

1. Parse the bug description (error message, test name, symptoms)
2. Infer severity using rules in [SEVERITY-RULES.md](SEVERITY-RULES.md)
3. Create debug document from [DEBUG-TEMPLATE.md](DEBUG-TEMPLATE.md) at `docs/debug/YYYY-MM-DD-<issue>.md`
4. Present to user:
   - "**Bug:** [restate clearly]"
   - "**Severity:** [Critical/Normal/Minor]"
   - "**Approach:** [Fast Triage/Scientific Method]"
   - "Proceed?"

## Step 2: Execute Phases

Run phases based on severity. See [PHASES.md](PHASES.md).

**All severities start with Phase 0: Memory Check**

| Severity | Phases |
|----------|--------|
| Critical | Memory Check → Understand → Locate → Fix → Verify → Memory Capture |
| Normal | Memory Check → Reproduce → Hypothesize → Test → Fix → Verify → Memory Capture |
| Minor | Memory Check → Reproduce → Fix → Verify |

## Step 3: Context Tracking

After each phase:
1. Update debug document at `docs/debug/YYYY-MM-DD-<issue>.md`
2. Summarize "What we know so far" in chat

## Step 4: Commit

After verification passes:
1. Stage fix and test files
2. Generate commit message: `fix: <description>`
3. Reference debug doc in commit if complex

## Key Rules

- Never jump to fixing before confirming root cause (except Critical)
- Document every hypothesis tested and outcome
- No scope creep - fix only this bug
- Always add regression test before verification
- Always use TodoWrite to track progress through phases
- Always invoke skills via Skill tool, not by memory
