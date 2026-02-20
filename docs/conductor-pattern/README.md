# Conductor Pattern

## Overview

The Conductor Pattern uses `git worktree` to run multiple AI agents (Claude/Codex/Gemini) in parallel on the same feature spec, each in an isolated branch. Results are compared via PRs.

Each agent works independently in its own worktree, producing a branch that can be opened as a pull request. You review the PRs side by side and merge the best implementation — or cherry-pick across them.

---

## Prerequisites

- git (with worktree support)
- tmux
- gh CLI (for PR creation)
- At least one of: `claude`, `codex`, `gemini` CLI

---

## Quick Start

```bash
# 1. Pre-flight check
bash scripts/pipeline-check.sh --agents=claude,codex

# 2. Optional: run planno review first (independent step)
bash scripts/conductor-planno.sh my-feature main claude,codex

# 3. Or run directly
bash scripts/conductor.sh my-feature main claude,codex

# 4. Create PRs after agents finish
bash scripts/conductor-pr.sh my-feature main

# 5. Clean up
bash scripts/conductor-cleanup.sh my-feature
```

---

## Unified Pipeline

Run all stages in sequence with a single command:

```bash
# Full pipeline (check -> conductor -> PR)
bash scripts/pipeline.sh my-feature --stages check,conductor,pr

# With plan review
bash scripts/pipeline.sh my-feature --stages check,plan,conductor,pr

# Dry run (preview only)
bash scripts/pipeline.sh my-feature --dry-run

# Resume after failure
bash scripts/pipeline.sh --resume
```

### Pipeline Flags

| Flag | Description |
|------|-------------|
| `--base <branch>` | Base branch (default: main) |
| `--agents <list>` | Comma-separated agents (default: claude,codex) |
| `--stages <list>` | Stages to run: check,plan,conductor,pr,copilot |
| `--no-attach` | Don't attach to tmux (CI/non-interactive) |
| `--skip-hooks` | Bypass all hooks |
| `--dry-run` | Print stages without executing |
| `--resume` | Resume from last failed stage |

---

## Hooks System

Hooks in `scripts/hooks/` run automatically at each stage. Place executable shell scripts at the paths below to extend pipeline behavior.

| Event | File | Abort on Fail |
|-------|------|---------------|
| `pre-conductor` | `hooks/pre-conductor.sh` | Yes |
| `post-conductor` | `hooks/post-conductor.sh` | No (warning) |
| `pre-pr` | `hooks/pre-pr.sh` | Yes |
| `post-pr` | `hooks/post-pr.sh` | No |
| `pre-copilot` | `hooks/pre-copilot.sh` | Yes |
| `post-copilot` | `hooks/post-copilot.sh` | No |

Skip all hooks:

```bash
CONDUCTOR_SKIP_HOOKS=1 bash scripts/pipeline.sh ...
```

Custom hooks directory:

```bash
CONDUCTOR_HOOKS_DIR=/path/to/hooks bash scripts/pipeline.sh ...
```

---

## planno (plannotator) Integration — Optional

planno (plannotator) is a separate, independent skill for reviewing implementation plans visually before agents start coding. It can be used alongside Conductor, but each operates independently.

```bash
# Optional: review plan with planno first, then run conductor
bash scripts/conductor-planno.sh my-feature main claude,codex

# Or use them independently:
# 1. Use planno skill to review your plan:  planno로 구현 계획 검토해줘
# 2. Then run conductor separately:
bash scripts/conductor.sh my-feature main claude,codex
```

Install plannotator (only needed for the plan review step):

```bash
curl -fsSL https://plannotator.ai/install.sh | bash
```

---

## Feature Name Rules

Feature names are automatically normalized before use in branch and worktree names:

- Lowercase only
- Alphanumeric and hyphens only
- Example: `"My Feature 2.0"` → `"my-feature-2-0"`

---

## Worktree Structure

Each agent gets its own isolated workspace under `trees/`:

```
trees/
├── feat-my-feature-claude/    # Claude's isolated workspace
├── feat-my-feature-codex/     # Codex's isolated workspace
└── feat-my-feature-gemini/    # Gemini's isolated workspace
```

Each directory is a full git worktree on its own branch. Agents cannot interfere with each other's work.

---

## Pipeline State

State is saved to `.conductor-pipeline-state.json` after each stage completes. On failure, resume without re-running successful stages:

```bash
# Resume from the last failed stage
bash scripts/pipeline.sh --resume

# Or restart from a specific stage
bash scripts/pipeline.sh my-feature --stages pr
```
