# Allowed Commands

This file defines which bash commands are permitted for execution. Commands not in this list will be blocked by the security validation layer.

---

## Customization Instructions

**To customize for your project:**
1. Copy this file to your project's `.claude/security/` directory
2. Add project-specific commands to the "Project-Specific Additions" section
3. Document the rationale for each addition
4. Remove any base commands that aren't needed for your project

**Security note:** Only add commands that are necessary for your project. Follow the principle of least privilege.

---

## Base Commands (Standard Set)

### File Inspection
Commands for reading and inspecting files (read-only operations).

```
ls       # List directory contents
cat      # Display file contents
head     # Display first lines of file
tail     # Display last lines of file (including tail -f for logs)
wc       # Count lines, words, characters
grep     # Search text patterns
find     # Search for files
```

**Rationale:** Required for code exploration, log inspection, and understanding project structure.

---

### Node.js Development
Commands for JavaScript/TypeScript development.

```
npm      # Node package manager
npx      # Execute npm packages
pnpm     # Fast package manager alternative
node     # Node.js runtime
```

**Rationale:** Required for installing dependencies, running scripts, and executing JavaScript code.

**⚠️ Remove if:** Your project doesn't use Node.js/JavaScript.

---

### Python Development
Commands for Python development.

```
python   # Python interpreter (includes python3)
pip      # Python package installer
poetry   # Python dependency manager
pytest   # Python testing framework
```

**Rationale:** Required for running Python code, installing packages, and running tests.

**⚠️ Remove if:** Your project doesn't use Python.

---

### Version Control
Commands for git operations.

```
git      # Version control system
```

**Rationale:** Required for commits, branches, pull requests, and version history.

**⚠️ Required:** Nearly all projects need git.

---

### Process Management
Commands for managing running processes (with restrictions).

```
ps       # List running processes
lsof     # List open files and network connections
kill     # Terminate process by PID
pkill    # Terminate process by name (RESTRICTED - see validators)
```

**Rationale:** Required for managing development servers, killing hung processes.

**⚠️ Note:** `pkill` has special validation rules (see `command-validators.md`). Only dev processes can be killed.

---

### Container Management
Commands for Docker and containerization.

```
docker           # Docker CLI
docker-compose   # Docker Compose (multi-container)
```

**Rationale:** Required if project uses Docker for development or deployment.

**⚠️ Remove if:** Your project doesn't use Docker.

---

### Shell Execution
Commands for running shell scripts.

```
bash     # Bash shell
sh       # POSIX shell
```

**Rationale:** Required for executing setup scripts, build scripts, and utilities.

**⚠️ Note:** Be cautious with script generation. Script contents are NOT validated by this security layer.

---

## Project-Specific Additions

This section is for commands specific to your project. Add them here with clear rationale.

### Example Additions

**Build Tools:**
```
make     # GNU Make build system
cmake    # CMake build system
gradle   # Gradle build tool (Java)
mvn      # Maven build tool (Java)
```

**Cloud/Infrastructure:**
```
terraform  # Infrastructure as code
aws        # AWS CLI
gcloud     # Google Cloud CLI
kubectl    # Kubernetes CLI
```

**Database:**
```
psql       # PostgreSQL client
mysql      # MySQL client
mongosh    # MongoDB shell
redis-cli  # Redis CLI
```

**Language-Specific:**
```
dotnet     # .NET CLI
cargo      # Rust package manager
go         # Go compiler/runtime
ruby       # Ruby interpreter
php        # PHP interpreter
```

**Testing/QA:**
```
jest       # JavaScript testing
vitest     # Vite-native testing
playwright # Browser automation (if not using MCP)
```

---

## Commands NOT Allowed (Examples)

The following commands are intentionally NOT allowed for security reasons:

### System Administration
```
❌ sudo       # Privilege escalation
❌ su         # Switch user
❌ chmod      # Change file permissions (except +x via validator)
❌ chown      # Change file ownership
❌ usermod    # Modify user accounts
```

