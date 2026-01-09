# Security Model

The base-claude framework implements a defense-in-depth security model to protect against malicious command execution and unauthorized system access.

---

## Security Layers

### Layer 1: OS-Level Sandbox
- File system restrictions (if supported by Claude Code)
- Process isolation
- Network restrictions

### Layer 2: File Permissions
- `.claude_settings.json` restricts file access to project directory
- No access to parent directories
- No access to sensitive system files

### Layer 3: Command Allowlist (This Layer)
- Pre-execution validation of ALL bash commands
- Allowlist-based approach (deny by default)
- Special validators for sensitive commands
- Fail-safe parsing

---

## Command Allowlist System

### How It Works

**1. Pre-Tool-Use Hook**
```
User request → Agent plans action → HOOK validates → Execute or block
```

**2. Validation Process**
```python
def validate_bash_command(command: str) -> bool:
    """
    Returns True if command allowed, False if blocked.
    """
    # Parse command safely
    tokens = shlex.split(command)
    base_command = tokens[0]

    # Check allowlist
    if base_command not in ALLOWED_COMMANDS:
        return False

    # Special validators for sensitive commands
    if base_command in SENSITIVE_COMMANDS:
        return validate_sensitive_command(base_command, tokens)

    return True
```

**3. Error Handling**
```
Blocked command → Agent notified → Agent asks user for permission OR finds alternative
```

---

## Default Allowed Commands

See `allowed-commands.md` for the full list and customization instructions.

**Categories:**
- **File Inspection:** ls, cat, head, tail, wc, grep, find
- **Node.js Development:** npm, npx, pnpm, node
- **Python Development:** python, pip, poetry, pytest
- **Version Control:** git
- **Process Management:** ps, lsof, kill, pkill (restricted)
- **Containers:** docker, docker-compose
- **Shells:** bash, sh

---

## Special Command Validators

See `command-validators.md` for detailed validation rules.

### pkill Validator
Only allows killing development processes:
```bash
✅ pkill -f "node.*vite"
✅ pkill -f "npm run dev"
❌ pkill -f "postgres"
❌ pkill -f "system"
```

### chmod Validator
Only allows adding execute permissions:
```bash
✅ chmod +x script.sh
❌ chmod 777 file.txt
❌ chmod -R 755 .
```

### rm Validator
Prevents destructive deletions:
```bash
✅ rm temp-file.txt
❌ rm -rf /
❌ rm -rf node_modules
❌ rm *.* (dangerous wildcards)
```

---

## Customization Per Project

### Adding Allowed Commands

Edit: `.claude/security/allowed-commands.md`

```markdown
# Project-Specific Allowed Commands

## Base Commands (from framework)
[inherited from base-claude]

## Project-Specific Additions
- `make` - Build system
- `terraform` - Infrastructure as code
- `kubectl` - Kubernetes management

## Rationale
This project uses Make for builds and Terraform for infrastructure.
Kubernetes access needed for deployment verification.
```

### Adding Custom Validators

Edit: `.claude/security/command-validators.md`

```markdown
# Project-Specific Validators

## terraform validator
Only allow plan and apply with confirmation:

```bash
✅ terraform plan
✅ terraform apply (asks for user confirmation first)
❌ terraform destroy
```
```

---

## Integration with CLAUDE.md

Reference in your project's `CLAUDE.md`:

```markdown
## Security Protocol

ALL bash commands are validated before execution using the command allowlist system.

**Validation rules:**
1. Command must be in allowed list (`.claude/security/allowed-commands.md`)
2. Sensitive commands require additional validation (`.claude/security/command-validators.md`)
3. Unparseable commands are blocked (fail-safe)

**If command is blocked:**
1. Agent will be notified with reason
2. Agent should either:
   - Use an alternative allowed command
   - Ask user for explicit permission
   - Explain why the command is needed

**User can override:**
- For one-time commands: User can manually execute
- For permanent: Add to `.claude/security/allowed-commands.md`
```

---

## Reference Implementation

The `python/` directory contains the reference implementation:

