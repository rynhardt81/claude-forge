---
name: reflect
description: Self-improving skill that extracts preferences and corrections to update skills, and captures session context for continuity. Use /reflect to manually trigger, /reflect on to enable auto-reflection, or /reflect resume to continue from last session.
---

# Reflect Skill

## Purpose

1. **Skill Improvement:** Extract learnings to make skills better over time
2. **Session Continuity:** Capture context so you can resume seamlessly

## Commands

| Command | Purpose |
|---------|---------|
| `/reflect` | Manual reflection on current session |
| `/reflect on` | Enable auto-reflection at session end |
| `/reflect off` | Disable auto-reflection |
| `/reflect status` | Show settings and recent learnings |
| `/reflect config` | Configure approval mode and signals |
| `/reflect resume` | Load last session and continue |

## Manual Reflection Flow

1. Scan current conversation for learning signals (see [SIGNALS.md](SIGNALS.md))
2. Identify skills used during session
3. Categorize findings by confidence (High/Medium/Low)
4. Match learnings to relevant skills or general memories
5. Capture session context using [SESSION-TEMPLATE.md](SESSION-TEMPLATE.md)
6. Present batch review of proposed changes (see [CHECKPOINTS.md](CHECKPOINTS.md))
7. On approval, update files per [UPDATE-RULES.md](UPDATE-RULES.md)
8. Commit changes with descriptive message

## Auto-Reflection Flow

When enabled (`/reflect on`) and session ends:
1. Hook checks if skills were used this session
2. If yes, triggers reflection automatically
3. Same flow as manual, respects approval mode in config
4. Batch mode: presents review before applying
5. Auto mode: applies high confidence, queues others for review

## Resume Flow (`/reflect resume`)

1. Read `.claude/memories/sessions/latest.md`
2. Present session summary:
   - What was being worked on
   - Tasks completed / incomplete
   - Bugs and fixes
   - Where you left off
3. Ask: "Continue from here?"
4. Load context and proceed with incomplete tasks

## Storage Locations

```
.claude/
├── memories/
│   ├── general.md              # General preferences not tied to skills
│   ├── sessions/
│   │   ├── latest.md           # Most recent session (copy)
│   │   └── YYYY-MM-DD.md       # Date-stamped sessions
│   ├── .reflect-status         # on/off toggle
│   ├── .reflect-config.json    # Configuration
│   └── .session-skills         # Skills used this session (temp)
└── skills/
    └── [skill-name]/
        └── SKILL.md            # Learned preferences appended here
```

## Learning Target Logic

```
Is learning tied to a specific skill used this session?
├── Yes → Update that skill's SKILL.md
└── No → Does learning relate to existing skill by keywords?
    ├── Yes → Propose update, confirm with user
    └── No → Add to .claude/memories/general.md
```

## Key Rules

- Never overwrite existing skill content, only append to Learned Preferences section
- Always commit updates with clear messages
- Deduplicate learnings before adding
- Flag conflicts for manual review
- Respect retention settings for session cleanup
- Track which skills were used via .session-skills temp file
