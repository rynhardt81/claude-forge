# Content Merge Rules

This document defines the rules for merging content from `.claude_old/` into the new Claude Forge framework.

---

## Core Principles

1. **Never lose user data** - Project-specific content is always preserved
2. **Framework updates win** - Framework files use current versions
3. **Append, don't overwrite** - Historical data is appended, not replaced
4. **Ask when uncertain** - Unknown files prompt user decision
5. **Document everything** - All merge decisions are logged

---

## File Categories

### Category A: PRESERVE

Files that must be kept exactly as-is. These contain project-specific state that cannot be recreated.

| Pattern | Reason |
|---------|--------|
| `docs/prd.md` | Project requirements |
| `docs/tasks/registry.json` | Task state and progress |
| `docs/tasks/config.json` | Task configuration |
| `docs/epics/**/*.md` | Epic and task definitions |
| `features.db` | Feature database |
| `*.sqlite`, `*.db` | Any database files |

**Merge Rule:**
```python
def preserve(old_path, new_location):
    # Copy exactly as-is to new location
    shutil.copy2(old_path, new_location)
    log(f"Preserved: {old_path}")
```

### Category B: MERGE (Append)

Files where old content is appended to new content. Used for historical/log files.

| Pattern | Reason |
|---------|--------|
| `memories/progress-notes.md` | Session history (append-only) |
| `memories/sessions/completed/*` | Completed session files |

**Merge Rule:**
```python
def merge_append(old_path, new_path):
    # Read both files
    old_content = read_file(old_path)
    new_content = read_file(new_path) if exists(new_path) else ""

    # Create migration marker
    marker = f"""
---

## Pre-Migration History

> Content migrated from previous Claude configuration
> Migration date: {current_timestamp()}

"""

    # Append old content after marker
    combined = new_content + marker + old_content
    write_file(new_path, combined)
    log(f"Merged (append): {old_path}")
```

### Category C: MERGE (Preferences)

Files where values should be merged, with old values taking priority.

| Pattern | Reason |
|---------|--------|
| `memories/general.md` | Project preferences |
| `settings.local.json` | User settings |
| `security/allowed-commands.md` | Custom security rules |

**Merge Rule for general.md:**
```python
def merge_preferences(old_path, new_path):
    old_content = read_file(old_path)
    new_content = read_file(new_path) if exists(new_path) else ""

    # Parse sections from both
    old_sections = parse_markdown_sections(old_content)
    new_sections = parse_markdown_sections(new_content)

    # Merge: old values override new for same sections
    merged = {}
    for section in new_sections:
        merged[section] = new_sections[section]
    for section in old_sections:
        if old_sections[section].strip():  # Only if has content
            merged[section] = old_sections[section]

    # Add migration note
    merged["_migration_note"] = f"Merged preferences on {current_timestamp()}"

    write_file(new_path, render_sections(merged))
    log(f"Merged (preferences): {old_path}")
```

**Merge Rule for settings.local.json:**
```python
def merge_json_settings(old_path, new_path):
    old_settings = load_json(old_path)
    new_settings = load_json(new_path) if exists(new_path) else {}

    # Deep merge with old values taking priority
    merged = deep_merge(new_settings, old_settings)

    # Add migration metadata
    merged["_migrated_from"] = old_path
    merged["_migration_date"] = current_timestamp()

    write_json(new_path, merged)
    log(f"Merged (JSON): {old_path}")
```

### Category D: REPLACE

Files that should use the framework version. The old version is discarded.

| Pattern | Reason |
|---------|--------|
| `CLAUDE.md` | Framework instructions |
| `templates/**` | Document templates |
| `agents/**` | Agent personas |
| `skills/**` (framework) | Workflow skills |
| `mcp-servers/**` | MCP server code |
| `reference/*.template.md` | Template files |

**Merge Rule:**
```python
def replace(old_path, new_path):
    # Keep framework version, log that old was discarded
    log(f"Replaced: {old_path} (using framework version)")
    # Old file remains in .claude_old/ for reference
```

### Category E: ANALYZE

Files that need intelligent comparison to determine action.

| Pattern | Reason |
|---------|--------|
| `reference/*.md` (non-template) | May have project-specific content |

