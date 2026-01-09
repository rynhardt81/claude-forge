# Changelog Format

## File Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [X.Y.Z] - YYYY-MM-DD

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
### Breaking Changes
```

## Section Order

1. Breaking Changes (if any) - always first for visibility
2. Added
3. Changed
4. Deprecated
5. Removed
6. Fixed
7. Security

Only include sections that have entries.

## Entry Format

```markdown
- Description of change (#123)
```

- Start with capital letter
- No period at end
- Include issue/PR reference if available
- Keep concise (one line preferred)

## Categorization from Commits

| Commit Prefix | Category |
|---------------|----------|
| `feat:` | Added |
| `fix:` | Fixed |
| `change:`, `refactor:` | Changed |
| `deprecate:` | Deprecated |
| `remove:` | Removed |
| `security:` | Security |
| `BREAKING CHANGE` | Breaking Changes |
| `perf:` | Changed |

## Excluded from Changelog

- `docs:` - Documentation only
- `chore:` - Maintenance
- `ci:` - CI changes
- `test:` - Test only
- `style:` - Formatting only

Can be overridden in config if needed.

## Grouping by Scope

If many changes, optionally group by scope:

```markdown
### Added

**API**
- New endpoint for user preferences (#123)
- Support for bulk operations (#124)

**UI**
- Dark mode toggle in settings (#125)
```

## Version Links

At bottom of file, include comparison links:

```markdown
[Unreleased]: https://github.com/user/repo/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/user/repo/compare/v1.2.3...v1.3.0
[1.2.3]: https://github.com/user/repo/compare/v1.2.2...v1.2.3
```

## Pre-release Entries

```markdown
## [1.3.0-beta.2] - 2025-01-06

### Added
- Feature in beta testing (#130)

## [1.3.0-beta.1] - 2025-01-04

### Added
- Initial beta feature (#129)
```

## GitHub Release Notes

Same content as changelog section, formatted for GitHub:
- Issue numbers become clickable links
- Include comparison link to previous version
- Optionally include contributor mentions
- Mark as pre-release if applicable
