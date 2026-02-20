---
name: plannotator
keyword: planno
description: Interactive plan and diff review for AI coding agents. Visual browser UI for annotating agent plans — approve or request changes with structured feedback. Supports code review, image annotation, and auto-save to Obsidian/Bear Notes.
allowed-tools: [Read, Bash, Write]
tags: [planno, plannotator, plan-review, diff-review, code-review, claude-code, opencode, annotation, visual-review]
platforms: [Claude, OpenCode, Codex, Gemini]
version: 0.8.2
source: backnotprop/plannotator
---

# plannotator — Interactive Plan & Diff Review (planno)

> Keyword: `planno` | Source: https://github.com/backnotprop/plannotator
>
> Annotate and review AI coding agent plans visually, share with your team, send feedback with one click.
> Works with **Claude Code** and **OpenCode**.

## When to use this skill

- You want to review an AI agent's implementation plan BEFORE it starts coding
- You want to annotate a git diff after the agent makes changes
- You need a feedback loop: visually mark up what to change, then send structured feedback back
- You want to share plan reviews with teammates via a link
- You want to auto-save approved plans to Obsidian or Bear Notes

---

## Step 1: Install Plannotator CLI

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
# IMPORTANT: Restart Claude Code after plugin install
```

### OpenCode

Add to `opencode.json`:

```json
{
  "plugin": ["@plannotator/opencode@latest"]
}
```

Then run the install script and restart OpenCode.

---

## Step 3: Plan Review (Before Coding)

When your agent finishes planning (Claude Code: `Shift+Tab×2` to enter plan mode), Plannotator automatically opens a browser UI:

1. **View** the agent's plan in the visual UI
2. **Annotate** with clear intent:
   - `delete` — remove risky or unnecessary step
   - `insert` — add missing step
   - `replace` — revise incorrect approach
   - `comment` — clarify constraints or acceptance criteria
3. **Submit** one outcome:
   - **Approve** → agent proceeds with implementation
   - **Request changes** → your annotations are sent back as structured feedback for replanning

---

## Step 4: Code Review (After Coding)

Run `/plannotator-review` to review git diffs with inline annotations:

```bash
/plannotator-review
```

- Select line numbers in the diff to annotate specific changes
- Switch between unified/split diff views
- Add image attachments with annotations (pen, arrow, circle tools)
- Send feedback directly to the agent

---

## Step 5: Auto-save & Sharing (Optional)

- **Obsidian** and **Bear Notes**: Approved plans are automatically saved
- **Share link**: Share a plan review session with teammates for collaboration

---

## Remote/Devcontainer Configuration

```bash
export PLANNOTATOR_REMOTE=1   # No auto browser open
export PLANNOTATOR_PORT=9999  # Fixed port
```

| Variable | Description |
|----------|-------------|
| `PLANNOTATOR_REMOTE` | Remote mode (no auto browser open) |
| `PLANNOTATOR_PORT` | Fixed local/forwarded port |
| `PLANNOTATOR_BROWSER` | Custom browser path/app |
| `PLANNOTATOR_SHARE_URL` | Custom share portal URL |

---

## Best Practices

1. Use plan review BEFORE the agent starts coding — catch wrong approaches early
2. Keep each annotation tied to one concrete, actionable change
3. Include acceptance criteria in "request changes" feedback
4. For diff review, annotate exact line ranges tied to expected behavior changes
5. Use image annotation for UI/UX feedback where text is insufficient

---

## References

- [GitHub: backnotprop/plannotator](https://github.com/backnotprop/plannotator)
- [Official site: plannotator.ai](https://plannotator.ai)
- [Detailed install: apps/hook/README.md](https://github.com/backnotprop/plannotator/blob/main/apps/hook/README.md)
