# Claude Code Hooks

This directory contains hook scripts for the Claude Forge framework.

## Overview

Hooks are shell scripts that execute in response to Claude Code events. They enable:
- **Gate enforcement** - Block code writes until requirements are met
- **Token optimization** - Minimal output to preserve context window
- File protection for sensitive files
- Custom notifications and validation

**CRITICAL:** Without hooks installed, the framework's gates are ADVISORY ONLY. Claude can bypass session and task requirements. Hooks make enforcement MANDATORY.

## Installation (REQUIRED)

When the framework is deployed to a target project, hooks MUST be installed:

```bash
# 1. Make hooks executable
chmod +x .claude/hooks/*.sh

# 2. Create settings.json from comprehensive template
# (includes hooks, permissions, and MCP server configs)
cp .claude/templates/settings.json .claude/settings.json

# Or use hooks-only template:
# cp .claude/hooks/settings.example.json .claude/settings.json

# 3. Verify hooks are working (should return exit code 2)
echo '{"tool_input":{"file_path":"test.js"}}' | bash .claude/hooks/gate-check.sh
# Expected: Exit 2, "GATE:BLOCKED[12]" (no session, no registry)
```

**The `/new-project` and `/migrate` skills do this automatically.** If hooks aren't working, install manually using the steps above.

## Settings Templates

Two templates are available:

| Template | Location | Contents |
|----------|----------|----------|
| **Comprehensive** | `templates/settings.json` | Hooks + Permissions + MCP servers |
| **Hooks-only** | `hooks/settings.example.json` | Hooks + Framework permissions |

The comprehensive template is recommended for most projects.

## Framework Permissions

Both templates include permissions that allow Claude to manage framework files without prompting:

```json
"permissions": {
  "allow": [
    "Read(.claude/**)",
    "Edit(.claude/**)",
    "Write(.claude/**)",
    "Read(docs/tasks/**)",
    "Edit(docs/tasks/**)",
    "Write(docs/tasks/**)",
    "Read(docs/epics/**)",
    "Read(docs/project-memory/**)",
    "Edit(docs/project-memory/**)"
  ]
}
```

This allows:
- **`.claude/**`** - Full read/write for session files, memories, configs
- **`docs/tasks/**`** - Full read/write for task registry and task files
- **`docs/epics/**`** - Read access for epic definitions
- **`docs/project-memory/**`** - Read/write for project memory files

Without these permissions, Claude will prompt for access when running `/reflect resume` or managing sessions.

## Hook Configuration

Hooks are configured in `.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Stop": [...]
  }
}
```

## Available Hooks

### gate-check.sh (CRITICAL - Gate Enforcement)

**Token-optimized gate enforcement hook.** Blocks code writes until gates pass:
- Gate 1: Active session must exist
- Gate 2: Task registry must exist with tasks

Output is minimal (~50 tokens) to preserve context window:
```
GATE:BLOCKED[12]
->Session required
->Run /new-project first
```

Exceptions: Framework files (.claude/, hooks/, CLAUDE.md) bypass gates.

### session-context.sh (CRITICAL - Token Optimized)

**Token-optimized session start hook.** Provides compact status (~100 tokens max):
```
=== FORGE ===
S:20240115-143022-a7x9    # Session ID (or NONE)
P3:INCOMPLETE E2/5 T8/20  # Phase 3 incomplete (if applicable)
->Resume Phase 3: Read .claude/memories/phase3-progress.json
T:5/20|R3|A1              # 5/20 done, 3 ready, 1 active (or NONE)
G:s+r+t+sk+ag             # Gates: session+registry+task+skill+agent
===
```

**Phase 3 Detection:** If `/new-project` was interrupted during epic/task creation, this hook detects the incomplete state and reminds to resume.

### validate-edit.sh

Validates file edits before they're made:
- Prevents editing `.env` files with secrets
- Blocks modifications to `package-lock.json`
- Protects `.git/` directory

### session-end.sh

Runs when session ends:
- Updates session file status
- Moves session to completed/
- Appends to progress notes

### pre-compact.sh (Context Preservation)

**Saves session state before context compaction.** Triggered when:
- **Auto**: Context window is full and auto-compact runs
- **Manual**: User runs `/compact` command

Actions prompted:
- Save current work state to session file
- Append pre-compact snapshot to progress notes
- Add continuation context to task registry
- Commit any safe-to-commit changes as WIP checkpoint

Output:
```
PRE-COMPACT: Before context is compacted, you MUST save critical state.
COMPACT-TRIGGER: AUTO (context window full)
ACTION: Save state immediately - compaction is imminent
```

## Setting Up Hooks

### Option 1: Use provided settings template (Recommended)

Copy the example settings file to your project's `.claude/` directory:

```bash
cp .claude/hooks/settings.example.json .claude/settings.json
```

### Option 2: Manual configuration

Add to `.claude/settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/gate-check.sh\"",
            "timeout": 5
          },
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/validate-edit.sh\"",
            "timeout": 5
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/session-context.sh\"",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

## Creating Custom Hooks

### Hook Input

Hooks receive JSON via stdin:

```json
{
  "session_id": "abc123",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.js",
    "content": "..."
  }
}
```

### Hook Output

- **Exit 0**: Success (continue)
- **Exit 2**: Block the operation (stderr shown to Claude)
- **Other**: Warning (stderr shown to user)

### Token Optimization Best Practices

When creating hooks, minimize output to preserve context window:

```bash
# BAD - Verbose output wastes tokens
echo "Gate check complete. Session found at /path/to/session-abc123.md. Registry contains 45 tasks."

# GOOD - Compact output
echo "GATE:OK"

# BAD - Long error messages
echo "Error: No active session found. Please create a session file in .claude/memories/sessions/active/ before proceeding with code modifications."

# GOOD - Compact errors
echo "GATE:BLOCKED[1]"
echo "->Session required"
```

## Hook Events

| Event | When | Matcher Values | Use Case |
|-------|------|----------------|----------|
| PreToolUse | Before tool executes | Tool names (`Edit`, `Write`, `Bash`) | Gate enforcement, validation |
| PostToolUse | After tool completes | Tool names | Formatting, logging |
| PermissionRequest | Permission dialog shown | Tool names | Custom permission handling |
| UserPromptSubmit | User submits prompt | None | Input validation |
| Notification | Notification sent | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` | Custom notifications |
| Stop | When Claude stops | `*` | Cleanup, session archiving |
| SubagentStop | When subagent finishes | `*` | Subagent cleanup |
| PreCompact | Before context compaction | `auto`, `manual` | **State preservation** |
| SessionStart | Session begins | `startup`, `resume`, `clear`, `compact` | Context loading |
| SessionEnd | Session terminates | None | Final state saving |

## Gate Enforcement

The `gate-check.sh` hook enforces the framework's mandatory gates:

| Gate | Check | Block Message |
|------|-------|---------------|
| 1 | Session exists in active/ | `->Session required` |
| 2 | Registry exists with tasks | `->Run /new-project first` |

Gates 3-5 (task assignment, skill invocation, agent delegation) are enforced by the framework documentation in CLAUDE.md, not hooks.

## Security Considerations

- Always validate and sanitize input
- Use absolute paths via `$CLAUDE_PROJECT_DIR`
- Quote all variables
- Don't expose secrets in hook output
- Test hooks before enabling
- Keep output minimal for security and tokens

## Disabling Hooks

To temporarily disable hooks, use `.claude/settings.local.json`:

```json
{
  "hooks": {}
}
```

Or remove the specific hook from the configuration.
