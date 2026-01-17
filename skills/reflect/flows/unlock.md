# Unlock Flow

Handles `/reflect unlock T###` and `/reflect cleanup` commands.

---

## `/reflect unlock T###`

Force unlock a stale task.

**Flow:**

1. **Read Task Registry**
   - Find task T002
   - Check if locked

2. **Validate Unlock**
   - If not locked: "Task T002 is not locked."
   - If locked by current session: "You already have this task locked."
   - If locked and not stale: Warn user

```markdown
## Unlock Task T002?

**Task:** T002 - [Task Name]
**Locked by:** session-xyz
**Since:** 45 minutes ago
**Stale:** No (timeout is 60 minutes)

This task is actively locked. Force unlock?
- [Yes, unlock anyway] - May cause conflicts
- [No, cancel] - Wait for lock to expire
```

3. **If Stale or User Confirms**
   - Clear lock from task
   - Set status to `continuation` (preserves any partial work)
   - Add to lock history

4. **Update Task File**

```markdown
## Lock History

| Action | Time | Session | Reason |
|--------|------|---------|--------|
| created | 2024-01-15 10:00 | - | Initial creation |
| locked | 2024-01-15 14:00 | session-xyz | Started work |
| unlocked | 2024-01-15 15:30 | session-abc | Stale lock (manual) |
```

5. **Confirm**

```markdown
## Task T002 Unlocked

**Previous Status:** in_progress (locked)
**New Status:** continuation

The task is now available. Resume with `/reflect resume T002`.
```

---

## `/reflect cleanup`

Clean up stale sessions from the active directory.

**Flow:**

1. **Scan Active Sessions**
   - List all files in `.claude/memories/sessions/active/`
   - Parse timestamps from session IDs

2. **Identify Stale Sessions**
   - Sessions older than `sessionStaleTimeout` (default: 24h)

3. **Present Stale Sessions**

```markdown
## Stale Sessions Found

| Session ID | Started | Age | Branch |
|------------|---------|-----|--------|
| 20240114-093022-b2k4 | 2024-01-14 09:30 | 29h | feature/old |

Clean up these sessions?
- Move to completed/ with status "abandoned"
- Append summary to progress-notes.md
```

4. **On Confirmation**
   - Update each session file's status to `abandoned`
   - Move from `active/` to `completed/`
   - Append summary to `progress-notes.md`
