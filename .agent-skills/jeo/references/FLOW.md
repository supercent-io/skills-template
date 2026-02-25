# JEO Workflow — Detailed Reference

## Complete Execution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      JEO WORKFLOW                               │
│                                                                 │
│  [START] User activates "jeo" keyword with task description     │
│                          │                                      │
│          ┌───────────────▼──────────────────┐                  │
│          │         PHASE 1: PLAN             │                  │
│          │   ralph creates plan.md           │                  │
│          │   plannotator reviews visually    │                  │
│          │   ┌──────────────────────────┐   │                  │
│          │   │  Approve → continue      │   │                  │
│          │   │  Feedback → re-plan      │   │                  │
│          │   └──────────────────────────┘   │                  │
│          └───────────────┬──────────────────┘                  │
│                          │                                      │
│          ┌───────────────▼──────────────────┐                  │
│          │         PHASE 2: EXECUTE          │                  │
│          │                                   │                  │
│          │  team available?                  │                  │
│          │  ├─ YES: /omc:team N:executor    │                  │
│          │  │       staged pipeline          │                  │
│          │  └─ NO:  /bmad /workflow-init    │                  │
│          │          Analysis→Planning→       │                  │
│          │          Solutioning→Implementation│                 │
│          └───────────────┬──────────────────┘                  │
│                          │                                      │
│          ┌───────────────▼──────────────────┐                  │
│          │         PHASE 3: TRACK            │                  │
│          │   npx vibe-kanban (kanban UI)     │                  │
│          │   agent-browser → board update    │                  │
│          │   Cards: ToDo→InProgress→Done     │                  │
│          └───────────────┬──────────────────┘                  │
│                          │                                      │
│          ┌───────────────▼──────────────────┐                  │
│          │         PHASE 4: CLEANUP          │                  │
│          │   bash scripts/worktree-cleanup.sh│                  │
│          │   git worktree prune              │                  │
│          │   Remove vibe-kanban worktrees    │                  │
│          └───────────────┬──────────────────┘                  │
│                          │                                      │
│                       [DONE]                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Platform-Specific Execution Paths

### Claude Code (Primary)

```
jeo keyword detected
    │
    ├─ omc available? → /omc:team N:executor (team orchestration)
    │   ├─ team-plan: explore + planner agents
    │   ├─ team-prd: analyst agent
    │   ├─ team-exec: executor agents (parallel)
    │   ├─ team-verify: verifier + reviewers
    │   └─ team-fix: debugger/executor (loop until done)
    │
    └─ plannotator hook: ExitPlanMode → plannotator plan -
        └─ User reviews in browser UI
```

**State file**: `{worktree}/.omc/state/jeo-state.json`

### Codex CLI

```
/prompts:jeo activated
    │
    ├─ Plan: Write plan.md manually or via ralph prompt
    ├─ Execute: BMAD /workflow-init (no native team support)
    ├─ Track: agent-browser → vibe-kanban board
    └─ Cleanup: bash .agent-skills/jeo/scripts/worktree-cleanup.sh
```

**Config**: `~/.codex/config.toml` (developer_instructions)
**Prompt**: `~/.codex/prompts/jeo.md`

### Gemini CLI

```
gemini --approval-mode plan
    │
    ├─ Plan mode: write plan → exit → plannotator fires
    ├─ Execute: ohmg (bunx oh-my-ag) or BMAD /workflow-init
    ├─ Track: agent-browser → vibe-kanban
    └─ Cleanup: bash .agent-skills/jeo/scripts/worktree-cleanup.sh
```

**Config**: `~/.gemini/settings.json` (ExitPlanMode hook)
**Instructions**: `~/.gemini/GEMINI.md`

### OpenCode

```
/jeo-plan → /jeo-exec → /jeo-status → /jeo-cleanup
    │
    ├─ omx (oh-my-opencode): /omx:team N:executor "<task>"
    ├─ BMAD fallback: /workflow-init
    ├─ plannotator: /plannotator-review (code review)
    └─ Slash commands registered via opencode.json
```

**Config**: `opencode.json` (plugins + instructions)

---

## State Machine

```
States: plan → execute → track → cleanup → done
                                    ↑
Transitions:                        │
  plan     → execute  (plan approved)
  plan     → plan     (feedback received, re-plan)
  execute  → track    (tasks started in kanban)
  execute  → cleanup  (task complete, no kanban used)
  track    → cleanup  (all kanban cards Done)
  cleanup  → done     (worktrees removed, prune complete)
```

