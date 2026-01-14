# Claude Code Hooks

This directory contains hook scripts for the Claude Forge framework.

## Overview

Hooks are shell scripts that execute in response to Claude Code events. They enable:
- **Gate enforcement** - Block code writes until requirements are met
- **Token optimization** - Minimal output to preserve context window
- File protection for sensitive files
- Custom notifications and validation

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
T:5/20|R3|A1              # 5/20 done, 3 ready, 1 active (or NONE)
G:s+r+t+sk+ag             # Gates: session+registry+task+skill+agent
===
```

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

## Setting Up Hooks

### Option 1: Use provided settings template (Recommended)

Copy the example settings file to your project's `.claude/` directory:

```bash
cp hooks/settings.example.json .claude/settings.json
```

### Option 2: Manual configuration

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/hooks/gate-check.sh\"",
            "timeout": 5
          },
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/hooks/validate-edit.sh\"",
            "timeout": 5
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "type": "command",
        "command": "bash \"$CLAUDE_PROJECT_DIR/hooks/session-context.sh\"",
        "timeout": 5
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

| Event | When | Use Case |
|-------|------|----------|
| PreToolUse | Before tool executes | Gate enforcement, validation |
| PostToolUse | After tool completes | Formatting, logging |
| Stop | When Claude stops | Cleanup, notifications |
| SessionStart | Session begins | Minimal context loading |
| SessionEnd | Session ends | State saving |

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
