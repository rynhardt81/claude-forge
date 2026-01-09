# 08-security-model.md

**Security Model for Autonomous Operations**

> **Audience:** Developers, Security Engineers, Claude Code
> **Authority:** Security Policy (Tier 1)
> **Persona:** Security Architect
> **Purpose:** Define security boundaries for autonomous agent operations

---

## 1. Purpose of This Document

This document defines the **security model** for autonomous development operations.

It answers:
* What commands can agents execute?
* How are dangerous operations prevented?
* What validation occurs before execution?
* How are security incidents handled?

This document does NOT cover:
* Application-level security (see `03-security-auth-and-access.md`)
* Infrastructure security (see ops documentation)
* User authentication flows (see app security docs)

---

## 2. Security Philosophy

### Defense in Depth

Multiple layers of protection:

```
Layer 1: Command Allowlist
         ↓ (only allowed commands pass)
Layer 2: Special Validators
         ↓ (dangerous commands get extra checks)
Layer 3: Argument Validation
         ↓ (parameters are validated)
Layer 4: Execution Sandboxing
         ↓ (Claude Code sandbox)
Layer 5: Output Monitoring
         ↓ (detect anomalies)
```

### Fail-Safe Defaults

- **Default Deny:** Commands not in allowlist are blocked
- **Explicit Allow:** Only listed commands can execute
- **Minimum Privilege:** Validators restrict to safe operations
- **No Bypass:** Security rules cannot be overridden by agents

---

## 3. Command Allowlist

### Allowlist Location

`security/allowed-commands.md`

### Allowed Command Categories

| Category | Commands | Purpose |
|----------|----------|---------|
| Package Managers | npm, yarn, pnpm, pip | Install dependencies |
| Build Tools | vite, webpack, esbuild | Build applications |
| Dev Servers | node, npx | Run development servers |
| Testing | jest, vitest, pytest | Run tests |
| Linting | eslint, prettier, tsc | Code quality |
| Version Control | git | Source control |
| File Operations | ls, cat, mkdir | Basic file ops |
| Process Control | pkill | Stop dev processes |
| Network | curl | API testing |

### Full Allowlist

```markdown
## Always Allowed (No Restrictions)

npm, yarn, pnpm, bun
node, npx, tsx, ts-node
python, python3, pip, pip3
vite, webpack, esbuild, rollup
jest, vitest, pytest, mocha
eslint, prettier, tsc, biome
git (with restrictions)
ls, pwd, which, echo
mkdir, touch, cp, mv
cat, head, tail, less
grep, find, wc
curl (with restrictions)
```

---

## 4. Special Validators

Some commands require additional validation beyond the allowlist.

### Validator: pkill

**Purpose:** Only allow killing development processes.

```python
ALLOWED_PROCESSES = [
    'node', 'npm', 'yarn', 'pnpm',
    'vite', 'webpack', 'esbuild',
    'next', 'nuxt', 'remix',
    'jest', 'vitest', 'pytest'
]

def validate_pkill(args):
    # Extract process name from args
    process = extract_process_name(args)

    if process not in ALLOWED_PROCESSES:
        return False, f"Cannot kill {process}: not a dev process"

    return True, None
```

**Blocked:**
- `pkill postgres` - Database process
- `pkill nginx` - Web server
- `pkill systemd` - System process

### Validator: chmod

**Purpose:** Only allow making files executable.

```python
def validate_chmod(args):
    # Only allow +x (make executable)
    if '+x' not in args and '755' not in args:
        return False, "Only chmod +x allowed"

    return True, None
```

**Blocked:**
- `chmod 777` - World writable
- `chmod -R` - Recursive changes
- `chmod 000` - Remove all permissions

### Validator: rm

**Purpose:** Prevent destructive deletions.

```python
def validate_rm(args):
    # Block recursive deletion
    if '-r' in args or '-rf' in args or '-fr' in args:
        return False, "Recursive deletion not allowed"

    # Block force flag alone (can hide errors)
    if '-f' in args and '-r' not in args:
        # Allow -f for single files, but warn
        pass

    return True, None
```

**Blocked:**
- `rm -rf /` - System destruction
- `rm -r node_modules` - Use package manager instead
- `rm -rf .git` - Repository destruction

### Validator: curl

**Purpose:** Prevent file protocol and dangerous operations.

```python
def validate_curl(args):
    # Block file:// protocol
    if 'file://' in ' '.join(args):
        return False, "file:// protocol not allowed"

    # Block output to sensitive locations
    for arg in args:
        if arg.startswith('-o') or arg.startswith('--output'):
            output_path = get_output_path(args)
            if is_sensitive_path(output_path):
                return False, f"Cannot write to {output_path}"

    return True, None
```

**Blocked:**
- `curl file:///etc/passwd` - Local file access
- `curl -o /etc/hosts` - System file overwrite

### Validator: git

**Purpose:** Prevent destructive git operations.

```python
def validate_git(args):
    subcommand = args[0] if args else ''

    # Block force push to protected branches
    if subcommand == 'push':
        if '--force' in args or '-f' in args:
            if 'main' in args or 'master' in args:
                return False, "Force push to main/master not allowed"

    # Block hard reset
    if subcommand == 'reset':
        if '--hard' in args:
            return False, "Hard reset requires confirmation"

    return True, None
```

**Blocked:**
- `git push --force origin main` - Destructive push
- `git reset --hard` - Lose uncommitted changes
- `git clean -fdx` - Remove untracked files

