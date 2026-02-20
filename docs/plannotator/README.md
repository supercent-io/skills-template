# plannotator — AI Review Tool

> Keyword: `planno` (formerly `planview`)

Visual plan and diff review using Plannotator. Add inline annotations, approve or request revisions, and send structured feedback back to your coding agent.

## Classification: AI Review Tools

plannotator is part of the **AI Review Tools** family alongside:
- `kanbanview` (vibe-kanban) — Kanban-based visual agent management
- `copilotview` (copilot-coding-agent) — GitHub Copilot PR review

## Quick Start

```bash
# macOS / Linux / WSL
curl -fsSL https://plannotator.ai/install.sh | bash

# Claude Code plugin
/plugin marketplace add backnotprop/plannotator
/plugin install plannotator@plannotator
```

## Keyword Activation

```text
planno로 이번 구현 계획을 검토하고 수정 코멘트를 만들어줘.
```

## Usage: Plan Review Loop

1. Ask your coding agent to produce a plan (Claude Code: Shift+Tab×2)
2. Open plannotator review: `/plannotator-review`
3. Annotate with clear intent:
   - `delete`: remove risky or unnecessary step
   - `insert`: add missing step
   - `replace`: revise incorrect approach
   - `comment`: clarify constraints or acceptance criteria
4. Submit outcome:
   - **Approve**: implementation proceeds
   - **Request changes**: structured feedback returns to agent

## Usage: Diff Review

```bash
# Review after agent creates changes
plannotator review --branch <branch-name>
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `PLANNOTATOR_REMOTE` | Remote mode (no auto browser open) |
| `PLANNOTATOR_PORT` | Fixed local/forwarded port |
| `PLANNOTATOR_BROWSER` | Custom browser path |
| `PLANNOTATOR_SHARE_URL` | Custom share portal URL |

## Integration with AI Review Tools

### With kanbanview (vibe-kanban)
```
[Epic 분해 계획] → [planno 검토/승인] → [kanbanview 태스크 생성] → [In Progress] → [planno diff 검토] → [PR]
```

### With copilotview (copilot-coding-agent)
```
[이슈 스펙 작성] → [planno 검토/승인] → [copilotview로 Copilot 할당] → [Draft PR] → [planno diff 검토] → [Merge]
```

## Best Practices

1. Require explicit acceptance criteria in annotations
2. Prefer small, actionable comments over broad rewrites
3. For diff review, annotate exact line ranges
4. Keep one decision per annotation

## References

- [Plannotator official](https://plannotator.ai)
- [Claude Code plugin](https://github.com/backnotprop/plannotator)
