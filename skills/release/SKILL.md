---
name: release
description: Creates releases with semantic versioning, changelog generation, and deployment support. Infers version bump from conventional commits, runs checks, updates files, creates GitHub Release, and guides deployment. Use when ready to release a new version.
---

# Release Workflow

## Invocation

| Command | Purpose |
|---------|---------|
| `/release` | Infer version bump from commits |
| `/release patch` | Force patch release |
| `/release minor` | Force minor release |
| `/release major` | Force major release |
| `/release --pre beta` | Create beta pre-release |
| `/release --pre rc` | Create release candidate |
| `/release --pre alpha` | Create alpha pre-release |

## Workflow

1. **Analyze:** Get current version, parse commits, infer bump type
2. **Verify:** Run all checks (tests, lint, types), ensure clean state
3. **Update:** Bump version files, update CHANGELOG.md, commit
4. **Tag:** Create annotated tag, push to remote
5. **GitHub Release:** Create release with notes
6. **Deploy:** Auto-trigger or present checklist per config

## Version Bump Inference

See [COMMIT-PARSING.md](COMMIT-PARSING.md) for details.

| Signal | Bump |
|--------|------|
| `BREAKING CHANGE` or `!` | Major |
| `feat:` | Minor |
| `fix:`, `perf:`, etc. | Patch |

## File Detection

See [VERSION-DETECTION.md](VERSION-DETECTION.md) for supported files.

Auto-detects version files or uses `.release-config.json`.

## Changelog

See [CHANGELOG-FORMAT.md](CHANGELOG-FORMAT.md) for format.

- Updates CHANGELOG.md with categorized entries
- Creates GitHub Release notes from same content

## Checks

See [CHECKS.md](CHECKS.md) for requirements.

- Tests, lint, and type checks must pass
- Working tree must be clean
- Must be on allowed branch

## Configuration

Create `.release-config.json` in project root for:
- Custom version file locations
- Check commands
- Deployment mode and checklists
- GitHub Release options

If no config exists, skill auto-detects and prompts for confirmation.

## Pre-releases

Use `--pre <type>` for pre-releases:
- `/release --pre alpha` → 1.3.0-alpha.1
- `/release --pre beta` → 1.3.0-beta.1
- `/release --pre rc` → 1.3.0-rc.1

Subsequent pre-releases increment: beta.1 → beta.2 → beta.3

## Key Rules

- Never release with failing checks
- Never release with uncommitted changes
- Always confirm version bump before proceeding
- Always create annotated tags (not lightweight)
- Always update CHANGELOG.md before tagging
