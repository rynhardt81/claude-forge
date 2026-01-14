#!/bin/bash
# gate-check.sh
# PreToolUse hook to enforce Claude Forge gates
#
# Validates that required gates are passed before allowing code writes:
# - Gate 1: Session must be active
# - Gate 2: Registry with epics/tasks must exist
#
# Exit codes:
# - 0: Gates passed, allow the operation
# - 2: Gate failed, block the operation (message shown to Claude)
#
# Token-optimized: Outputs minimal text to preserve context window

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# Read JSON input from stdin
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# If no file path, allow (not a file operation)
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Exception: Framework files in .claude/ or hooks/ can be edited without full gates
# This allows framework maintenance and initial setup
if [[ "$FILE_PATH" == *".claude/"* ]] || [[ "$FILE_PATH" == *"/hooks/"* ]] || [[ "$FILE_PATH" == *"CLAUDE.md"* ]]; then
    exit 0
fi

# Gate 1: Check for active session
check_session() {
    if ls "$PROJECT_ROOT/.claude/memories/sessions/active/"session-*.md 1>/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Gate 2: Check for registry with tasks
check_registry() {
    if [ -f "$PROJECT_ROOT/docs/tasks/registry.json" ]; then
        # Verify it's not empty (has at least one task)
        if grep -q '"tasks"' "$PROJECT_ROOT/docs/tasks/registry.json" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Run gate checks
FAILED=""

if ! check_session; then
    FAILED="${FAILED}1"
fi

if ! check_registry; then
    FAILED="${FAILED}2"
fi

# If any gates failed, block with minimal output
if [ -n "$FAILED" ]; then
    echo "GATE:BLOCKED[$FAILED]" >&2
    if [[ "$FAILED" == *"1"* ]]; then
        echo "->Session required" >&2
    fi
    if [[ "$FAILED" == *"2"* ]]; then
        echo "->Run /new-project first" >&2
    fi
    exit 2
fi

# All gates passed
exit 0
