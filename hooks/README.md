# Claude Code Hooks

This directory contains hook scripts for the Claude Forge framework.

## Overview

Hooks are shell scripts that execute in response to Claude Code events. They enable:
- Automatic code formatting after edits
- File protection for sensitive files
- Custom notifications
- Validation and enforcement

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

### validate-edit.sh

Validates file edits before they're made:
- Prevents editing `.env` files with secrets
- Blocks modifications to `package-lock.json`
- Protects `.git/` directory

### format-on-save.sh

Auto-formats code after Write/Edit operations:
- Runs Prettier for JS/TS files
- Runs Black for Python files
- Runs gofmt for Go files

### session-start.sh

Runs when a new session starts:
- Loads previous session context
- Checks for uncommitted changes
- Displays project status

## Setting Up Hooks

### Option 1: Use provided settings template

Copy the example settings file:

```bash
cp .claude/hooks/settings.example.json .claude/settings.local.json
```

### Option 2: Run /hooks command

Use Claude Code's built-in hook configuration:

```
/hooks
```

### Option 3: Manual configuration

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-edit.sh"
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

### Example: Custom Validation Hook

```bash
#!/bin/bash
# hooks/custom-validate.sh

# Read JSON input
INPUT=$(cat)

# Extract file path
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Block certain files
if [[ "$FILE_PATH" == *".env"* ]]; then
  echo "Cannot edit .env files - contains secrets" >&2
  exit 2
fi

exit 0
```

## Hook Events

| Event | When | Use Case |
|-------|------|----------|
| PreToolUse | Before tool executes | Validation, blocking |
| PostToolUse | After tool completes | Formatting, logging |
| Stop | When Claude stops | Cleanup, notifications |
| SessionStart | Session begins | Context loading |
| SessionEnd | Session ends | State saving |

## Security Considerations

- Always validate and sanitize input
- Use absolute paths
- Quote all variables
- Don't expose secrets in hook output
- Test hooks before enabling

## Disabling Hooks

To temporarily disable hooks, use `.claude/settings.local.json`:

```json
{
  "hooks": {}
}
```

Or remove the specific hook from the configuration.
