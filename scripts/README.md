# Claude Forge Scripts

This directory contains scripts for setup, management, and runtime helpers.

## Directory Structure

```
scripts/
├── install/          # Installation and migration scripts
│   ├── migrate.sh
│   ├── migrate.ps1
│   ├── add-project-memory.sh
│   └── add-project-memory.ps1
├── helpers/          # Runtime helper scripts (Python)
│   ├── detect_agent.py
│   ├── prepare_task_prompt.py
│   └── dispatch_analysis.py
└── README.md
```

---

## Installation Scripts (`install/`)

### Migration Scripts

| Script | Platform | Description |
|--------|----------|-------------|
| `install/migrate.sh` | macOS/Linux | Migrate existing project to Claude Forge |
| `install/migrate.ps1` | Windows | Migrate existing project to Claude Forge |

**Usage:**
```bash
# macOS/Linux
./scripts/install/migrate.sh

# Windows PowerShell
.\scripts\install\migrate.ps1
```

**What Migration Does:**
1. Prompts for target project path
2. Backs up existing `.claude/` to `.claude_old/`
3. Copies Claude Forge framework to `.claude/`
4. Creates session directories
5. Initializes project memory (`docs/project-memory/`)
6. Creates restoration script for rollback

After running the migration script, start Claude Code in your project and run `/migrate` to complete the integration.

---

### Feature Add-On Scripts

These scripts add specific features to projects that already have Claude Forge installed.

#### add-project-memory

| Script | Platform | Description |
|--------|----------|-------------|
| `install/add-project-memory.sh` | macOS/Linux | Add Project Memory feature |
| `install/add-project-memory.ps1` | Windows | Add Project Memory feature |

**Usage:**
```bash
# macOS/Linux
./scripts/install/add-project-memory.sh

# Windows PowerShell
.\scripts\install\add-project-memory.ps1
```

**What It Installs:**
- `docs/project-memory/` with template files (bugs.md, decisions.md, key-facts.md, patterns.md)
- `.claude/templates/project-memory/` with same templates (for resetting memory files)
- `/remember` skill for adding memories
- Updated `/fix-bug` skill with memory phases
- Updated `/reflect` skill with memory loading
- Updated agent definitions (architect, dev, tea)
- Reference documentation (`reference/16-project-memory.md`)

**Backup Behavior:**
- Existing files are backed up before overwriting
- Backups are stored in `.claude/backups/YYYYMMDD-HHMMSS/`
- Directory structure is preserved in backups
- Summary shows how many files were backed up

---

## Running Installation Scripts

### Prerequisites

- **macOS/Linux:** Bash shell (standard on most systems)
- **Windows:** PowerShell 5.1 or later

### Permissions (macOS/Linux)

Make scripts executable before running:
```bash
chmod +x scripts/install/*.sh
```

### Execution Policy (Windows)

If you encounter execution policy errors:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## Script Development

### Creating New Feature Scripts

When creating new feature add-on scripts:

1. **Use backup functionality** - Always backup before overwriting
2. **Preserve directory structure** - Copy backups with relative paths
3. **Report changes** - Show summary of what was modified
4. **Handle existing installations** - Check for existing files and offer choices
5. **Cross-platform** - Create both `.sh` and `.ps1` versions

### Backup Pattern (Bash)

```bash
BACKUP_TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

backup_if_exists() {
    local src="$1"
    local backup_dir="$PROJECT_DIR/.claude/backups/$BACKUP_TIMESTAMP"

    if [ -e "$src" ]; then
        mkdir -p "$backup_dir"
        local relative_path="${src#$PROJECT_DIR/}"
        local backup_path="$backup_dir/$relative_path"
        mkdir -p "$(dirname "$backup_path")"
        cp -r "$src" "$backup_path"
        return 0
    fi
    return 1
}
```

### Backup Pattern (PowerShell)

```powershell
$BackupTimestamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Backup-IfExists {
    param([string]$SourcePath, [string]$ProjectDir, [string]$Timestamp)

    if (Test-Path $SourcePath) {
        $backupDir = Join-Path $ProjectDir ".claude\backups\$Timestamp"
        $relativePath = $SourcePath.Replace($ProjectDir, "").TrimStart("\", "/")
        $backupPath = Join-Path $backupDir $relativePath

        $backupParent = Split-Path -Parent $backupPath
        if (-not (Test-Path $backupParent)) {
            New-Item -Path $backupParent -ItemType Directory -Force | Out-Null
        }

        Copy-Item -Path $SourcePath -Destination $backupPath -Recurse -Force
        return $true
    }
    return $false
}
```

