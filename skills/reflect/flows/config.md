# Config Flow

Handles `/reflect config`, `/reflect dispatch`, `/reflect intent`, `/reflect on`, and `/reflect off` commands.

---

## `/reflect config`

Show current configuration.

**Output:**

```markdown
## Reflect Configuration

### Task Management
| Setting | Value | Allowed Values | Description |
|---------|-------|----------------|-------------|
| lockTimeout | 3600 | 60-86400 (seconds) | Seconds before task lock is stale |
| allowManualUnlock | true | true, false | Allow /reflect unlock |
| maxParallelAgents | 3 | 1-10 | Max concurrent task locks |
| autoAssignNextTask | true | true, false | Auto-suggest next task |

### Session Management
| Setting | Value | Allowed Values | Description |
|---------|-------|----------------|-------------|
| sessionStaleTimeout | 86400 | 3600-604800 (seconds) | Seconds before session is stale |
| maxContextTokens | 200000 | 50000-500000 | Total context budget |
| targetResumeTokens | 8000 | 2000-50000 | Target for resume context |
| warningThreshold | 150000 | 50000-400000 | Warn when context exceeds |

### Intelligent Dispatch
| Setting | Value | Allowed Values | Description |
|---------|-------|----------------|-------------|
| dispatch.enabled | true | true, false | Automatic sub-agent dispatch |
| dispatch.mode | automatic | automatic, confirm | Spawns without confirmation |
| dispatch.maxParallelAgents | 3 | 1-10 | Max concurrent sub-agents |
| intentDetection.enabled | true | true, false | Natural language intent detection |
| intentDetection.mode | suggest | suggest, off | Suggests skills, waits for confirm |
| intentDetection.confidenceThreshold | 0.7 | 0.5-1.0 | Min confidence to suggest |

### Auto-Reflection
| Setting | Value | Allowed Values |
|---------|-------|----------------|
| enabled | off | on, off |
| approvalMode | batch | batch, individual |

Use `/reflect config dispatch` or `/reflect config intent` for detailed settings.
```

---

## `/reflect config <key> <value>`

Update a configuration setting.

**Examples:**

```
/reflect config lockTimeout 1800           # 30 minute lock timeout
/reflect config sessionStaleTimeout 43200  # 12 hour session timeout
/reflect config maxParallelAgents 5        # Allow 5 concurrent workers
/reflect config autoAssignNextTask false
```

---

## `/reflect config dispatch`

Show dispatch configuration.

**Output:**

```markdown
## Dispatch Configuration

| Setting | Value | Allowed Values | Description |
|---------|-------|----------------|-------------|
| enabled | true | true, false | Automatic dispatch active |
| mode | automatic | automatic, confirm | Spawns agents without confirmation |
| maxParallelAgents | 3 | 1-10 | Max concurrent sub-agents |

### Trigger Points
| Trigger | Enabled | Allowed Values |
|---------|---------|----------------|
| onResume | true | true, false |
| onTaskComplete | true | true, false |
| onFeatureComplete | true | true, false |

### Task Registry Settings
| Setting | Value | Allowed Values |
|---------|-------|----------------|
| enabled | true | true, false |
| minReadyTasks | 2 | 1-10 |
| respectPriority | true | true, false |
| scopeConflictBehavior | skip | skip, warn, block |

### Feature Database Settings
| Setting | Value | Allowed Values |
|---------|-------|----------------|
| enabled | true | true, false |
| categoryMatrix | default | default, strict, permissive |
| regressionStrategy | shared | shared, independent |
| criticalCategories | A, P | A-T (comma-separated) |
```

---

## `/reflect config intent`

Show intent detection configuration.

**Output:**

```markdown
## Intent Detection Configuration

| Setting | Value | Allowed Values | Description |
|---------|-------|----------------|-------------|
| enabled | true | true, false | Pattern matching active |
| mode | suggest | suggest, off | Asks before invoking skill |
| confidenceThreshold | 0.7 | 0.5-1.0 | Minimum confidence to suggest |

### Skill Detection
| Category | Enabled | Allowed Values |
|----------|---------|----------------|
| framework | true | true, false |
| superpowers | true | true, false |

### Excluded Patterns (editable via config)
- "how do I"
- "what is"
- "explain"
- "show me"

### Statistics (this session)
| Metric | Value |
|--------|-------|
| Suggestions shown | 3 |
| Suggestions accepted | 2 |
| Acceptance rate | 66.7% |
```

