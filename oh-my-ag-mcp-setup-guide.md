# oh-my-ag MCP Integration Guide (for ulw)

This guide shows how to install and configure `oh-my-ag` so it can be used through MCP in a `ulw` workflow.

## 1) Prerequisites

- `bun` installed
- `uv` installed
- One CLI authenticated (`gemini`, `claude`, `codex`, or `qwen`)

## 2) Install oh-my-ag

Run in your target project root:

```bash
bunx oh-my-ag
```

Then run setup inside your agent environment:

```text
/setup
```

`/setup` checks CLI installation, MCP connection status, and vendor mapping.

## 3) MCP Connection Mode

Use one of these two modes:

- Command mode: spawn Serena MCP per session
- SSE mode: shared Serena server

If your environment needs stdio-to-http bridging (for example Antigravity IDE path), use:

```bash
bunx oh-my-ag bridge http://localhost:12341/sse
```

## 4) Verify

```bash
bunx oh-my-ag doctor
```

You should confirm MCP status for your configured CLI(s).

## 5) Install this skill from skills-template

Install only this skill:

```bash
npx skills add https://github.com/supercent-io/skills-template --skill oh-my-ag-mcp-integration
```

Install with related skills:

```bash
npx skills add https://github.com/supercent-io/skills-template --skill oh-my-ag-mcp-integration --skill opencode-authentication --skill agentic-workflow
```

## 6) Minimal ulw flow

1. `bunx oh-my-ag` in project root
2. `/setup`
3. `bunx oh-my-ag doctor`
4. If needed, `bunx oh-my-ag bridge ...`
5. Start ulw task with MCP-enabled environment
