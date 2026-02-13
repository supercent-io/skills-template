---
name: ralph-loop
description: Self-referential completion loop for OpenCode. Re-injects continuation prompts until the task is fully complete with a completion promise.
allowed-tools: [Read, Write, Bash, Grep, Glob]
tags: [opencode, ralph-loop, ultrawork, loop, completion]
platforms: [OpenCode, Claude, Gemini, Codex]
version: 1.0.0
source: sst/opencode + code-yeongyu/oh-my-opencode
---

# ralph-loop - Completion Enforcement Loop

## When to use this skill

- Long-running implementation tasks that tend to stop early
- Tasks that need strict completion signaling
- Workflows using `ultrawork` / `ulw` in OpenCode
- Sessions where the agent must continue until exact completion

---

## 1. Core Command Pattern

Use the built-in command form:

```text
/ralph-loop "<task description>" [--completion-promise=TEXT] [--max-iterations=N]
```

Defaults:
- Completion promise: `DONE`
- Max iterations: `100`

---

## 2. How the Loop Behaves

1. Starts with your task prompt.
2. On each idle cycle, verifies whether the assistant output contains:

```xml
<promise>DONE</promise>
```

3. If not found, injects a continuation prompt and increments iteration.
4. Stops only when:
   - Completion promise is detected, or
   - Max iterations is reached, or
   - You run `/cancel-ralph`.

---

## 3. Practical Usage

### Standard run

```text
/ralph-loop "Refactor auth module and finish all tests"
```

### Custom promise

```text
/ralph-loop "Migrate API clients to v2" --completion-promise=SHIP_IT
```

### Bounded iteration run

```text
/ralph-loop "Fix flaky CI tests" --max-iterations=20
```

### Cancel active loop

```text
/cancel-ralph
```

---

## 4. Integration Notes for skills-template

- Keep this skill as an operational guide for OpenCode workflows.
- Pair with orchestration skills (for example, `ohmg`) when tasks require delegation.
- Require explicit completion tags in final responses to avoid premature stop.

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start loop | `/ralph-loop "task"` |
| Custom promise | `/ralph-loop "task" --completion-promise=TEXT` |
| Iteration cap | `/ralph-loop "task" --max-iterations=N` |
| Cancel | `/cancel-ralph` |
