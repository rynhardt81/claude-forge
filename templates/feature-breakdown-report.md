# Feature Breakdown Report: [Project Name]

**Generated:** YYYY-MM-DD HH:MM
**PRD Version:** [X.X.X]
**Agent:** @scrum-master
**Testing Mode:** [Standard | YOLO | Hybrid]

---

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Features | [X] |
| Total Epics | [X] |
| Estimated Complexity | [Simple | Medium | Complex] |
| Priority Distribution | P0: [X], P1: [X], P2: [X], P3: [X] |

---

## Breakdown by Category

| Code | Category | Count | % of Total | Priority Avg |
|------|----------|-------|------------|--------------|
| A | Security & Authentication | [X] | [X]% | [X.X] |
| B | Navigation & Routing | [X] | [X]% | [X.X] |
| C | Data Management (CRUD) | [X] | [X]% | [X.X] |
| D | Workflow & User Actions | [X] | [X]% | [X.X] |
| E | Forms & Input Validation | [X] | [X]% | [X.X] |
| F | Display & List Views | [X] | [X]% | [X.X] |
| G | Search & Filtering | [X] | [X]% | [X.X] |
| H | Notifications & Alerts | [X] | [X]% | [X.X] |
| I | Settings & Configuration | [X] | [X]% | [X.X] |
| J | Integration & APIs | [X] | [X]% | [X.X] |
| K | Analytics & Reporting | [X] | [X]% | [X.X] |
| L | Admin & Management | [X] | [X]% | [X.X] |
| M | Performance & Caching | [X] | [X]% | [X.X] |
| N | Accessibility (a11y) | [X] | [X]% | [X.X] |
| O | Error Handling | [X] | [X]% | [X.X] |
| P | Payment & Billing | [X] | [X]% | [X.X] |
| Q | Communication (Email/SMS) | [X] | [X]% | [X.X] |
| R | Media & File Handling | [X] | [X]% | [X.X] |
| S | Documentation & Help | [X] | [X]% | [X.X] |
| T | UI Polish & Animations | [X] | [X]% | [X.X] |
| **TOTAL** | | **[X]** | **100%** | |

---

## Breakdown by Epic

### Epic 1: [Epic Name]
**Story Count:** [X]
**Categories:** [A, B, C]

| ID | Feature Name | Category | Priority |
|----|--------------|----------|----------|
| 1 | [Feature name] | [Cat] | [P0-P3] |
| 2 | [Feature name] | [Cat] | [P0-P3] |
| 3 | [Feature name] | [Cat] | [P0-P3] |

---

### Epic 2: [Epic Name]
**Story Count:** [X]
**Categories:** [D, E, F]

| ID | Feature Name | Category | Priority |
|----|--------------|----------|----------|
| [X] | [Feature name] | [Cat] | [P0-P3] |
| [X] | [Feature name] | [Cat] | [P0-P3] |

---

### Epic 3: [Epic Name]
**Story Count:** [X]
**Categories:** [G, H]

| ID | Feature Name | Category | Priority |
|----|--------------|----------|----------|
| [X] | [Feature name] | [Cat] | [P0-P3] |
| [X] | [Feature name] | [Cat] | [P0-P3] |

---

## Testing Mode Configuration

### Selected Mode: [Standard | YOLO | Hybrid]

**Standard Mode Features:**
- Full browser automation testing
- Regression testing before each feature
- Screenshot verification

**YOLO Mode Features:**
- Lint + type-check only
- No browser automation
- Fast iteration

**Hybrid Mode Configuration:**
| Category | Test Type | Reason |
|----------|-----------|--------|
| A (Security) | Browser | Critical functionality |
| B (Navigation) | Lint only | Low risk |
| C (Data) | Browser | Data integrity |
| P (Payment) | Browser | Financial operations |
| T (UI Polish) | Lint only | Visual only |

---

## Implementation Order

### Phase 1: Foundation (Features 1-[X])
**Focus:** Core infrastructure, authentication, basic navigation

| Order | ID | Feature | Category | Rationale |
|-------|-----|---------|----------|-----------|
| 1 | [X] | [Name] | A | Security first |
| 2 | [X] | [Name] | A | Auth dependency |
| 3 | [X] | [Name] | B | Navigation setup |
| 4 | [X] | [Name] | B | Route structure |
| 5 | [X] | [Name] | C | Core data model |

### Phase 2: Core Features (Features [X]-[Y])
**Focus:** Primary user workflows, CRUD operations

| Order | ID | Feature | Category | Rationale |
|-------|-----|---------|----------|-----------|
| [X] | [X] | [Name] | [Cat] | [Reason] |
| [X] | [X] | [Name] | [Cat] | [Reason] |

