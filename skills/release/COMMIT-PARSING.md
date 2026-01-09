# Conventional Commit Parsing

## Format

```
<type>(<scope>)!: <description>

[optional body]

[optional footer(s)]
```

## Type Detection

| Type | Version Bump | Changelog Category |
|------|--------------|-------------------|
| `feat` | Minor | Added |
| `fix` | Patch | Fixed |
| `perf` | Patch | Changed |
| `refactor` | Patch | Changed |
| `docs` | None | (Excluded) |
| `style` | None | (Excluded) |
| `test` | None | (Excluded) |
| `chore` | None | (Excluded) |
| `ci` | None | (Excluded) |
| `build` | Patch | Changed |
| `revert` | Patch | Fixed |

## Breaking Change Detection

A commit is breaking if:
1. Type has `!` suffix: `feat!:` or `feat(scope)!:`
2. Footer contains `BREAKING CHANGE:`
3. Footer contains `BREAKING-CHANGE:`

Breaking changes always trigger **Major** bump (unless version < 1.0.0).

## Version Bump Priority

When multiple commits exist, use highest priority:
1. **Major** - Any breaking change
2. **Minor** - Any feature
3. **Patch** - Fixes, performance, refactors

## Scope Extraction

Optional scope in parentheses:
- `feat(auth):` → scope: auth
- `fix(api):` → scope: api
- `feat:` → scope: none

Scopes can be used to group changelog entries.

## Issue Reference Extraction

Look for patterns in description or body:
- `#123` → GitHub issue
- `fixes #123` → Closes issue
- `closes #123` → Closes issue
- `resolves #123` → Closes issue
- `JIRA-123` → Jira ticket (if configured)

## Examples

```
feat(webhooks): add retry configuration endpoint (#123)
→ Type: feat
→ Scope: webhooks
→ Bump: Minor
→ Category: Added
→ Entry: "Add retry configuration endpoint (#123)"

fix!: correct rate limit calculation
→ Type: fix
→ Breaking: yes
→ Bump: Major
→ Category: Breaking Changes
→ Entry: "Correct rate limit calculation"

chore: update dependencies
→ Type: chore
→ Bump: None
→ Excluded from changelog

feat: add dark mode support

BREAKING CHANGE: Theme API has changed
→ Type: feat
→ Breaking: yes (from footer)
→ Bump: Major
→ Categories: Breaking Changes + Added
```

## Commits to Skip

- Merge commits: `Merge branch...`, `Merge pull request...`
- Release commits: `chore(release):`, `release:`
- Revert of release: `Revert "chore(release)..."`
- WIP commits: `wip:`, `WIP:`

## Non-conventional Commits

If commit doesn't follow convention:
1. Include in "Other" or "Miscellaneous" section
2. Or skip with warning
3. Configurable behavior

## Getting Commits

```bash
# Get commits since last tag
git log v1.2.3..HEAD --pretty=format:"%s|%b|%H" --no-merges
```
