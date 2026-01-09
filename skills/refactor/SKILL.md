---
name: refactor
description: Orchestrates disciplined refactoring with scope boundaries and behavior verification. Infers refactor type and adapts verification approach. Prevents scope creep and ensures behavior unchanged. Use when improving code without changing functionality.
---

# Refactor Workflow

## Invocation

User runs: `/refactor <description>`

Examples:
- `/refactor extract validation logic from UserController into ValidationService`
- `/refactor move webhook handlers to dedicated module`
- `/refactor optimize database queries in ReportService`

## Step 1: Analyze and Propose

1. Parse the refactor description
2. Infer type using rules in [TYPE-RULES.md](TYPE-RULES.md)
3. Assess risk level
4. Present to user:
   - "**Refactor:** [restate clearly]"
   - "**Type:** [Simple/Structural/Performance]"
   - "**Risk:** [Low/Medium/High]"
   - "Proceed to define scope?"

## Step 2: Define Scope Boundary

Create scope document from [SCOPE-TEMPLATE.md](SCOPE-TEMPLATE.md) at `docs/refactors/YYYY-MM-DD-<refactor>.md`.

- List files in scope
- Explicitly list what's out of scope
- Define success criteria
- Get user approval on boundary

## Step 3: Execute Phases

Run phases sequentially. See [PHASES.md](PHASES.md).

| Phase | Purpose |
|-------|---------|
| Verify Coverage | Ensure adequate tests exist |
| Refactor | Make changes within scope |
| Verify | Confirm behavior unchanged |
| Commit | Commit with proper message |

## Key Rules

- Never modify out-of-scope files without checkpoint approval
- Always establish green test baseline before refactoring
- Run tests after each incremental change
- Log scope creep temptations, don't act on them
- No new functionality - refactoring only
- Always use TodoWrite to track progress