### Phase 3: Enhanced Features (Features [Y]-[Z])
**Focus:** Search, filtering, notifications

| Order | ID | Feature | Category | Rationale |
|-------|-----|---------|----------|-----------|
| [X] | [X] | [Name] | [Cat] | [Reason] |

### Phase 4: Polish (Features [Z]-[Total])
**Focus:** UI polish, accessibility, documentation

| Order | ID | Feature | Category | Rationale |
|-------|-----|---------|----------|-----------|
| [X] | [X] | [Name] | [Cat] | [Reason] |

---

## Agent Routing Plan

Based on feature categories, features will be routed to:

| Category | Primary Agent | Secondary Agent |
|----------|---------------|-----------------|
| A (Security) | @security-boss | @developer |
| B (Navigation) | @developer | - |
| C (Data) | @developer | @api-tester |
| D (Workflow) | @developer | @quality-engineer |
| E (Forms) | @developer | @ux-designer |
| F (Display) | @developer | @whimsy |
| G (Search) | @developer | @performance-enhancer |
| H (Notifications) | @developer | - |
| I (Settings) | @developer | - |
| J (Integration) | @developer | @api-tester |
| K (Analytics) | @developer | @analyst |
| L (Admin) | @developer | @security-boss |
| M (Performance) | @performance-enhancer | @developer |
| N (Accessibility) | @developer | @quality-engineer |
| O (Error Handling) | @developer | - |
| P (Payment) | @security-boss | @developer |
| Q (Communication) | @developer | @api-tester |
| R (Media) | @developer | - |
| S (Documentation) | @developer | - |
| T (UI Polish) | @whimsy | @developer |

---

## Dependency Graph

```
[Feature 1: Auth]
    └──> [Feature 5: Protected Routes]
         └──> [Feature 10: User Dashboard]
              └──> [Feature 15: User Settings]

[Feature 2: Database Setup]
    └──> [Feature 6: CRUD Operations]
         └──> [Feature 11: Search]
         └──> [Feature 12: Filtering]
```

---

## Risk Assessment

### High-Risk Features
| ID | Feature | Risk | Mitigation |
|----|---------|------|------------|
| [X] | [Name] | [Risk description] | [Mitigation] |
| [X] | [Name] | [Risk description] | [Mitigation] |

### Integration Points
| Feature | External System | Risk Level |
|---------|-----------------|------------|
| [Name] | [System] | [H/M/L] |

---

## Checkpoint Schedule

Checkpoints will occur every 10 features:

| Checkpoint | After Feature | Expected Progress |
|------------|---------------|-------------------|
| 1 | 10 | [X]% complete |
| 2 | 20 | [X]% complete |
| 3 | 30 | [X]% complete |
| 4 | 40 | [X]% complete |
| 5 | 50 | [X]% complete |
| ... | ... | ... |

**At each checkpoint:**
- Display progress summary
- Show last 5 completed features
- Show next 5 pending features
- User can: Continue / Pause / Adjust priorities

---

## Estimation Summary

### By Complexity
| Complexity | Count | Avg Time | Total Time |
|------------|-------|----------|------------|
| Simple | [X] | ~2 min | [X] min |
| Medium | [X] | ~5 min | [X] min |
| Complex | [X] | ~10 min | [X] min |
| **Total** | **[X]** | | **[X] min** |

### By Testing Mode
| Mode | Features | Avg Time | Total Time |
|------|----------|----------|------------|
| Browser Test | [X] | ~8 min | [X] min |
| Lint Only | [X] | ~2 min | [X] min |

---

## Database Entry Preview

First 5 features as they will appear in the database:

```json
[
  {
    "id": 1,
    "priority": 1,
    "category": "A",
    "name": "[Feature Name]",
    "description": "[Description]",
    "steps": [
      "Step 1",
      "Step 2",
      "Step 3"
    ],
    "passes": false,
    "in_progress": false
  },
  {
    "id": 2,
    "priority": 2,
    "category": "A",
    "name": "[Feature Name]",
    "description": "[Description]",
    "steps": [
      "Step 1",
      "Step 2"
    ],
    "passes": false,
    "in_progress": false
  }
]
```

---

## Approval

**Breakdown Approved By:** [Name/Role]
**Date:** YYYY-MM-DD

**Ready to proceed with `/implement-features`:** [ ] Yes / [ ] No

---

## Notes

[Any additional context about the breakdown, special considerations, or instructions for implementation]

---

*Generated by @scrum-master as part of `/new-project` Phase 2*
