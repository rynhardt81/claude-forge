# 00-documentation-governance.md

**Documentation Governance & Source-of-Truth Contract**

> **Audience:** Claude Code, architects, senior engineers
> **Authority:** **Highest** – governs *all* documentation
> **Purpose:** Define how documentation is created, updated, referenced, and trusted

---

## 1. Purpose of This Document

This document defines the **governance rules** for all documentation in this repository.

It establishes:

* What documents are authoritative
* How documentation may be created or modified
* How supporting documentation is processed and referenced
* How Claude and humans must resolve conflicts

📌 **This is the highest-authority documentation file.**
All other documents must comply with it.

---

## 2. Documentation Authority Model

Documentation in this repository is divided into **four tiers**:

### Tier 1 — Governance

* `00-documentation-governance.md` (**this document**)

### Tier 2 — Master Source-of-Truth Documents

* `01-system-overview.md`
* `02-architecture-and-tech-stack.md`
* `03-security-auth-and-access.md`
* `04-development-standards-and-structure.md`
* `05-operational-and-lifecycle.md`
* `06-architecture-decisions.md`
* `07-non-functional-requirements.md`

These documents define the **authoritative truth** of the system.

### Tier 3 — Processed Supporting Documentation

* `docs/processed/`

These documents:

* Provide evidence or background
* Are **read-only**
* Must be explicitly referenced by master documents

### Tier 4 — Execution & Raw Documentation

* `CLAUDE.md`
* `.claude/*`
* Inline comments, notes, drafts

These guide execution but **do not define truth**.

---

## 3. Master Document Rules

All master documents (01–07) must:

* Follow this governance file
* Declare their **persona**
* Declare their **scope and non-goals**
* Avoid duplicating content from other master documents
* Reference supporting documents instead of embedding them
* Remain concise and stable

Master documents are **living documents**, but changes must be:

* Intentional
* Traceable
* Consistent with persona and scope

---

## 4. Docs Folder Processing Rules

### `docs/` (Active Source Pool)

* Contains unprocessed documentation
* May be scanned for information
* Documents here are **eligible for use**

### `docs/processed/` (Evidence Archive)

* Contains documentation already used
* Must **not** be re-processed automatically
* May only be consulted when explicitly referenced
* Organized by category (e.g., `architecture/`, `business/`, `operations/`)

### Processing Rules

When a document is used by a master document:

1. Relevant sections are extracted
2. The document path and sections are recorded in the master document's reference table
3. The document is moved to `docs/processed/` (preserving folder structure)
4. The master document references it explicitly using the format below

Unused or obsolete documents in `docs/`:

* Should be flagged for review
* May be removed after user confirmation
* Deletion prevents documentation bloat and confusion

### Reference Format Standard

Master documents must reference processed docs using this table format:

```markdown
| Source Document | Sections Used | Summary |
|-----------------|---------------|---------|
| `architecture/system-overview.md` | §2, §3.1 | High-level components, key characteristics |
```

**Rules:**
* Path is relative to `docs/processed/`
* Sections identify specific headings or numbered sections used
* Summary is a brief (5-15 word) description of extracted content
* Same processed doc MAY be referenced by multiple master documents
* Each master records only the sections IT uses (no duplication of content)

### Multi-Document Content

When a processed document contains content relevant to multiple master documents:

* The document is moved to `docs/processed/` on **first use**
* Each master document references the **specific sections** it uses
* No content is duplicated between master documents
* The processed doc serves as the **detailed drill-down** for all referencing masters

---

## 5. Modification & Evolution Rules

Claude **is allowed** to:

* Read master documents
* Append to master documents
* Modify master documents

Claude **must not**:

* Delete master documents
* Change a document's authority level
* Remove governance constraints
* Rewrite intent without explicit justification

All modifications must:

* Respect the document's persona
* Stay within declared scope
* Preserve intent unless explicitly superseded
* Be traceable (what changed and why)

---

## 5a. Change Workflow for Ongoing Maintenance

When new features, changes, or updates occur, documentation must flow through the established structure:

### New Feature/Change Workflow

```
1. Create detailed documentation
   └── Write in docs/ (active source pool)

2. Identify affected master documents
   └── Determine which 01-07 docs need updates

3. Extract relevant content to master docs
   └── Summarize within persona constraints
   └── Add to appropriate sections

4. Move detailed doc to processed
   └── Move to docs/processed/{category}/
   └── Preserve folder structure

5. Update references
   └── Add to master doc reference table
   └── Record sections used
```

### Triggering Events

Documentation updates are triggered by:

