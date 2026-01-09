# Version File Detection

## Detection Priority

1. Check `.release-config.json` for explicit `version_files`
2. Auto-detect from common project files
3. Prompt user if ambiguous or not found

## Supported Files

| File | Pattern | Language |
|------|---------|----------|
| `package.json` | `"version": "X.Y.Z"` | Node.js |
| `pyproject.toml` | `version = "X.Y.Z"` | Python |
| `setup.py` | `version="X.Y.Z"` | Python (legacy) |
| `setup.cfg` | `version = X.Y.Z` | Python |
| `VERSION` | `X.Y.Z` (plain text) | Any |
| `version.txt` | `X.Y.Z` (plain text) | Any |
| `Cargo.toml` | `version = "X.Y.Z"` | Rust |
| `build.gradle` | `version = 'X.Y.Z'` | Java/Kotlin |
| `pom.xml` | `<version>X.Y.Z</version>` | Java (Maven) |
| `mix.exs` | `version: "X.Y.Z"` | Elixir |
| `pubspec.yaml` | `version: X.Y.Z` | Dart/Flutter |

## Auto-detection Order

Search in this order, use first found:
1. `package.json`
2. `pyproject.toml`
3. `Cargo.toml`
4. `VERSION`
5. `setup.py`
6. Others...

## Multi-file Projects

Some projects have multiple version files:
- Monorepo: root + packages
- Full-stack: frontend + backend

Config example:
```json
{
  "version_files": [
    "package.json",
    "backend/pyproject.toml",
    "mobile/pubspec.yaml"
  ]
}
```

All files updated to same version.

## Update Methods

| File Type | Method |
|-----------|--------|
| JSON (package.json) | Parse, update, write with formatting |
| TOML (pyproject.toml) | Parse, update version field |
| Plain text (VERSION) | Overwrite entire file |
| Regex (setup.py) | Pattern replacement |

## Version Validation

Before proceeding, verify:
- Current version is valid semver
- No version files have conflicts (different versions)
- New version is greater than current (unless pre-release)

## Tag Detection

Find last release version from git tags:
```bash
git describe --tags --abbrev=0 --match "v*"
```

Tag formats supported:
- `v1.2.3` (recommended)
- `1.2.3`
- `release-1.2.3`
- `v1.2.3-beta.1` (pre-release)

## Handling Conflicts

If multiple version files have different versions:
1. Report the conflict
2. Ask which version to use as base
3. Update all files to same version