**Merge Rule:**
```python
def analyze_reference_doc(old_path, new_path):
    old_content = read_file(old_path)

    # Calculate how much is non-template content
    template_content = get_template_for(old_path)
    custom_lines = count_different_lines(old_content, template_content)

    if custom_lines > 100:
        # Substantial customization - preserve old
        shutil.copy2(old_path, new_path)
        log(f"Preserved (substantial content): {old_path}")
    elif custom_lines > 20:
        # Some customization - merge
        merge_reference_doc(old_content, template_content, new_path)
        log(f"Merged (partial content): {old_path}")
    else:
        # Mostly template - use new
        log(f"Replaced (minimal content): {old_path}")
```

### Category F: ASK

Files that don't match any known pattern. User must decide.

**Merge Rule:**
```python
def ask_user(old_path):
    preview = read_file(old_path, lines=10)
    size = get_file_size(old_path)

    display(f"""
    Unknown file: {old_path}
    Size: {size}
    Preview:
    ---
    {preview}
    ---

    Options:
    1. Keep in .claude/custom/
    2. Discard
    3. Show full content
    """)

    choice = get_user_input()

    if choice == 1:
        dest = f".claude/custom/{basename(old_path)}"
        shutil.copy2(old_path, dest)
        log(f"Preserved to custom: {old_path}")
    elif choice == 2:
        log(f"Discarded: {old_path}")
    elif choice == 3:
        display(read_file(old_path))
        return ask_user(old_path)  # Re-ask after showing
```

---

## Special Cases

### ADR Files

Architecture Decision Records are always preserved:

```python
def handle_adrs(old_claude_dir):
    # Check multiple locations
    adr_locations = [
        "reference/06-architecture-decisions.md",
        "docs/adr-*.md",
        "adrs/*.md",
    ]

    for pattern in adr_locations:
        for adr_file in glob(f"{old_claude_dir}/{pattern}"):
            # Preserve to consistent location
            dest = f".claude/reference/06-architecture-decisions.md"
            if exists(dest):
                # Append to existing
                append_adr(adr_file, dest)
            else:
                shutil.copy2(adr_file, dest)
```

### Custom Skills

Skills not in the framework are preserved:

```python
def handle_custom_skills(old_claude_dir):
    framework_skills = [
        "new-project", "reflect", "new-feature", "fix-bug",
        "refactor", "create-pr", "release", "implement-features", "pdf"
    ]

    for skill_dir in glob(f"{old_claude_dir}/skills/*/"):
        skill_name = basename(skill_dir)
        if skill_name not in framework_skills:
            # This is a custom skill
            dest = f".claude/skills/custom/{skill_name}"
            shutil.copytree(skill_dir, dest)
            log(f"Preserved custom skill: {skill_name}")
```

### Session Files

Sessions require special handling:

```python
def handle_sessions(old_claude_dir):
    # Active sessions should be reviewed - may be stale
    for session in glob(f"{old_claude_dir}/memories/sessions/active/*"):
        age = get_file_age(session)
        if age > timedelta(hours=24):
            warn(f"Stale active session found: {session}")
            # Move to completed with note
            add_note_to_session(session, "Migrated - was in active/ but stale")
            dest = f".claude/memories/sessions/completed/{basename(session)}"
            shutil.copy2(session, dest)
        else:
            # Recent active session - may be current
            warn(f"Recent active session found: {session}")
            # Keep in active but add migration note
            dest = f".claude/memories/sessions/active/{basename(session)}"
            shutil.copy2(session, dest)
            add_note_to_session(dest, "Migrated from previous framework")

    # Completed sessions just copy over
    for session in glob(f"{old_claude_dir}/memories/sessions/completed/*"):
        dest = f".claude/memories/sessions/completed/{basename(session)}"
        shutil.copy2(session, dest)
```

### Task Registry Validation

The task registry needs validation after migration:

```python
def validate_task_registry(registry_path):
    registry = load_json(registry_path)

    issues = []

    # Check for stale locks
    for task in registry.get("tasks", []):
        if task.get("status") == "in_progress":
            locked_since = task.get("locked_since")
            if locked_since and is_stale(locked_since, hours=24):
                issues.append({
                    "type": "stale_lock",
                    "task": task["id"],
                    "locked_since": locked_since
                })

    # Check for orphaned dependencies
    task_ids = {t["id"] for t in registry.get("tasks", [])}
    for task in registry.get("tasks", []):
        for dep in task.get("dependencies", []):
            if dep not in task_ids:
                issues.append({
                    "type": "orphaned_dependency",
                    "task": task["id"],
                    "missing_dep": dep
                })

    # Report issues
    if issues:
        display_issues(issues)
        choice = get_user_input("Fix these issues? [Y/n]")
        if choice != "n":
            fix_registry_issues(registry, issues)
            save_json(registry_path, registry)

    return len(issues) == 0
```

