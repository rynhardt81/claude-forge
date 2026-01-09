#!/bin/bash
# validate-edit.sh
# PreToolUse hook to validate file edits
#
# Prevents editing sensitive files:
# - .env files (may contain secrets)
# - package-lock.json (should be auto-generated)
# - .git/ directory (internal git files)
#
# Exit codes:
# - 0: Allow the edit
# - 2: Block the edit (message shown to Claude)

# Read JSON input from stdin
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# If no file path, allow (not a file operation)
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Check for protected patterns
PROTECTED_PATTERNS=(
  ".env"
  ".env.local"
  ".env.production"
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
  ".git/"
  "node_modules/"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Protected file: Cannot edit '$pattern' files. These are either auto-generated or may contain secrets." >&2
    exit 2
  fi
done

# Allow the edit
exit 0
