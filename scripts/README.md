# Claude Forge Scripts

This directory contains shell scripts for setting up and managing Claude Forge installations.

## Available Scripts

### Migration Scripts

| Script | Platform | Description |
|--------|----------|-------------|
| `migrate.sh` | macOS/Linux | Migrate existing project to Claude Forge |
| `migrate.ps1` | Windows | Migrate existing project to Claude Forge |

**Usage:**
```bash
# macOS/Linux
./scripts/migrate.sh

# Windows PowerShell
.\scripts\migrate.ps1
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
| `add-project-memory.sh` | macOS/Linux | Add Project Memory feature |
| `add-project-memory.ps1` | Windows | Add Project Memory feature |

**Usage:**
```bash
# macOS/Linux
./scripts/add-project-memory.sh

# Windows PowerShell
.\scripts\add-project-memory.ps1
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

## Running Scripts

### Prerequisites

- **macOS/Linux:** Bash shell (standard on most systems)
- **Windows:** PowerShell 5.1 or later

### Permissions (macOS/Linux)

Make scripts executable before running:
```bash
chmod +x scripts/*.sh
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
ls scripts/
```

### Permission denied (macOS/Linux)

Make the script executable:
```bash
chmod +x scripts/migrate.sh
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
./scripts/migrate.sh
# Enter path: /Users/name/projects/my-app

# Bad (relative paths may not work)
./scripts/migrate.sh
# Enter path: ../my-app
```

---

## See Also

- [README.md](../README.md) - Main framework documentation
- [hooks/README.md](../hooks/README.md) - Hook system documentation
- [templates/README.md](../templates/README.md) - Template documentation
