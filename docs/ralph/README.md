# ralph — Completion Loop Guide

> **ralph** is a self-referential completion loop for AI CLI tools. It runs the agent on the same task across turns with fresh context each iteration, until the completion promise is detected or max iterations is reached.

← [Back to README](../../README.md)

---

## How It Works

Ralph intercepts the agent's exit via an `AfterAgent` hook, clears the context, and re-runs the same prompt — but file state persists. Each iteration starts fresh but builds on what previous iterations wrote to disk.

```
Iteration 1: Agent reads task → works → exits
AfterAgent hook: clears context, re-runs same prompt
Iteration 2: Agent reads task + sees file changes → continues → exits
... repeats until completion promise detected
```

---

## Usage

```bash
/ralph "<task>" [--completion-promise="DONE"] [--max-iterations=10]
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--completion-promise` | `"DONE"` | String the agent must output to signal completion |
| `--max-iterations` | `10` | Maximum number of iterations before stopping |

### Examples

```bash
# Simple task with default completion promise
/ralph "refactor the auth module"

# Custom completion signal
/ralph "implement the API endpoints" --completion-promise="ALL ENDPOINTS IMPLEMENTED"

# Limit iterations
/ralph "fix all TypeScript errors" --max-iterations=5 --completion-promise="0 errors"
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/ralph "<task>"` | Start a ralph loop |
| `/ralph:cancel` | Cancel the active loop |
| `/ralph:help` | Show help |

---

## Keyword Availability

| Keyword | Available In |
|---------|-------------|
| `ralph` | Gemini-CLI, OpenCode, oh-my-opencode, Claude Code |
| `ohmg` | Available when ralph is active |
| `omx` | Available when ralph is active |
| `bmad` | Available when ralph is active |
| `playwriter` | Available for browser verification |
| `agent-browser` | Available for headless verification |

---

## Prompt Best Practices

For best results, write prompts that:
1. **State the task clearly** — what needs to be done
2. **Specify the completion signal** — what output means "done"
3. **Reference file paths** — so each iteration knows what to look at

```bash
# Good: clear task + completion signal
/ralph "Fix all TypeScript errors in src/. Run tsc and show 0 errors." --completion-promise="0 errors"

# Good: iterative implementation
/ralph "Implement all TODO items in src/api.ts. Mark each as done when complete." --completion-promise="ALL TODOS COMPLETE"
```

---

## Installation

```bash
npx skills add https://github.com/supercent-io/skills-template --skill ralph
```

Source: [gemini-cli-extensions/ralph](https://github.com/gemini-cli-extensions/ralph)