---

## `/reflect config --preset <name>`

Apply a preset configuration.

**Available Presets:**

| Preset | Description | Dispatch Mode | Max Agents | Confidence |
|--------|-------------|---------------|------------|------------|
| `careful` | New projects | confirm | 2 | 0.8 |
| `balanced` | Normal use | automatic | 3 | 0.7 |
| `aggressive` | Large projects | automatic | 5 | 0.6 |

**Example:**

```
/reflect config --preset balanced
```

**Output:**

```markdown
## Applied Preset: balanced

Updated settings:
- dispatch.mode: automatic
- dispatch.maxParallelAgents: 3
- intentDetection.confidenceThreshold: 0.7

Configuration saved to `.claude/memories/.dispatch-config.json`
```

---

## `/reflect dispatch on`

Enable automatic sub-agent dispatch.

**Flow:**

1. Set `dispatch.enabled = true` in config
2. Confirm change

**Output:**

```markdown
## Dispatch Enabled

Automatic sub-agent dispatch is now **enabled**.

When you resume tasks or complete work, the system will:
- Analyze task dependencies for parallelizable work
- Spawn sub-agents based on dispatch.mode setting
- Current mode: automatic (will spawn without confirmation)

Use `/reflect dispatch off` to disable.
```

---

## `/reflect dispatch off`

Disable automatic sub-agent dispatch.

**Output:**

```markdown
## Dispatch Disabled

Automatic sub-agent dispatch is now **disabled**.

Tasks will be executed sequentially by the main agent.
Use `/reflect dispatch on` to re-enable.
```

---

## `/reflect intent on`

Enable intent detection.

**Output:**

```markdown
## Intent Detection Enabled

Natural language intent detection is now **enabled**.

When you send a message, the system will:
- Check for patterns matching known skills
- Suggest appropriate skill if confidence >= 0.7
- Wait for your confirmation before invoking

Use `/reflect intent off` to disable.
```

---

## `/reflect intent off`

Disable intent detection.

**Output:**

```markdown
## Intent Detection Disabled

Natural language intent detection is now **disabled**.

To invoke skills, use explicit commands:
- `/new-feature <description>`
- `/fix-bug <description>`
- `/refactor <description>`
- etc.

Use `/reflect intent on` to re-enable.
```

---

## `/reflect on`

Enable auto-reflection at session end.

**Flow:**
1. Set enabled to `on` in `.claude/memories/.reflect-status`
2. Confirm change

---

## `/reflect off`

Disable auto-reflection.

**Flow:**
1. Set enabled to `off` in `.claude/memories/.reflect-status`
2. Confirm change

---

## Dispatch Configuration Settings

Update dispatch settings with `/reflect config <key> <value>`:

```
# Enable/disable dispatch
/reflect config dispatch.enabled true
/reflect config dispatch.enabled false

# Set dispatch mode
/reflect config dispatch.mode automatic    # Spawn without asking
/reflect config dispatch.mode confirm      # Ask before spawning

# Set max parallel agents
/reflect config dispatch.maxParallelAgents 5

# Configure trigger points
/reflect config dispatch.triggerPoints.onResume true
/reflect config dispatch.triggerPoints.onTaskComplete true
/reflect config dispatch.triggerPoints.onFeatureComplete false

# Task registry settings
/reflect config dispatch.taskRegistry.enabled true
/reflect config dispatch.taskRegistry.minReadyTasks 3

# Feature database settings
/reflect config dispatch.featureDatabase.regressionStrategy independent
/reflect config dispatch.featureDatabase.criticalCategories ["A", "P", "L"]
```

---

## Intent Detection Configuration Settings

Update intent detection settings with `/reflect config <key> <value>`:

```
# Enable/disable intent detection
/reflect config intentDetection.enabled true
/reflect config intentDetection.enabled false

# Set mode
/reflect config intentDetection.mode suggest   # Suggest and confirm
/reflect config intentDetection.mode off       # Disable completely

# Set confidence threshold
/reflect config intentDetection.confidenceThreshold 0.8   # More conservative
/reflect config intentDetection.confidenceThreshold 0.6   # More suggestions

# Enable/disable skill categories
/reflect config intentDetection.skills.framework true
/reflect config intentDetection.skills.superpowers false

# Add exclusion pattern
/reflect config intentDetection.excludePatterns.add "tell me about"
```