---

## 5. Validation Flow

### Pre-Tool-Use Hook

Every bash command passes through validation:

```python
def bash_security_hook(command: str) -> tuple[bool, str]:
    """
    Pre-tool-use hook for bash commands.

    Returns:
        (allowed: bool, message: str)
    """
    # Parse command
    try:
        parts = shlex.split(command)
    except ValueError:
        return False, "Could not parse command"

    if not parts:
        return False, "Empty command"

    base_command = parts[0]
    args = parts[1:]

    # Check allowlist
    if base_command not in ALLOWED_COMMANDS:
        return False, f"Command '{base_command}' not in allowlist"

    # Check special validators
    if base_command in VALIDATORS:
        allowed, message = VALIDATORS[base_command](args)
        if not allowed:
            return False, message

    return True, "Command allowed"
```

### Integration Point

The hook is called by Claude Code before executing any bash command:

```python
# Claude Code integration (conceptual)
def execute_bash(command):
    # Security check
    allowed, message = bash_security_hook(command)

    if not allowed:
        return {
            'error': True,
            'message': f"Security: {message}",
            'blocked': True
        }

    # Execute if allowed
    return subprocess.run(command, ...)
```

---

## 6. Handling Blocked Commands

### Agent Response to Block

When a command is blocked, the agent should:

1. **Acknowledge the block**
2. **Find an alternative approach**
3. **Ask user if stuck**

```markdown
## Example: Blocked Command

Agent tries: rm -rf node_modules
System returns: "Security: Recursive deletion not allowed"

Agent response:
"I cannot use rm -rf. Let me use the package manager instead:
npm ci  (clean install)"
```

### User Override

Some blocks can be overridden by the user:

```markdown
## User Override Flow

1. Agent reports: "Command blocked: git reset --hard"
2. User decides: "Go ahead and run it" or "Find another way"
3. If approved: User runs command manually
4. Agent continues with next step
```

### Cannot Override

Some operations are never allowed:

- Force push to main/master
- System file modifications
- Process killing outside dev tools
- Recursive deletions

---

## 7. Security Boundaries

### What Agents CAN Do

- Install dependencies (npm, pip)
- Run build tools (vite, webpack)
- Execute tests (jest, pytest)
- Lint and format code
- Git operations (non-destructive)
- Read files
- Write to project directories
- Run dev servers
- Make API calls (curl)

### What Agents CANNOT Do

- Delete files recursively
- Kill system processes
- Modify system files
- Force push to protected branches
- Access file:// URLs
- Change file permissions (except +x)
- Run arbitrary system commands

---

## 8. Audit and Logging

### Command Logging

All commands are logged:

```json
{
    "timestamp": "2024-01-15T14:30:00Z",
    "command": "npm install",
    "allowed": true,
    "validator": null,
    "session_id": "abc123"
}
```

### Block Logging

Blocked commands are logged with details:

```json
{
    "timestamp": "2024-01-15T14:31:00Z",
    "command": "rm -rf node_modules",
    "allowed": false,
    "reason": "Recursive deletion not allowed",
    "validator": "rm",
    "session_id": "abc123"
}
```

### Log Review

Security logs should be reviewed:
- After each autonomous session
- When investigating issues
- During security audits

---

## 9. Extending the Security Model

### Adding New Commands

To allow a new command:

1. Evaluate security implications
2. Add to `security/allowed-commands.md`
3. Create validator if needed
4. Document in this file
5. Test thoroughly

### Adding New Validators

To add a validator:

1. Identify dangerous patterns
2. Implement validation function
3. Add to VALIDATORS dict
4. Document allowed/blocked patterns
5. Add test cases

### Security Review Checklist

Before adding commands:

- [ ] What damage could this command cause?
- [ ] Can it be restricted to safe operations?
- [ ] Is there a safer alternative?
- [ ] What arguments need validation?
- [ ] Should it require user confirmation?

---

## 10. Incident Response

### Security Incident Types

| Type | Example | Response |
|------|---------|----------|
| Blocked Attempt | Agent tried rm -rf | Log, continue |
| Bypass Attempt | Agent tried to circumvent | Log, alert, investigate |
| Unexpected Behavior | Command did unexpected thing | Stop, investigate |
| Data Exposure | Sensitive data in logs | Remediate, notify |

### Response Procedure

1. **Detect:** Security hook blocks or logs issue
2. **Contain:** Stop current operation if needed
3. **Assess:** Review logs and impact
4. **Remediate:** Fix any damage, update rules
5. **Learn:** Update validators, document

---

## 11. Implementation Reference

### Python Implementation

Full reference implementation at: `security/python/security.py`

```python
# Example usage
from security import bash_security_hook

allowed, message = bash_security_hook("npm install")
# allowed=True, message="Command allowed"

allowed, message = bash_security_hook("rm -rf /")
# allowed=False, message="Recursive deletion not allowed"
```

### Integration with Claude Code

The security model integrates with Claude Code's hook system:

```json
{
    "hooks": {
        "pre-tool-use": {
            "bash": "python security/python/security.py"
        }
    }
}
```

---

## 12. See Also

- `security/README.md` - Security overview
- `security/allowed-commands.md` - Full allowlist
- `security/command-validators.md` - Validator details
- `security/python/security.py` - Reference implementation
- `03-security-auth-and-access.md` - Application security
