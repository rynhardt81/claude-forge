---
name: create-pr
description: Creates pull requests with smart defaults. Infers target branch from branch name, adapts description detail to PR size, and runs appropriate checks based on PR type (draft vs final). Use when ready to open a PR for review or early feedback.
---

# Create PR Workflow

## Invocation

User runs: `/create-pr` or `/create-pr --draft`

Examples:
- `/create-pr` - Create final PR with full checks
- `/create-pr --draft` - Create draft PR for early feedback

## Step 1: Analyze

1. Get current branch and commits since diverging from base
2. Calculate diff stats (files changed, lines added/removed)
3. Detect PR type (draft vs final)
4. Determine size (small/medium/large)
5. Present analysis for confirmation

## Step 2: Determine Target

1. Infer target branch using [BRANCH-RULES.md](BRANCH-RULES.md)
2. Confirm with user before proceeding

## Step 3: Run Checks

Run checks based on PR type. See [CHECKS.md](CHECKS.md).

| Type | Checks Required |
|------|-----------------|
| Draft | Tests only, warnings OK |
| Final | Tests + types + lint must pass |

## Step 4: Generate Description

Generate description based on size. See [TEMPLATES.md](TEMPLATES.md).

| Size | Criteria | Template |
|------|----------|----------|
| Small | 1-3 files, <100 lines | Title + 1 sentence |
| Medium | 4-10 files, 100-500 lines | Summary + bullet list |
| Large | 10+ files or 500+ lines | Full template with test plan |

## Step 5: Create PR

1. Push branch if not already pushed
2. Create PR via `gh pr create`
3. Present PR URL and post-PR checklist

## Key Rules

- Always confirm target branch before creating
- Never create final PR with failing checks (offer draft instead)
- Always include Claude Code attribution in description
- Extract and link related issues from branch/commits
