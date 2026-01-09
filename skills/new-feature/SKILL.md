---
name: new-feature
description: Orchestrates full feature development workflow from discovery through commit. Infers scope from feature description and adapts phases accordingly. Use when adding any new feature, regardless of size.
---

# New Feature Workflow

## Invocation

User runs: `/new-feature <description>`

Example: `/new-feature add user preference settings to the portal`

## Step 1: Analyze and Propose

1. Analyze the feature description
2. Infer scope using rules in [SCOPE-RULES.md](SCOPE-RULES.md)
3. Present to user:
   - "**Feature:** [restate clearly]"
   - "**Inferred scope:** [small/medium/large]"
   - "**Recommended phases:** [list]"
   - "Proceed with this plan?"

## Step 2: Execute Phases

Run each phase sequentially. See [PHASES.md](PHASES.md) for detailed instructions.

| Scope | Phases |
|-------|--------|
| Small | Discovery → Planning → Implementation → Verification → Commit |
| Medium | Discovery → Design → Planning → Implementation → Verification → Review → Commit |
| Large | All phases with deeper analysis |

## Step 3: Checkpoint Protocol

After each phase, pause using prompts from [CHECKPOINTS.md](CHECKPOINTS.md).

User can: **continue** | **revise** | **skip phase** | **abort**

## Key Rules

- Always use TodoWrite to track progress through phases
- Always invoke skills via Skill tool, not by memory
- Always check for project-level agents before falling back to built-in
- Never skip verification phase
