# MCP Servers

This directory contains Model Context Protocol (MCP) server implementations for the base-claude framework.

---

## Overview

MCP servers provide tool interfaces that Claude can use during autonomous development. These servers run as separate processes and communicate via the MCP protocol.

### Available Servers

| Server | Purpose | Required For |
|--------|---------|--------------|
| `feature-tracking` | Feature database management | `/new-project`, `/implement-features` |
| `browser-automation` | Playwright browser testing | Standard/Hybrid testing modes |

---

## Startup Mode: Hybrid (On-Demand)

MCP servers start **on-demand** when skills require them:

```
User runs /new-project
    ↓
Phase 4: Check if feature-tracking MCP is running
    ↓
If not running → Start MCP server
    ↓
Continue with feature creation
```

**Benefits:**
- No wasted resources when not doing autonomous development
- Self-contained - skills handle their own dependencies
- No manual setup required for users

---

## Quick Start

### Feature Tracking Server

```bash
# Navigate to feature-tracking directory
cd mcp-servers/feature-tracking

# Install dependencies (first time only)
pip install -r requirements.txt

# Start the server
python server.py
```

**Environment Variables:**
```bash
# Set the project directory (where features.db will be created)
export PROJECT_DIR="/path/to/project/.claude/features"
```

### Browser Automation Server

See `browser-automation/README.md` for Playwright MCP setup instructions.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Claude Code                           │
│                                                         │
│  ┌─────────────────┐    ┌─────────────────────────────┐ │
│  │ /new-project    │    │ /implement-features         │ │
│  │ skill           │    │ skill                       │ │
│  └────────┬────────┘    └──────────────┬──────────────┘ │
│           │                            │                │
└───────────┼────────────────────────────┼────────────────┘
            │                            │
            ▼                            ▼
┌───────────────────────┐    ┌───────────────────────────┐
│ Feature Tracking MCP  │    │ Browser Automation MCP    │
│                       │    │ (Playwright)              │
│ Tools:                │    │                           │
│ - feature_get_stats   │    │ Tools:                    │
│ - feature_get_next    │    │ - navigate                │
│ - feature_create_bulk │    │ - click                   │
│ - feature_mark_passing│    │ - type                    │
│ - ...                 │    │ - screenshot              │
└───────────┬───────────┘    └─────────────┬─────────────┘
            │                              │
            ▼                              ▼
┌───────────────────────┐    ┌───────────────────────────┐
│ .claude/features/     │    │ Browser (Chromium)        │
│ features.db           │    │                           │
└───────────────────────┘    └───────────────────────────┘
```

---

## Integration with Claude Code

### Claude Desktop Configuration

To use these MCP servers with Claude Desktop, add to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "features": {
      "command": "python",
      "args": ["path/to/.claude/mcp-servers/feature-tracking/server.py"],
      "env": {
        "PROJECT_DIR": "/path/to/project/.claude/features"
      }
    }
  }
}
```

### Claude Code Hooks (Recommended)

For on-demand startup, use a pre-tool-use hook to start the MCP server when needed:

```python
# hooks/start_mcp.py
import subprocess
import os

def ensure_mcp_running():
    """Start feature MCP server if not already running."""
    # Check if server is running (implementation depends on your setup)
    # If not, start it as a background process
    pass
```

---

## Database Location

The feature database is stored at:
```
{project_root}/.claude/features/features.db
```

This location was chosen because:
1. `.claude/` directory contains all Claude-specific configuration
2. `features/` subdirectory keeps feature data separate from other config
3. When copying this framework to a new project, the structure is self-contained

---

## Development

### Adding a New MCP Server

1. Create a new directory under `mcp-servers/`
2. Implement the server using FastMCP or similar
3. Add a README.md with setup instructions
4. Update this file with the new server details
5. Update relevant skills to use the new server

### Testing MCP Servers

```bash
# Test feature tracking tools
python -c "from server import mcp; print(mcp.list_tools())"

# Run with debug logging
DEBUG=1 python server.py
```

---

## Troubleshooting

### Feature Server Won't Start

1. Check Python version (3.10+ required)
2. Verify dependencies: `pip install -r requirements.txt`
3. Check PROJECT_DIR environment variable is set
4. Look for port conflicts (default: stdio)

### Database Errors

1. Ensure `.claude/features/` directory exists
2. Check file permissions on `features.db`
3. Run migration if upgrading from JSON format

### Browser Automation Issues

1. Ensure Playwright is installed: `npx playwright install`
2. Check chromium is available
3. See `browser-automation/README.md` for detailed troubleshooting

---

## References

- [FastMCP Documentation](https://github.com/jlowin/fastmcp)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Playwright MCP](https://github.com/microsoft/playwright-mcp)
- [Claude Code MCP Integration](https://docs.anthropic.com/claude-code/mcp)