State persisted in: `.omc/state/jeo-state.json`

```json
{
  "phase": "plan",
  "task": "Implement user authentication",
  "plan_approved": false,
  "plan_path": ".omc/plans/jeo-plan.md",
  "team_available": true,
  "kanban_url": "http://localhost:3000",
  "worktrees": [".vibe-kanban/task-1", ".vibe-kanban/task-2"],
  "bmad_phase": null,
  "created_at": "2026-02-24T00:00:00Z",
  "updated_at": "2026-02-24T00:00:00Z",
  "cleanup_completed": false
}
```

---

## Team vs BMAD Decision Matrix

| Condition | Executor | Notes |
|-----------|----------|-------|
| Claude Code + omc + AGENT_TEAMS=1 | **team** | Best option — parallel staged pipeline |
| Claude Code + omc (no teams) | **ralph** | Single-agent loop with verification |
| Codex CLI | **BMAD** | Structured phases, no native team |
| Gemini CLI + ohmg | **ohmg** | Multi-agent via oh-my-ag |
| Gemini CLI (basic) | **BMAD** | Fallback structured workflow |
| OpenCode + omx | **omx team** | oh-my-opencode team orchestration |
| OpenCode (basic) | **BMAD** | Fallback structured workflow |

---

## agent-browser Kanban Interaction Pattern

```bash
# 1. Open kanban board
agent-browser open http://localhost:3000

# 2. Get accessibility snapshot to find card refs
agent-browser snapshot -i
# Output: @e1 (Add Task button), @e2 (card: Task A), @e3 (In Progress column), ...

# 3. Update card status (drag to In Progress)
agent-browser click @e2    # Select card
agent-browser drag @e2 @e3 # Drag to In Progress column

# 4. Check updated state
agent-browser snapshot -i

# 5. After task done — move to Done column
agent-browser drag @e4 @e5  # @e4=card, @e5=Done column
```

**MCP mode (preferred when available):**
```bash
npx vibe-kanban --mcp  # Start with MCP API
# Agent directly calls MCP endpoints to update card states
# No browser interaction needed
```

---

## Worktree Patterns Created by vibe-kanban

vibe-kanban creates worktrees with these patterns:
- `.vibe-kanban/<task-id>/`
- Path contains "vibe-kanban"
- Branch names: `task/*`, `agent/*`, `vibe-kanban-*`

The `worktree-cleanup.sh` script detects and removes all of these.

Manual cleanup if needed:
```bash
# List all worktrees
git worktree list

# Remove specific worktree
git worktree remove /path/to/worktree --force

# Prune stale references
git worktree prune

# Nuclear option (removes all non-main worktrees)
git worktree list | tail -n +2 | awk '{print $1}' | \
  xargs -I{} git worktree remove {} --force
git worktree prune
```

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable native team orchestration | `1` |
| `PLANNOTATOR_REMOTE` | Remote mode (no auto browser open) | unset |
| `PLANNOTATOR_PORT` | Fixed plannotator port | auto |
| `JEO_KANBAN_URL` | vibe-kanban board URL | `http://localhost:3000` |
| `JEO_MAX_ITERATIONS` | Max ralph loop iterations | `20` |
| `VIBE_KANBAN_REMOTE` | Remote kanban access | unset |

---

## Troubleshooting

### plannotator not opening on plan exit
```bash
# Check hook is configured
bash scripts/check-status.sh

# Re-run hook setup
bash scripts/setup-claude.sh  # or setup-gemini.sh

# Verify plannotator CLI is installed
which plannotator || plannotator --version
```

### team mode not working
```bash
# Ensure env variable is set
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

# Or add to ~/.claude/settings.json:
# "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" }

# Fall back to ralph:
/ralph "<task>" --max-iterations=20
```

### vibe-kanban port conflict
```bash
PORT=3001 npx vibe-kanban
export JEO_KANBAN_URL=http://localhost:3001
```

### worktree removal fails
```bash
# Force remove
git worktree remove /path/to/wt --force

# If git objects missing
git worktree prune --verbose

# Manual directory removal
rm -rf /path/to/worktree
git worktree prune
```