### Destructive Operations
```
❌ rm -rf     # Recursive forced deletion (rm alone has validators)
❌ dd         # Direct disk write
❌ mkfs       # Format filesystem
❌ fdisk      # Partition management
```

### Network/Security Tools
```
❌ nc         # Netcat (network utility)
❌ nmap       # Network mapper
❌ telnet     # Telnet client
❌ ssh        # SSH client (use manual SSH instead)
❌ scp        # Secure copy (file transfer)
```

### Package Management (System-Level)
```
❌ apt        # Debian package manager
❌ yum        # RedHat package manager
❌ brew       # Homebrew (can install system tools)
```

**Rationale:** These commands can:
- Modify system configuration
- Delete critical files
- Escalate privileges
- Access sensitive data
- Install system-level software

**If you need these:** Run them manually outside of agent control.

---

## Validation Process

When an agent attempts to run a bash command:

1. **Parse Command:** Extract base command using `shlex.split()`
2. **Check Allowlist:** Is base command in this file?
   - ✅ Yes → Continue to step 3
   - ❌ No → BLOCK with message: "Command not in allowlist"
3. **Check Validators:** Does command have special validation rules?
   - If yes → Run validator (see `command-validators.md`)
   - If no → ALLOW
4. **Execute:** Command runs

---

## Adding New Commands

### Process

1. **Identify Need:** Why is this command necessary?
2. **Assess Risk:** What could go wrong if this command is misused?
3. **Add Validator:** If command has security implications, create validator
4. **Document:** Add to this file with clear rationale
5. **Test:** Verify command works as expected

### Template

```markdown
### [Category Name]
Commands for [purpose].

```
[command]  # [brief description]
```

**Rationale:** [Why this command is necessary]

**⚠️ Remove if:** [Conditions when this command isn't needed]
```

---

## Tech Stack Presets

Common command sets by project type:

### Full-Stack Web (MERN/MEAN)
```
node, npm, npx, pnpm
git
ls, cat, grep, head, tail, wc, find
ps, lsof, kill, pkill
docker, docker-compose (if using Docker)
```

### Python Backend (Django/Flask)
```
python, pip, poetry, pytest
git
ls, cat, grep, head, tail, wc, find
ps, lsof, kill, pkill
docker, docker-compose (if using Docker)
psql (if PostgreSQL)
```

### .NET Application
```
dotnet
git
ls, cat, grep, head, tail, wc, find
ps, lsof, kill, pkill
docker, docker-compose (if using Docker)
```

### Static Site / JAMstack
```
node, npm, npx
git
ls, cat, grep, head, tail, wc, find
```

### Rust Application
```
cargo
git
ls, cat, grep, head, tail, wc, find
ps, lsof, kill, pkill
```

---

## Security Hardening

For maximum security, start with the MINIMAL set and add only as needed:

```
# Absolute minimum for most projects
git
ls, cat, grep
```

Then add project-specific commands one at a time, documenting each addition.

---

## Audit Log

Maintain a log of command additions:

```markdown
## Change History

### 2024-01-15: Initial Setup
- Added Node.js commands (npm, npx, node)
- Added git
- Added file inspection commands

### 2024-01-20: Added Docker
- Added docker, docker-compose
- Rationale: Project now uses Docker for local development

### 2024-02-01: Added PostgreSQL
- Added psql
- Rationale: Need to run database migrations and check data
```

This helps track why commands were added and makes security reviews easier.

---

## Testing Commands

To test if a command is allowed, you can ask the agent:

```
User: "Is the command 'npm install' allowed?"
Agent: [Checks allowlist] "Yes, 'npm' is in the allowed commands list."

User: "Is the command 'sudo apt install' allowed?"
Agent: [Checks allowlist] "No, 'sudo' is not in the allowed commands list and will be blocked."
```

---

## See Also

- `README.md` - Security model overview
- `command-validators.md` - Special validation rules for sensitive commands
- `security-hooks.md` - Integration with Claude Code hooks
- `../../reference/08-security-model.md` - Architecture documentation
