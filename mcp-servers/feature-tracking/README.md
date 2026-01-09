# Feature Tracking MCP Server

MCP server for managing features in the autonomous development workflow. Provides tools to create, query, and update feature status during `/new-project` and `/implement-features` skills.

---

## Quick Start

### 1. Install Dependencies

```bash
cd mcp-servers/feature-tracking
pip install -r requirements.txt
```

### 2. Set Environment Variable

```bash
# Point to where features.db should be stored
export PROJECT_DIR="/path/to/project/.claude/features"

# Windows (PowerShell)
$env:PROJECT_DIR = "C:\path\to\project\.claude\features"

# Windows (CMD)
set PROJECT_DIR=C:\path\to\project\.claude\features
```

### 3. Run the Server

```bash
python server.py
```

---

## Available Tools

| Tool | Description | Used By |
|------|-------------|---------|
| `feature_get_stats` | Get completion statistics | All agents |
| `feature_get_next` | Get next pending feature | @orchestrator |
| `feature_get_for_regression` | Get random passing features | @developer |
| `feature_mark_passing` | Mark feature as complete | @developer, @quality-engineer |
| `feature_skip` | Move feature to end of queue | @orchestrator |
| `feature_mark_in_progress` | Lock feature for work | @orchestrator |
| `feature_clear_in_progress` | Unlock abandoned feature | @orchestrator |
| `feature_create_bulk` | Create many features at once | @scrum-master |
| `feature_get_by_category` | Get features by category | @orchestrator |

---

## Tool Details

### `feature_get_stats`

Returns progress statistics.

**Output:**
```json
{
  "passing": 45,
  "in_progress": 1,
  "total": 92,
  "percentage": 48.9
}
```

### `feature_get_next`

Returns the highest-priority pending feature.

**Output:**
```json
{
  "id": 46,
  "priority": 46,
  "category": "D",
  "name": "Add item to cart workflow",
  "description": "User can add products to shopping cart...",
  "steps": [
    "Navigate to product page",
    "Click 'Add to Cart' button",
    "Verify cart count increases"
  ],
  "passes": false,
  "in_progress": false
}
```

### `feature_get_for_regression`

Returns random passing features for regression testing.

**Parameters:**
- `limit` (int, 1-10): Maximum features to return (default: 3)

**Output:**
```json
{
  "features": [...],
  "count": 3
}
```

### `feature_mark_passing`

Marks a feature as complete.

**Parameters:**
- `feature_id` (int): The feature ID

**Output:**
```json
{
  "id": 46,
  "passes": true,
  "in_progress": false,
  ...
}
```

### `feature_skip`

Moves a feature to the end of the priority queue.

**Parameters:**
- `feature_id` (int): The feature ID

**Output:**
```json
{
  "id": 46,
  "name": "Feature name",
  "old_priority": 46,
  "new_priority": 93,
  "message": "Feature 'Feature name' moved to end of queue"
}
```

### `feature_create_bulk`

Creates multiple features at once. Used during `/new-project` Phase 2.

**Parameters:**
- `features` (list): List of feature objects

**Input Example:**
```json
{
  "features": [
    {
      "category": "A",
      "name": "User login",
      "description": "Users can log in with email and password",
      "steps": ["Navigate to /login", "Enter credentials", "Click submit", "Verify redirect"]
    },
    {
      "category": "A",
      "name": "User logout",
      "description": "Users can log out from any page",
      "steps": ["Click logout button", "Verify redirect to home"]
    }
  ]
}
```

**Output:**
```json
{
  "created": 2
}
```

### `feature_get_by_category`

Returns all features in a specific category.

**Parameters:**
- `category` (str): Category code (A-T)

**Output:**
```json
{
  "category": "A",
  "features": [...],
  "count": 8,
  "passing": 5,
  "pending": 3
}
```

---

## Database Schema

```sql
CREATE TABLE features (
    id INTEGER PRIMARY KEY,
    priority INTEGER NOT NULL DEFAULT 999,
    category VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    steps JSON NOT NULL,
    passes BOOLEAN DEFAULT FALSE,
    in_progress BOOLEAN DEFAULT FALSE
);

CREATE INDEX ix_features_priority ON features (priority);
CREATE INDEX ix_features_passes ON features (passes);
CREATE INDEX ix_features_in_progress ON features (in_progress);
```

---

## Category Codes

| Code | Category | Description |
|------|----------|-------------|
| A | Security & Authentication | Login, logout, permissions, roles |
| B | Navigation & Routing | Pages, links, menus, breadcrumbs |
| C | Data Management (CRUD) | Create, read, update, delete operations |
| D | Workflow & User Actions | Multi-step processes, state machines |
| E | Forms & Input Validation | Form fields, validation, error messages |
| F | Display & List Views | Tables, grids, cards, pagination |
| G | Search & Filtering | Search bars, filters, sorting |
| H | Notifications & Alerts | Toast messages, alerts, banners |
| I | Settings & Configuration | User preferences, app settings |
| J | Integration & APIs | External services, webhooks |
| K | Analytics & Reporting | Charts, dashboards, exports |
| L | Admin & Management | Admin panels, user management |
| M | Performance & Caching | Optimization, lazy loading |
| N | Accessibility (a11y) | Screen readers, keyboard nav |
| O | Error Handling | Error pages, fallbacks, recovery |
| P | Payment & Billing | Checkout, subscriptions, invoices |
| Q | Communication | Email, SMS, in-app messaging |
| R | Media & File Handling | Upload, images, documents |
| S | Documentation & Help | Help pages, tooltips, guides |
| T | UI Polish & Animations | Transitions, micro-interactions |

---

## Claude Desktop Integration

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "features": {
      "command": "python",
      "args": ["/path/to/.claude/mcp-servers/feature-tracking/server.py"],
      "env": {
        "PROJECT_DIR": "/path/to/project/.claude/features"
      }
    }
  }
}
```

---

## Migration from JSON

If you have an existing `feature_list.json` file, the server automatically migrates it to SQLite on first startup:

1. Detects `feature_list.json` in PROJECT_DIR
2. Imports all features to `features.db`
3. Renames JSON to `feature_list.json.backup.<timestamp>`

To manually export back to JSON:

```python
from migration import export_to_json
from database import create_database

engine, session_maker = create_database(Path("."))
export_to_json(Path("."), session_maker)
```

---

## Troubleshooting

### "Database not initialized"

The MCP server hasn't started properly. Check:
- Python 3.10+ is installed
- Dependencies are installed: `pip install -r requirements.txt`
- PROJECT_DIR environment variable is set

### "Feature with ID X not found"

The feature ID doesn't exist in the database. Use `feature_get_stats` to check if features exist.

### Migration fails

Check that `feature_list.json` is valid JSON:
```bash
python -c "import json; json.load(open('feature_list.json'))"
```

### Permission errors

Ensure the PROJECT_DIR directory exists and is writable:
```bash
mkdir -p /path/to/project/.claude/features
```

---

## Development

### Running Tests

```bash
# Test tool functionality
python -c "
from server import mcp
print('Available tools:', [t.name for t in mcp.list_tools()])
"
```

### Debug Mode

```bash
DEBUG=1 python server.py
```

### Adding New Tools

1. Add tool function with `@mcp.tool()` decorator
2. Use Annotated types for parameter validation
3. Return JSON string
4. Update this README

---

## References

- [FastMCP Documentation](https://github.com/jlowin/fastmcp)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
