# Vibe Kanban

A visual Kanban board for managing AI coding agents. Tasks move through stages — To Do → In Progress → Review → Done — with AI agents automatically assigned to and executing tasks.

---

## Overview

Vibe Kanban provides a browser-based board that coordinates one or more AI agents (Claude, Codex, Gemini) across a set of task cards. Each card represents a discrete unit of work. When an agent is assigned to a card, it picks up the task, executes it in an isolated environment, and advances the card through the pipeline on completion.

Key capabilities:

- Visual progress tracking across a sprint or feature set
- Parallel agent execution on independent tasks
- Git worktree isolation per task card
- Automatic PR creation on task completion
- planview integration for epic-level review before card creation

---

## Installation

No global install is required. Run directly with `npx`:

```bash
# Run directly (no install needed)
npx vibe-kanban

# Or use the wrapper script
bash scripts/vibe-kanban-start.sh

# With custom port
bash scripts/vibe-kanban-start.sh --port 3001
```

After starting, the board is available at `http://localhost:3000` (or your configured port).

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `VIBE_KANBAN_PORT` | Server port | `3000` |
| `VIBE_KANBAN_REMOTE` | Allow remote connections | `false` |
| `ANTHROPIC_API_KEY` | For Claude-powered tasks | — |
| `OPENAI_API_KEY` | For GPT-powered tasks | — |

Set variables in your shell or in a `.env` file at the project root before starting the server.

---

## Workflow

### 1. Install and Start

```bash
npx vibe-kanban
```

Opens the board at `http://localhost:3000`.

### 2. Plan Review with planview

Before creating individual task cards, review the epic breakdown using planview:

```text
planview로 이 기능의 구현 계획을 검토해줘
```

planview breaks the feature spec into an ordered set of sub-tasks. Review and adjust the plan, then approve it. Approved specs become the source of truth for card creation.

### 3. Create Tasks

Add task cards to the **To Do** column. Each card should represent a single, atomic unit of work derived from the approved planview spec.

### 4. Assign Agents

Click a task card and select an AI agent from the assignment panel:

- **Claude** — via `ANTHROPIC_API_KEY`
- **Codex** — via `OPENAI_API_KEY`
- **Gemini** — via Google credentials

### 5. Auto-execution

The assigned agent picks up the task and the card moves to **In Progress** automatically. The agent works inside an isolated git worktree (see below) and reports progress back to the board.

### 6. Review

When the agent completes work, a PR is created and the card moves to **Review**. Open the PR link from the card detail view to inspect the diff.

### 7. Merge

Approve and merge the PR. The card advances to **Done**.

---

## planview Integration

planview is an epic-level planning step that sits before card creation. It prevents scope creep and ensures each card maps to a well-defined deliverable.

Typical flow:

1. Describe the feature or epic in natural language.
2. Ask planview to decompose it: `planview로 이 기능의 구현 계획을 검토해줘`
3. Review the generated breakdown — adjust ordering, scope, or dependencies.
4. Approve the plan.
5. Create one card per approved sub-task.

Skipping planview is fine for small, self-contained tasks. For larger features with multiple moving parts, planview significantly reduces rework.

---

## Git Worktree Integration

Each task card can optionally operate in an isolated git worktree:

- **Card created** — a worktree is auto-generated from the current branch at `worktrees/<card-id>/`.
- **Agent works in isolation** — changes do not affect the main working tree or other cards.
- **PR created on completion** — the agent commits work, pushes to a feature branch, and opens a PR.
- **Worktree cleaned up** — after the PR is merged, the worktree is removed automatically.

This isolation means multiple agents can work on different cards simultaneously without conflicting file edits.

---

## Use Cases

- **Parallel feature development** — assign different agents to independent feature cards and let them run concurrently.
- **Sprint tracking** — visualize all in-flight AI tasks across a team in one board.
- **Implementation comparison** — create two cards for the same problem, assign different agents, and compare the resulting PRs.
- **Team coordination** — multiple developers each manage their own agent assignments from a shared board view when `VIBE_KANBAN_REMOTE=true`.

---

## Tips

- Keep card scope narrow. One card = one commit-worthy change. Broad cards lead to large, hard-to-review PRs.
- Use planview for any feature touching more than two files.
- Set `VIBE_KANBAN_REMOTE=true` only on trusted networks — it exposes the board and agent controls to all connections on the port.
- If an agent stalls on a card, reassign to a different agent or break the card into smaller pieces.
