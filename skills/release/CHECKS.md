# Pre-Release Checks

## Required Checks

All checks must pass before release proceeds.

| Check | Purpose |
|-------|---------|
| Tests | All tests pass |
| Types | No type errors |
| Lint | Code style OK |
| Clean | No uncommitted changes |
| Branch | On allowed branch |
| Remote | Branch up to date with remote |

## Check Commands

### Auto-detection

If no config, detect from project:

| File Present | Test Command |
|--------------|--------------|
| `Makefile` with `test` | `make test` |
| `package.json` with `test` | `npm test` |
| `pyproject.toml` | `pytest` |
| `Cargo.toml` | `cargo test` |
| `go.mod` | `go test ./...` |

| File Present | Lint Command |
|--------------|--------------|
| `.eslintrc*` | `npm run lint` |
| `pyproject.toml` (ruff) | `ruff check` |
| `Cargo.toml` | `cargo clippy` |

| File Present | Type Command |
|--------------|--------------|
| `tsconfig.json` | `npm run type-check` or `tsc --noEmit` |
| `mypy.ini` or `pyproject.toml` | `mypy` |

### Custom Commands

Via `.release-config.json`:
```json
{
  "checks": {
    "tests": "make test-all",
    "lint": "npm run lint && cd backend && ruff check",
    "types": "npm run type-check && mypy backend/app"
  }
}
```

## Branch Requirements

Default allowed branches:
- `main`
- `master`
- `release/*`

Override in config:
```json
{
  "allowed_branches": ["main", "release/*", "hotfix/*"]
}
```

## Clean Working Tree

Requirements:
- No staged changes
- No unstaged changes
- No untracked files in tracked directories

Check: `git status --porcelain` should be empty.

## Remote Sync

Requirements:
- Local branch not behind remote
- All commits pushed

Check:
```bash
git fetch origin
git status -uno  # Should show "up to date"
```

## Failure Handling

If any check fails:
1. Report which check(s) failed
2. Show relevant error output
3. Options: fix and retry, or abort

Never proceed with failing checks.

## Skipping Checks (Emergency)

For emergency hotfixes only:
`/release --skip-checks`

Requirements:
- Explicit confirmation required
- Warning added to release notes
- Skip logged in commit message

Prompt:
```
⚠️ You are about to release without running checks.
This is only for emergencies.

Type "I understand the risks" to proceed:
```

## Check Output

Show concise pass/fail for each:
```
Pre-release Checks:
✓ Tests: 142 passing
✓ Types: No errors
✓ Lint: No issues
✓ Working tree: Clean
✓ Branch: main (allowed)
✓ Remote: Up to date
```