| Event | Action Required |
|-------|-----------------|
| New feature implementation | Create detailed doc → extract to masters |
| Architecture change | Update 02, possibly 06 (ADR) |
| Security change | Update 03, create security review |
| New operational procedure | Update 05, create runbook |
| Performance optimization | Update 07, record metrics |
| Bug fix with design impact | Update relevant master + 06 if decision made |

### Document Lifecycle States

| State | Location | Action |
|-------|----------|--------|
| Draft | `docs/` | Being written, not yet processed |
| Active | `docs/` | Ready for processing |
| Processed | `docs/processed/` | Extracted to master docs, read-only |
| Archived | `docs/archived/` | Historical, no longer referenced |

### Version Bumping

When master documents are updated:

* **Patch** (x.x.1): Clarifications, typo fixes, reference updates
* **Minor** (x.1.0): New sections, expanded content, new references
* **Major** (1.0.0): Structural changes, scope changes, breaking updates

---

## 6. Personas & Scope Enforcement

Each master document declares:

* A **primary persona**
* Optional **secondary personas**
* Persona-specific constraints

Claude must:

* Reason using the declared persona(s)
* Avoid drifting into other domains
* Defer to other master documents where scope overlaps

---

## 7. Step-by-Step Execution Rule

Claude must process documentation **sequentially**, never all at once:

1. Read this governance document
2. Process one master document at a time
3. Complete all phases (scan → analysis → draft → handoff)
4. Stop before moving to the next document

This prevents scope bleed and architectural drift.

---

## 8. Conflict Resolution

When conflicts arise:

1. `00-documentation-governance.md` wins
2. Relevant master document wins
3. Referenced processed documentation wins
4. Execution guidance (`CLAUDE.md`) loses

If conflicts exist between master documents:

* They must be recorded in `06-architecture-decisions.md`
* Or explicitly resolved with user input

---

## 9. Machine-Enforceable Governance Rules (JSON)

> **All tools and agents must obey the following rules exactly.**

```json
{
  "document_id": "00-documentation-governance",
  "document_type": "governance_contract",
  "authority_level": "highest",
  "version": "2.3.0",

  "governs": [
    "CLAUDE.md",
    "01-system-overview.md",
    "02-architecture-and-tech-stack.md",
    "03-security-auth-and-access.md",
    "04-development-standards-and-structure.md",
    "05-operational-and-lifecycle.md",
    "06-architecture-decisions.md",
    "07-non-functional-requirements.md"
  ],

  "documentation_tiers": {
    "tier_1": "governance",
    "tier_2": "master_source_of_truth",
    "tier_3": "processed_supporting_docs",
    "tier_4": "execution_and_raw_docs"
  },

  "master_document_rules": {
    "must_define_persona": true,
    "must_define_scope": true,
    "must_define_non_goals": true,
    "must_reference_supporting_docs": true,
    "duplication_forbidden": true
  },

  "docs_processing_rules": {
    "active_docs_path": "docs/",
    "processed_docs_path": "docs/processed/",
    "preserve_folder_structure": true,
    "reuse_policy": "forbidden_without_explicit_reference",
    "multi_doc_policy": "same_doc_may_be_referenced_by_multiple_masters",
    "unused_docs_policy": "flag_for_review_then_delete"
  },

  "reference_format": {
    "table_columns": ["Source Document", "Sections Used", "Summary"],
    "path_format": "relative_to_docs_processed",
    "section_format": "heading_or_number",
    "summary_length": "5-15 words"
  },

  "allowed_modifications": {
    "master_documents": [
      "read",
      "append",
      "modify"
    ],
    "constraints": [
      "persona_must_be_respected",
      "scope_must_not_be_exceeded",
      "intent_must_be_preserved_or_explicitly_superseded",
      "changes_must_be_traceable"
    ]
  },

  "execution_rules": {
    "step_by_step_only": true,
    "parallel_processing": false,
    "halt_on_critical_assumptions": true
  },

  "change_workflow": {
    "new_content_location": "docs/",
    "processed_location": "docs/processed/",
    "archived_location": "docs/archived/",
    "workflow_steps": [
      "create_detailed_doc_in_docs",
      "identify_affected_master_docs",
      "extract_to_masters_within_persona",
      "move_to_processed",
      "update_references"
    ],
    "version_bump_rules": {
      "patch": "clarifications, typos, reference updates",
      "minor": "new sections, expanded content",
      "major": "structural changes, scope changes"
    }
  },

  "conflict_resolution": {
    "precedence_order": [
      "governance",
      "master_documents",
      "processed_docs",
      "execution_guidance"
    ]
  }
}
```

---

## 10. Final Statement

This governance model ensures that:

* Documentation remains authoritative and coherent
* Architectural knowledge is preserved
* Claude can safely evolve documentation
* Humans and AI share a single source of truth

**All documentation work begins here.**

---