---

## Conflict Resolution

When files exist in both locations with different content:

### Same File, Different Content

```python
def resolve_conflict(old_path, new_path, category):
    if category in ["PRESERVE", "MERGE"]:
        # Old content wins or is merged
        return handle_by_category(category, old_path, new_path)

    elif category == "REPLACE":
        # New content wins
        return  # Framework version stays

    else:
        # Show diff and ask user
        display_diff(old_path, new_path)
        choice = get_user_input("""
        Which version should we use?
        1. Keep old version
        2. Use new version
        3. Merge manually
        """)
        return handle_choice(choice, old_path, new_path)
```

### Directory vs File Conflict

If old has a file where new has a directory (or vice versa):

```python
def resolve_type_conflict(old_path, new_path):
    old_is_file = os.path.isfile(old_path)
    new_is_file = os.path.isfile(new_path)

    if old_is_file and not new_is_file:
        # Old is file, new is directory
        # Save old file with special name
        dest = f"{new_path}/_migrated_{basename(old_path)}"
        shutil.copy2(old_path, dest)
        log(f"Type conflict: saved {old_path} as {dest}")

    elif not old_is_file and new_is_file:
        # Old is directory, new is file
        # This shouldn't happen with proper framework
        warn(f"Unusual type conflict at {old_path}")
        # Preserve old directory contents
        dest = f".claude/custom/_migrated_{basename(old_path)}"
        shutil.copytree(old_path, dest)
```

---

## Merge Order

Files are processed in this order to handle dependencies:

1. **Settings first** - May affect other processing
2. **Memories** - Provides context for decisions
3. **Project docs** - PRD, ADRs (needed for analysis)
4. **Task state** - Registry, epics, tasks
5. **Reference docs** - May reference project docs
6. **Custom content** - Unknown files last

```python
MERGE_ORDER = [
    # 1. Settings
    ("settings.local.json", "MERGE_JSON"),
    ("settings.json", "MERGE_JSON"),

    # 2. Memories
    ("memories/progress-notes.md", "MERGE_APPEND"),
    ("memories/general.md", "MERGE_PREFERENCES"),
    ("memories/sessions/**", "PRESERVE"),

    # 3. Project docs
    ("docs/prd.md", "PRESERVE"),
    ("reference/06-architecture-decisions.md", "PRESERVE"),
    ("docs/adr-*.md", "PRESERVE"),

    # 4. Task state
    ("docs/tasks/registry.json", "PRESERVE"),
    ("docs/tasks/config.json", "PRESERVE"),
    ("docs/epics/**", "PRESERVE"),

    # 5. Reference docs
    ("reference/*.md", "ANALYZE"),

    # 6. Security
    ("security/**", "MERGE_PREFERENCES"),

    # 7. Custom
    ("*", "ASK"),
]
```

---

## Logging

All merge decisions are logged to `migration-log.md`:

```markdown
# Migration Log

**Started:** 2024-01-15T10:30:00Z
**Completed:** 2024-01-15T10:35:00Z

## Actions Taken

| File | Action | Details |
|------|--------|---------|
| memories/progress-notes.md | MERGE_APPEND | Appended 2.3KB history |
| settings.local.json | MERGE_JSON | Preserved 5 settings |
| docs/prd.md | PRESERVE | Copied as-is (15KB) |
| templates/prd.md | REPLACE | Using framework version |
| custom-workflow.md | ASK → PRESERVE | User chose to keep |

## Conflicts Resolved

| File | Conflict Type | Resolution |
|------|---------------|------------|
| reference/01-system-overview.md | Content | Preserved (100+ custom lines) |

## Warnings

- Stale active session found: session-20240110-143022.md
- Task T005 has stale lock (48 hours)
```

---

## Recovery

If merge fails, original files are in `.claude_old/`:

```bash
# Manual recovery of specific file
cp .claude_old/path/to/file .claude/path/to/file

# Full restoration
./claude_restore.sh
```

All merge operations are designed to be idempotent - running migration twice produces the same result.
