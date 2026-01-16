# Claude Forge Templates

This directory contains template files that are copied and customized when deploying the Claude Forge framework to a project.

## Available Templates

### Configuration Templates

| Template | Purpose | Deployed To |
|----------|---------|-------------|
| `settings.json` | Claude Code settings with hooks, permissions, MCP servers | `.claude/settings.json` |
| `config.json` | Project-specific Claude Forge configuration | `docs/tasks/config.json` |
| `.dispatch-config.json` | Intelligent dispatch system configuration | `.claude/memories/.dispatch-config.json` |

### Documentation Templates

| Template | Purpose | Deployed To |
|----------|---------|-------------|
| `CLAUDE.template.md` | Main framework instructions | `.claude/CLAUDE.md` |
| `prd.md` | Product Requirements Document template | `docs/prd.md` |
| `adr-template.md` | Architecture Decision Record template | Used inline |

### Session & Task Templates

| Template | Purpose | Deployed To |
|----------|---------|-------------|
| `session.md` | Session file template | `.claude/memories/sessions/active/` |
| `session-summary.md` | Session end summary template | Used inline |
| `progress-notes.md` | Progress notes initialization | `.claude/memories/progress-notes.md` |
| `task-registry.json` | Task registry initialization | `docs/tasks/registry.json` |
| `task.md` | Individual task file template | `docs/epics/*/tasks/` |

### Epic Templates

| Template | Purpose | Deployed To |
|----------|---------|-------------|
| `epic-full.md` | Full epic template with all sections | `docs/epics/E##-*/` |
| `epic-minimal.md` | Minimal epic template | `docs/epics/E##-*/` |
| `user-story.md` | User story template | Used inline |

### Feature Templates

| Template | Purpose | Deployed To |
|----------|---------|-------------|
| `feature-spec.md` | Feature specification template | Used inline |
| `feature-breakdown-report.md` | Feature breakdown summary | `docs/feature-breakdown.md` |

### Project Memory Templates

| Template | Purpose | Deployed To |
|----------|---------|-------------|
| `project-memory/bugs.md` | Bug pattern memory template | `docs/project-memory/bugs.md` |
| `project-memory/decisions.md` | Technical decision memory template | `docs/project-memory/decisions.md` |
| `project-memory/key-facts.md` | Key facts memory template | `docs/project-memory/key-facts.md` |
| `project-memory/patterns.md` | Code pattern memory template | `docs/project-memory/patterns.md` |

The project memory templates provide structured formats for capturing institutional knowledge that persists across sessions. See [reference/16-project-memory.md](../reference/16-project-memory.md) for full documentation.

### Review Templates

| Template | Purpose | Deployed To |
|----------|---------|-------------|
| `review-report.md` | Code review report template | Used inline |

---

## Settings Template Details

The `settings.json` template is the most important for framework enforcement. It includes:

### Hooks (Gate Enforcement)

```json
"hooks": {
  "PreToolUse": [...],  // Blocks code writes without session/registry
  "SessionStart": [...], // Shows status on session start
  "Stop": [...]          // Cleans up on session end
}
```

**Without hooks installed, framework gates are advisory only.**

### Permissions

Pre-approved commands for common development tasks:

- **Package managers:** npm, yarn, pnpm, pip, cargo, go, etc.
- **Build tools:** make, cmake, vite, tsc, etc.
- **Testing:** jest, pytest, playwright, cypress, etc.
- **Infrastructure:** docker, kubectl, terraform, etc.
- **Utilities:** git, curl, jq, grep, find, etc.

**Denied commands:** rm -rf /, sudo, passwd, systemctl, etc.

### MCP Servers

Pre-configured but disabled MCP servers:

- `feature-tracking`: Feature database management
- `browser-automation`: Playwright browser testing

Enable by removing `"disabled": true` when needed.

---

## Installation

### New Project

```bash
# /new-project skill handles this automatically
cp .claude/templates/settings.json .claude/settings.json
chmod +x .claude/hooks/*.sh
```

### Migration

```bash
# /migrate skill handles this, or manually:
cp .claude/templates/settings.json .claude/settings.json
# Merge existing permissions if needed
```

### Manual Installation

```bash
cd /path/to/project
cp .claude/templates/settings.json .claude/settings.json
chmod +x .claude/hooks/*.sh

# Verify hooks work
echo '{"tool_input":{"file_path":"test.js"}}' | bash .claude/hooks/gate-check.sh
# Should exit with code 2 and show GATE:BLOCKED
```

---

## Customization

### Adding Permissions

Edit the `allow` array in `settings.json`:

```json
"permissions": {
  "allow": [
    "Bash(your-command:*)",
    // ... existing permissions
  ]
}
```

### Disabling Hooks

To temporarily disable enforcement:

```json
"hooks": {}
```

Or remove specific hooks from the configuration.

### Enabling MCP Servers

Remove `"disabled": true` from the server config:

```json
"mcpServers": {
  "feature-tracking": {
    "command": "python",
    "args": ["-m", ".claude.mcp-servers.feature-tracking.server"],
    "env": {
      "PROJECT_DIR": "${CLAUDE_PROJECT_DIR}/.claude/features"
    }
    // "disabled": true  <- Remove this line
  }
}
```