- `security.py` - Full Python implementation with validators
- `example_usage.py` - How to integrate with Claude SDK

This can be adapted to other languages or used directly if your project uses Python.

---

## Security Best Practices

### 1. Principle of Least Privilege
Only allow commands that are necessary for the project.

**Bad:**
```markdown
Allowed: curl, wget, nc, nmap, telnet
Reason: Might need to debug networking
```

**Good:**
```markdown
Allowed: curl (HTTP requests only)
Validators: curl validator blocks file:// protocol
Reason: API testing requires HTTP requests
```

### 2. Explicit Over Implicit
Be explicit about what's allowed, don't rely on defaults.

**Bad:**
```markdown
Allowed: * (everything)
```

**Good:**
```markdown
Allowed:
- npm, npx, node (Node.js project)
- git (version control)
- ls, cat, grep (file inspection)
```

### 3. Validate, Don't Filter
Use proper parsing (shlex), don't regex-match commands.

**Bad:**
```python
if "rm" not in command:  # Easily bypassed
    return True
```

**Good:**
```python
tokens = shlex.split(command)
if tokens[0] == "rm":
    return validate_rm_command(tokens)
```

### 4. Fail-Safe
If validation errors, block the command.

```python
try:
    tokens = shlex.split(command)
except ValueError:
    # Unparseable command - block it
    return False
```

### 5. Audit Log
Log all blocked commands for review.

```python
if not allowed:
    log_blocked_command(command, reason)
    return False
```

---

## Testing Security

### Test Allowed Commands
```bash
# These should all be allowed (for Node.js project)
npm install
git status
ls -la
cat package.json
ps aux
```

### Test Blocked Commands
```bash
# These should all be blocked
sudo rm -rf /
curl file:///etc/passwd
# (Malicious code examples omitted for security)
```

### Test Special Validators
```bash
# pkill - only dev processes
pkill -f "node.*vite"    # Allowed
pkill -f "postgres"      # Blocked

# chmod - only +x
chmod +x script.sh       # Allowed
chmod 777 file           # Blocked
```

---

## Troubleshooting

### "Command blocked: not in allowlist"

**Cause:** Command not in allowed commands list

**Solution:**
1. Verify command is necessary
2. Add to `.claude/security/allowed-commands.md`
3. Document rationale

### "Command blocked: failed validation"

**Cause:** Command in allowlist but failed special validator

**Solution:**
1. Check `.claude/security/command-validators.md` for rules
2. If legitimate use case, update validator
3. Or ask user to run command manually

### "Command blocked: unparseable"

**Cause:** Command has syntax that shlex can't parse

**Solution:**
1. Simplify command syntax
2. Break into multiple commands
3. Use script file instead of inline command

---

## Security Incident Response

If a malicious command is detected:

1. **Block immediately** - Fail-safe prevents execution
2. **Log the attempt** - Record command and context
3. **Alert user** - Notify user of potential security issue
4. **Review context** - Was this a legitimate use case or attack?
5. **Update rules** - Strengthen validators if needed

---

## FAQ

**Q: Can I disable security for my project?**
A: Not recommended. You can add commands to allowlist instead.

**Q: What if I need a command not in the allowlist?**
A: Add it to `.claude/security/allowed-commands.md` with rationale.

**Q: How do I test changes to security rules?**
A: Run test suite in `python/tests/` or create project-specific tests.

**Q: Can agents bypass this security?**
A: No. The hook runs BEFORE tool execution. Agents cannot bypass it.

**Q: What about commands in scripts?**
A: Scripts (bash, python, etc.) are executed via allowed commands (bash, python), so script content is NOT validated. Be cautious with script generation.

**Q: How does this compare to OS-level sandboxing?**
A: This is an additional layer. OS sandboxing is still recommended.

---

## See Also

- `allowed-commands.md` - Customizable command allowlist
- `command-validators.md` - Special validation rules
- `security-hooks.md` - Integration with Claude Code
- `python/security.py` - Reference implementation
- `../../reference/08-security-model.md` - Architecture overview
