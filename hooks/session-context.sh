#!/bin/bash
# session-context.sh
# SessionStart hook to provide minimal context
#
# Outputs compact status information to preserve context window:
# - Session status
# - Task registry status
# - Gate reminder
#
# Token-optimized: ~100 tokens max output

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

echo "=== FORGE ==="

# Session status
ACTIVE_SESSION=$(ls "$PROJECT_ROOT/.claude/memories/sessions/active/"session-*.md 2>/dev/null | head -1)
if [ -n "$ACTIVE_SESSION" ]; then
    SID=$(basename "$ACTIVE_SESSION" .md | sed 's/session-//')
    echo "S:$SID"
else
    echo "S:NONE"
fi

# Registry status
if [ -f "$PROJECT_ROOT/docs/tasks/registry.json" ]; then
    # Use jq if available for accurate counts, fallback to grep
    if command -v jq &>/dev/null; then
        STATS=$(jq -r '[.tasks[].status] | group_by(.) | map({(.[0]): length}) | add // {}' "$PROJECT_ROOT/docs/tasks/registry.json" 2>/dev/null)
        READY=$(echo "$STATS" | jq -r '.ready // 0')
        PROG=$(echo "$STATS" | jq -r '.in_progress // 0')
        DONE=$(echo "$STATS" | jq -r '.completed // 0')
        TOTAL=$(jq '.tasks | length' "$PROJECT_ROOT/docs/tasks/registry.json" 2>/dev/null)
    else
        READY=$(grep -c '"ready"' "$PROJECT_ROOT/docs/tasks/registry.json" 2>/dev/null || echo "?")
        PROG=$(grep -c '"in_progress"' "$PROJECT_ROOT/docs/tasks/registry.json" 2>/dev/null || echo "?")
        DONE=$(grep -c '"completed"' "$PROJECT_ROOT/docs/tasks/registry.json" 2>/dev/null || echo "?")
        TOTAL="?"
    fi
    echo "T:$DONE/$TOTAL|R$READY|A$PROG"
else
    echo "T:NONE"
fi

# Compact gate reminder
echo "G:s+r+t+sk+ag"
echo "==="