---

## Troubleshooting

### Script not found

Ensure you're in the claude-forge directory:
```bash
cd /path/to/claude-forge
ls scripts/install/
```

### Permission denied (macOS/Linux)

Make the script executable:
```bash
chmod +x scripts/install/migrate.sh
```

### Execution policy error (Windows)

Allow script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Target directory not found

Provide the full absolute path to your project:
```bash
# Good
./scripts/install/migrate.sh
# Enter path: /Users/name/projects/my-app

# Bad (relative paths may not work)
./scripts/install/migrate.sh
# Enter path: ../my-app
```

---

## Helper Scripts (`helpers/`)

These scripts reduce context usage during task execution by offloading computation to Python.

### `helpers/detect_agent.py`

Detect the appropriate agent for a task based on content keywords.

```bash
# From task ID
python3 scripts/helpers/detect_agent.py T015

# From text directly
python3 scripts/helpers/detect_agent.py --text "implement user authentication"

# Verbose output with matched keywords
python3 scripts/helpers/detect_agent.py --text "add payment checkout" --verbose

# JSON output for programmatic use
python3 scripts/helpers/detect_agent.py --text "write unit tests" --json
```

**Output:**
- Agent name (e.g., `security-boss`, `developer`, `quality-engineer`)
- With `--verbose`: matched keywords, confidence score
- With `--json`: full analysis as JSON

### `helpers/prepare_task_prompt.py`

Generate a complete Task tool prompt for delegating work to a subagent.

```bash
# Basic usage
python3 scripts/helpers/prepare_task_prompt.py T015

# With parent session tracking
python3 scripts/helpers/prepare_task_prompt.py T015 --parent-session 20240117-143022-a7x9

# For parallel tasks (specify subagent number)
python3 scripts/helpers/prepare_task_prompt.py T016 --subagent-num 2

# JSON output with metadata
python3 scripts/helpers/prepare_task_prompt.py T015 --json
```

**Output:**
- Complete prompt ready for Task tool invocation
- Includes: agent summary, task details, scope, instructions, reporting format

### `helpers/dispatch_analysis.py`

Analyze the task registry to find parallelizable work.

```bash
# Basic analysis
python3 scripts/helpers/dispatch_analysis.py

# Limit parallel agents
python3 scripts/helpers/dispatch_analysis.py --max-agents 2

# JSON output
python3 scripts/helpers/dispatch_analysis.py --json

# Generate prompts for all parallelizable tasks
python3 scripts/helpers/dispatch_analysis.py --generate-prompts --parent-session abc123
```

**Output:**
- Primary task (for main agent)
- Parallelizable tasks (for subagents)
- Deferred tasks with reasons (scope conflicts, dependencies, security)

### Token Savings

| Operation | Without Script | With Script |
|-----------|---------------|-------------|
| Detect agent | ~200 tokens (read summary, analyze) | ~50 tokens (one bash call) |
| Prepare prompt | ~500 tokens (read 3 files, assemble) | ~100 tokens (one bash call) |
| Dispatch analysis | ~800 tokens (read registry, analyze all) | ~100 tokens (one bash call) |

### Integration with Skills

These scripts are called by the reflect skill flows:

| Script | Called By | When |
|--------|-----------|------|
| `detect_agent.py` | `skills/reflect/flows/resume.md` | Step 7 of `/reflect resume T###` |
| `dispatch_analysis.py` | `skills/reflect/dispatch/task-dispatch.md` | Step 1 of dispatch flow |
| `prepare_task_prompt.py` | `skills/reflect/dispatch/task-dispatch.md` | Step 3 when spawning sub-agents |

**Example from resume.md:**
```bash
python3 scripts/helpers/detect_agent.py {task.id}
```

**Example from task-dispatch.md:**
```bash
python3 scripts/helpers/dispatch_analysis.py --json
python3 scripts/helpers/prepare_task_prompt.py T016 --parent-session 20240117-143022-a7x9 --subagent-num 1
```

### Requirements

- Python 3.10+
- No external dependencies (uses only stdlib)

---

## See Also

- [README.md](../README.md) - Main framework documentation
- [hooks/README.md](../hooks/README.md) - Hook system documentation
- [templates/README.md](../templates/README.md) - Template documentation
- [skills/reflect/SKILL.md](../skills/reflect/SKILL.md) - Reflect skill routing hub
