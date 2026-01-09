# Pre-PR Check Requirements

## Check Matrix

| PR Type | Tests | Type Check | Lint | Can Proceed on Fail |
|---------|-------|------------|------|---------------------|
| Draft | Run | Skip | Skip | Yes (with warning) |
| Final | Must pass | Must pass | Must pass | No |

## Check Commands

Detect from project configuration:

| Check | Detection | Fallback Command |
|-------|-----------|------------------|
| Tests | `package.json`, `Makefile`, `pytest.ini` | `make test-unit` |
| Type Check | `tsconfig.json`, `mypy.ini`, `pyproject.toml` | `npm run type-check` / `mypy app/` |
| Lint | `.eslintrc*`, `pyproject.toml`, `.ruff.toml` | `npm run lint` / `ruff check` |

## Project-Specific Commands

For this project (APIGateway):

| Check | Command |
|-------|---------|
| Backend tests | `make test-unit` |
| Backend types | `docker compose exec control-plane mypy app/` |
| Frontend tests | `cd frontend/admin-console && npm test` |
| Frontend types | `cd frontend/admin-console && npm run type-check` |
| Frontend lint | `cd frontend/admin-console && npm run lint` |

## Failure Handling

**Draft PR with failures:**
```
⚠️ Some checks failed, but proceeding with draft:
- Tests: [N] failures
- Types: skipped
- Lint: skipped

These should be fixed before marking ready for review.
```

**Final PR with failures:**
```
❌ Cannot create final PR with failing checks:
- Tests: [N] failures
- Type check: [M] errors
- Lint: [K] issues

Options:
1. Fix the issues and retry
2. Create as draft instead
3. Abort

Choice?
```

## Skipping Checks

If user explicitly requests: `/create-pr --skip-checks`

- Warn about risks
- Require confirmation
- Add note to PR description: "⚠️ Created without running checks"

## Check Order

Run checks in this order (fail fast):
1. Tests (most likely to fail)
2. Type check
3. Lint

Stop on first failure for Final PRs to save time.
