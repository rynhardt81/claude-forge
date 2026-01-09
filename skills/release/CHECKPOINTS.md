# Checkpoint Prompts

## After Analysis

```
**Release Analysis**

Current version: v1.2.3
Last release: 2024-12-15 (22 days ago)

**Commits since last release:** [N]
- [M] features (feat)
- [P] fixes (fix)
- [B] breaking changes

**Inferred bump:** [patch/minor/major] → v1.3.0

**Changelog preview:**

### Breaking Changes
- [entry if any]

### Added
- [entry 1]
- [entry 2]

### Fixed
- [entry 3]

Proceed with v1.3.0? (yes / change version / edit changelog / abort)
```

---

## After Checks - Pass

```
**Pre-release Checks**

- Tests: ✓ [N] passing
- Types: ✓ No errors
- Lint: ✓ No issues
- Working tree: ✓ Clean
- Branch: ✓ main
- Remote: ✓ Up to date

All checks pass. Proceed to update files? (yes / run again / abort)
```

---

## After Checks - Fail

```
**Pre-release Checks Failed**

- Tests: ✗ [N] failures
- Types: ✓ No errors
- Lint: ✗ [M] issues
- Working tree: ✓ Clean
- Branch: ✓ main
- Remote: ✓ Up to date

Cannot release with failing checks.

Fix issues and retry? (fix / abort)
```

---

## After File Updates

```
**Files Updated**

Version bumped: v1.2.3 → v1.3.0

Files modified:
- package.json (version field)
- CHANGELOG.md (new section added)

Commit created:
> chore(release): v1.3.0

Review changes? (show diff / proceed to tag / abort)
```

---

## After Tag

```
**Tag Created and Pushed**

Tag: v1.3.0 (annotated)
Commit: [short hash]
Remote: origin/main

Proceed to GitHub Release? (yes / skip to deployment / abort)
```

---

## After GitHub Release

```
**GitHub Release Created**

🔗 https://github.com/user/repo/releases/tag/v1.3.0

- Title: v1.3.0
- [N] changelog entries
- Pre-release: No
- Comparison: v1.2.3...v1.3.0

Proceed to deployment? (yes / skip / done)
```

---

## Deployment - Auto

```
**Deployment (Automatic)**

Mode: CI/CD triggered by tag

**Staging:**
- ✓ Deployment triggered
- Pipeline: [CI URL]
- Status: Running...

**Production:**
- ⏳ Awaiting staging success
- Auto-deploys after staging passes

Monitor? (open CI / done)
```

---

## Deployment - Manual

```
**Deployment Checklist**

Release v1.3.0 is ready for deployment.

## Pre-deployment
- [ ] Verify CI passed: [CI URL]
- [ ] Review staging deployment

## Production Deployment
- [ ] Announce maintenance window (if needed)
- [ ] Run deployment: `make deploy-prod`
- [ ] Verify health endpoint: /health
- [ ] Check error monitoring dashboard
- [ ] Monitor for 15 minutes

## Post-deployment
- [ ] Announce release completion
- [ ] Update status page (if applicable)

Mark complete as you go. Type 'done' when finished.
```

---

## Deployment - Hybrid

```
**Deployment Status**

**Staging:** ✓ Auto-deployed
- Pipeline: [CI URL]
- Status: Complete

**Production:** Manual deployment required

## Production Checklist
- [ ] Verify staging is healthy
- [ ] Run: `make deploy-prod`
- [ ] Verify health checks
- [ ] Monitor error rates

Proceed with checklist? (yes / done)
```

---

## Pre-release Confirmation

```
**Pre-release Version**

Type: beta
Current: v1.2.3
New: v1.3.0-beta.1

⚠️ Pre-release notes:
- Marked as pre-release on GitHub
- Not recommended for production
- Version will show as beta in package

Create v1.3.0-beta.1? (yes / change type / make stable / abort)
```

---

## Version Override

```
**Manual Version Entry**

Inferred version: v1.3.0 (minor)

Enter custom version (or 'back' to use inferred):
> _

Format: X.Y.Z or X.Y.Z-pre.N
```

---

## Edit Changelog

```
**Edit Changelog**

Current entries:

### Added
- Feature one (#123)
- Feature two (#124)

### Fixed
- Bug fix one (#125)

Edit options:
1. Add entry
2. Remove entry
3. Edit entry
4. Change category
5. Done editing

Choice? (1-5)
```

---

## Release Complete

```
**Release Complete** 🎉

Version: v1.3.0
Tag: v1.3.0
GitHub: https://github.com/user/repo/releases/tag/v1.3.0
Deployment: [status]

Summary:
- [N] new features
- [M] bug fixes
- [K] other changes

Next steps:
- Monitor deployment
- Announce release (if applicable)
- Start next development cycle
```

---

## User Response Handling

| Response | Action |
|----------|--------|
| yes / y | Proceed to next phase |
| change version | Prompt for manual version |
| edit changelog | Open changelog editor |
| show diff | Display git diff of changes |
| skip | Skip current phase, continue |
| fix | Exit to fix issues, retry later |
| done | Complete workflow |
| abort | Cancel release |
| open CI | Open CI URL in browser |
| back | Return to previous choice |
