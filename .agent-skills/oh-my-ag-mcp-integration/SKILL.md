---
name: oh-my-ag-mcp-integration
description: Integrate oh-my-ag with MCP for ulw-style multi-agent workflows. Covers install, setup, bridge mode, and verification steps.
tags: [oh-my-ag, mcp, ulw, serena, bridge, antigravity, setup]
platforms: [Claude, Gemini, ChatGPT, Codex, Opencode]
---

# oh-my-ag MCP Integration

## When to use this skill

- You want to use `oh-my-ag` through MCP in a ulw workflow
- You need a reproducible installation/setup sequence
- You need bridge mode between stdio and HTTP/SSE
- You need quick verification for MCP readiness

## Instructions

### Step 1: Install prerequisites

- Install `bun`
- Install `uv`
- Authenticate at least one CLI (`gemini`, `claude`, `codex`, or `qwen`)

### Step 2: Install oh-my-ag in the target project

```bash
bunx oh-my-ag
```

This installs `.agent/skills`, `.agent/workflows`, and default config for the target workspace.

### Step 3: Run setup workflow

In your agent chat:

```text
/setup
```

Setup checks CLI availability and MCP connection status.

### Step 4: Configure transport mode

Use one of:

- Command mode: MCP server runs per session
- SSE mode: MCP server shared via URL

If your IDE path requires bridging, run:

```bash
bunx oh-my-ag bridge http://localhost:12341/sse
```

### Step 5: Verify health

```bash
bunx oh-my-ag doctor
```

Pass criteria:

- Required CLI is detected
- MCP target is reachable/configured
- No critical setup warnings

## Output format

Provide:

1. Installation commands executed
2. Selected MCP mode (command or SSE)
3. Verification result from `doctor`
4. Any blocking issue and exact fix command

## Constraints

### MUST

1. Run install from project root
2. Use `/setup` before execution workloads
3. Run `doctor` after configuration

### MUST NOT

1. Do not skip MCP verification
2. Do not assume bridge mode is always required

## References

- `oh-my-ag` README: https://github.com/first-fluke/oh-my-ag
- Integration guide: https://github.com/first-fluke/oh-my-ag/blob/main/web/content/en/guide/integration.md
