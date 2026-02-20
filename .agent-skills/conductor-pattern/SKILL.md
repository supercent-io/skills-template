---
name: conductor-pattern
keyword: conductor
description: Run multiple AI agents (Claude/Codex/Gemini) in parallel using git worktree. Each agent works in an isolated sandbox branch, implements the same spec independently, then PRs are compared for the best implementation or cherry-picked for best-of-both.
allowed-tools: [Read, Write, Bash, Glob, Grep]
tags: [conductor, git-worktree, parallel-agents, claude-code, codex, tmux, pr-comparison, multi-agent, pipeline]
platforms: [Claude, Codex, Gemini, OpenCode]
version: 1.1.0
source: claude-code-docs/worktrees
---

# Conductor Pattern — Parallel AI Agent Execution (conductor)

> Keyword: `conductor`
>
> Run Claude + Codex + Gemini simultaneously on the same feature. Each agent works in an isolated git worktree branch. PRs are created per agent for comparison — cherry-pick the best of each.

## When to use this skill

- You want multiple AI agents to independently implement the same spec and compare results
- You want to reduce risk on a high-stakes refactor (if one agent fails, others succeed)
- You want parallel role separation: Claude for domain logic, Codex for tests/types, Gemini for docs
- You want CLI-based pipeline automation: check → agents → PR creation

---

## Architecture

```
repo-root/
  .git/                    # Shared git history
  src/ ...
  trees/                   # Per-agent worktrees (no conflicts)
    feat-x-claude/         # Claude sandbox
    feat-x-codex/          # Codex sandbox
    feat-x-gemini/         # Gemini sandbox (optional)
  scripts/
    conductor.sh           # Main orchestrator
    conductor-pr.sh        # Auto PR creation
    pipeline.sh            # Unified pipeline runner
    pipeline-check.sh      # Pre-flight checks
    lib/hooks.sh           # Hook system
```

---

## Quick Start

```bash
# Pre-flight check
bash scripts/pipeline-check.sh

# Run parallel agents (Claude + Codex by default)
bash scripts/conductor.sh my-feature main

# Run with 3 agents
bash scripts/conductor.sh my-feature main claude,codex,gemini

# Unified pipeline (check → agents → PR)
bash scripts/pipeline.sh my-feature --stages check,conductor,pr
```

---

## Step 1: Pre-flight Check

```bash
bash scripts/pipeline-check.sh
# Verifies: git, tmux, gh, jq, agent CLIs installed
```

---

## Step 2: Run Conductor

```bash
bash scripts/conductor.sh <feature-name> [base-branch] [agents]
```

**What it does:**
1. Creates `trees/feat-<name>-<agent>` worktrees
2. Creates isolated branches from base branch
3. Copies `.env` and common config files
4. Launches tmux sessions for each agent simultaneously
5. Each agent works independently (no conflicts)

**Flags:**
| Flag | Description |
|------|-------------|
| `--no-attach` | Don't attach to tmux session (for CI/non-interactive) |
| `--skip-hooks` | Skip all pre/post hooks |

---

## Step 3: Review in tmux

```bash
# Attach to tmux session
tmux attach-session -t conductor-<feature>

# Switch between agent panes
Ctrl+b, n  # Next pane
```

---

## Step 4: Auto-create PRs

```bash
bash scripts/conductor-pr.sh <feature-name> [base-branch]
```

Creates a PR per agent worktree. Commits any uncommitted changes automatically.

---

## Step 5: Compare & Merge Best

```bash
# List agent PRs
gh pr list --search "feat: <feature>"

# Create best-of-both branch
git checkout -b feat/<feature>-best main
git cherry-pick <claude-commit>   # UI structure
git cherry-pick <codex-commit>    # Tests/types
gh pr create -B main -H feat/<feature>-best
```

---

## Pipeline Mode

Run all stages in sequence:

```bash
bash scripts/pipeline.sh my-feature \
  --base main \
  --agents claude,codex \
  --stages check,conductor,pr
```

**Stages:** `check` → `plan` → `conductor` → `pr` → `copilot`

**Pipeline flags:**
| Flag | Description |
|------|-------------|
| `--base <branch>` | Base branch (default: main) |
| `--agents <list>` | Agent list (default: claude,codex) |
| `--stages <list>` | Stages to run |
| `--resume` | Resume from last failed stage |
| `--no-attach` | No tmux attach |
| `--dry-run` | Print stages without executing |
| `--skip-hooks` | Skip all hooks |

---

## Hook System

Pre/post hooks run at each stage. Create scripts in `scripts/hooks/`:

| Hook | Trigger | Behavior on failure |
|------|---------|---------------------|
| `pre-conductor.sh` | Before agent start | Abort if non-zero |
| `post-conductor.sh` | After agents complete | Warn only |
| `pre-pr.sh` | Before PR creation | Abort if non-zero |
| `post-pr.sh` | After each PR created | Warn only |

```bash
# Skip all hooks
CONDUCTOR_SKIP_HOOKS=1 bash scripts/conductor.sh my-feature

# Custom hooks directory
CONDUCTOR_HOOKS_DIR=/path/to/hooks bash scripts/conductor.sh my-feature
```

---

## Use Cases

| Scenario | Agent Config | Merge Strategy |
|----------|-------------|----------------|
| UI redesign | Claude (UI) + Codex (styling) | UI: Claude, style: Codex |
| API dev | Claude (business logic) + Codex (types/tests) | Logic: Claude, tests: Codex |
| Risk hedging | Claude + Codex (same spec) | Use successful version |
| Documentation | Gemini (docs) + Claude (examples) | Docs: Gemini, examples: Claude |

---

## Cleanup

```bash
git worktree list
git worktree remove trees/feat-<feature>-claude
git worktree remove trees/feat-<feature>-codex
git branch -d feat/<feature>-claude feat/<feature>-codex
```

---

## References

- [docs/conductor-pattern/README.md](docs/conductor-pattern/README.md)
- [scripts/conductor.sh](scripts/conductor.sh)
- [scripts/pipeline.sh](scripts/pipeline.sh)
- [Claude Code: Git worktrees guide](https://docs.anthropic.com/claude-code)
