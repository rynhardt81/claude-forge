# Refactor Type Inference Rules

## How to Determine Type

Analyze the refactor description against these indicators:

## Simple Refactor

**Nature:** Improve code without changing structure or performance characteristics

**Indicators:**
- Keywords: "rename", "extract", "inline", "simplify", "clean up", "reduce duplication", "improve readability"
- Single responsibility changes
- No file moves or new modules
- No interface changes

**Examples:**
- "Rename getUserData to fetchUserProfile"
- "Extract validation logic into helper method"
- "Remove duplicated error handling code"
- "Simplify nested conditionals in processOrder"

**Risk Level:** Low (1-2 files), Medium (3+ files)

**Verification:** Tests only

---

## Structural Refactor

**Nature:** Reorganize code architecture, move files, change module boundaries

**Indicators:**
- Keywords: "move", "reorganize", "split", "merge", "modularize", "extract service", "new module"
- File relocations
- New directories or modules
- Interface changes
- Import path updates across codebase

**Examples:**
- "Move webhook handlers to dedicated module"
- "Split UserService into UserService and ProfileService"
- "Reorganize routes into domain-based structure"
- "Extract shared utilities into common package"

**Risk Level:** Medium-High

**Verification:** Tests + manual verification checkpoint

---

## Performance Refactor

**Nature:** Optimize speed, memory, or resource usage

**Indicators:**
- Keywords: "optimize", "improve performance", "reduce latency", "cache", "batch", "lazy load", "reduce memory"
- Query optimization
- Algorithm improvements
- Caching additions
- Resource pooling

**Examples:**
- "Optimize database queries in ReportService"
- "Add caching to frequently accessed config"
- "Batch webhook deliveries instead of one-by-one"
- "Reduce memory usage in file processing"

**Risk Level:** Medium

**Verification:** Tests + benchmarks (before/after comparison)

---

## When Uncertain

Default to **Structural** - it requires the most verification, safest choice.

---

## Risk Assessment Matrix

| Refactor Type | Scope Size | Risk Level | Coverage Requirement |
|---------------|------------|------------|---------------------|
| Simple | 1-2 files | Low | Existing tests sufficient if passing |
| Simple | 3+ files | Medium | Verify tests cover changed code paths |
| Structural | Any | High | Full coverage of affected interfaces |
| Performance | Any | Medium | Tests + benchmark baseline required |
