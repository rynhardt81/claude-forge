# Branch Inference Rules

## Target Branch Inference

| Branch Pattern | Inferred Target | Rationale |
|----------------|-----------------|-----------|
| `feature/*`, `feat/*` | `main` | New features go to main |
| `fix/*`, `bugfix/*` | `main` | Bug fixes go to main |
| `hotfix/*` | Latest `release/*` or `main` | Hotfixes target release if exists |
| `refactor/*` | `main` | Refactors go to main |
| `docs/*` | `main` | Documentation goes to main |
| `release/*` | `main` | Release branches merge to main |
| `chore/*` | `main` | Maintenance goes to main |
| `dependabot/*` | `main` | Dependency updates go to main |
| Other | `main` | Default to main |

## Draft Detection

| Signal | Result |
|--------|--------|
| `--draft` flag passed | Create as Draft |
| Branch contains `wip`, `draft`, `poc` | Suggest Draft |
| Commit messages contain "WIP" | Suggest Draft |
| Otherwise | Create as Final |

## Issue Extraction

Look for issue references in:

1. **Branch name:** `feature/123-description` → #123
2. **Commit messages:** `fixes #456`, `closes #789`
3. **Keywords:** closes, fixes, resolves, implements + #number

## Remote Branch Handling

1. Check if branch exists on remote: `git ls-remote --heads origin <branch>`
2. If not pushed: push with `-u` flag before PR
3. If pushed: verify up-to-date with remote

## Title Generation

Format: `<type>: <description>`

| Branch Pattern | Type Prefix |
|----------------|-------------|
| `feature/*`, `feat/*` | `feat` |
| `fix/*`, `bugfix/*` | `fix` |
| `refactor/*` | `refactor` |
| `docs/*` | `docs` |
| `chore/*` | `chore` |
| `hotfix/*` | `fix` |
| Other | Infer from commits |
