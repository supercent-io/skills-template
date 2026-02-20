---
name: planview
description: Review AI agent plans and git diffs visually with Plannotator. Add inline annotations, approve or request revisions, and send structured feedback back to your coding agent.
allowed-tools: [Read, Bash, Write]
tags: [planview, plannotator, plan-review, code-review, claude-code, opencode]
platforms: [Claude, OpenCode, Codex, Gemini]
version: 0.1.0
source: backnotprop/plannotator
---

# planview - Visual Plan Review with Plannotator

Use this skill when the user asks to review a coding plan visually, annotate a diff with feedback, or run an approval loop before implementation.

## When to use this skill

- The user wants to review or refine an AI-generated implementation plan before coding starts
- The user asks for visual annotation of plans or diffs
- The user asks for a feedback loop: approve or request changes from the agent
- The user is using Claude Code or OpenCode and needs plannotator-based workflow guidance

---

## Step 1: Install Plannotator CLI

Install the `plannotator` command first:

```bash
# macOS / Linux / WSL
curl -fsSL https://plannotator.ai/install.sh | bash

# Windows PowerShell
irm https://plannotator.ai/install.ps1 | iex
```

---

## Step 2: Connect to Your Agent CLI

### Claude Code

```bash
/plugin marketplace add backnotprop/plannotator
/plugin install plannotator@plannotator
```

Restart Claude Code after plugin installation so hooks are applied.

### OpenCode

Add plugin:

```json
{
  "plugin": ["@plannotator/opencode@latest"]
}
```

Install command:

```bash
curl -fsSL https://plannotator.ai/install.sh | bash
```

Restart OpenCode after installation.

---

## Step 3: Run the Plan/Diff Review Loop

1. Ask your coding agent to produce a plan or create code changes.
2. Open plannotator review flow (`/plannotator-review` for diff review, or hook-based plan review).
3. Annotate with clear intent:
   - `delete`: remove risky or unnecessary step
   - `insert`: add missing step
   - `replace`: revise incorrect approach
   - `comment`: clarify constraints or acceptance criteria
4. Submit one of two outcomes:
   - **Approve**: implementation proceeds
   - **Request changes**: structured feedback returns to the agent for replanning

---

## Step 4: Remote/Devcontainer Configuration (Optional)

For remote sessions, set fixed port and remote mode:

```bash
export PLANNOTATOR_REMOTE=1
export PLANNOTATOR_PORT=9999
```

Useful environment variables:

- `PLANNOTATOR_REMOTE`: remote mode (no auto browser open)
- `PLANNOTATOR_PORT`: fixed local/forwarded port
- `PLANNOTATOR_BROWSER`: custom browser path/app
- `PLANNOTATOR_SHARE_URL`: custom share portal URL

---

## Best practices

1. Require explicit acceptance criteria in annotations (test/build/lint conditions).
2. Prefer small, actionable comments over broad rewrites.
3. For diff review, annotate exact line ranges tied to expected behavior changes.
4. Keep one decision per annotation to reduce ambiguity for the agent.
