---
name: agentation
keyword: agentation
description: Visual UI annotation tool for AI agents. Drop the React toolbar into any app — humans click elements and leave feedback, agents receive structured CSS selectors, bounding boxes, and React component trees to find exact code. Supports MCP watch-loop, platform-specific hooks (Claude Code / Codex / Gemini CLI / OpenCode), webhook delivery, and autonomous self-driving critique with agent-browser.
allowed-tools: [Read, Write, Bash, Grep, Glob]
tags: [ui-feedback, browser-annotation, visual-feedback, mcp, react, ai-agent, design-review, css-selector]
platforms: [Claude Code, Codex, Gemini CLI, OpenCode, Cursor, Windsurf, ChatGPT]
version: 1.0.0
source: benjitaylor/agentation
compatibility: React 18+, Node.js 18+
---

# agentation — Visual UI Feedback Bridge for AI Agents

> **The missing link between human eyes and agent code.**
>
> Instead of describing "the blue button in the sidebar," you hand the agent `.sidebar > button.primary`. It can `grep` for that directly.

---

## When to use this skill

- Human needs to point at a UI element and give feedback — without writing selectors
- Running iterative UI/UX review cycles between human and coding agent
- Building a watch-loop where agent auto-fixes every annotation a human leaves
- Capturing CSS selectors, bounding boxes, and React component trees for precise code targeting
- Autonomous design critique via `agent-browser` + self-driving pattern
- Integrating visual feedback into agent hooks so annotations auto-appear in agent context

---

## 1. Architecture

```
agentation (monorepo)
├── agentation          → npm: agentation (React toolbar component)
│   └── src/index.ts   → exports Agentation component + types + utilities
└── agentation-mcp      → npm: agentation-mcp (MCP server + CLI)
    ├── src/cli.ts      → agentation-mcp CLI (init, server, doctor)
    └── src/server/     → HTTP REST API (port 4747) + SSE events + MCP stdio tools
```

**Two modes of operation:**

| Mode | How it works |
|------|-------------|
| **Copy-Paste** | Human annotates → clicks Copy → pastes markdown into agent chat |
| **Agent Sync** | `endpoint` prop connects toolbar to MCP server → agent uses `agentation_watch_annotations` loop |

---

## 2. Installation

```bash
# React toolbar (dev dependency)
npm install agentation -D
# or
pnpm add agentation -D

# MCP server (for agent integration)
npm install agentation-mcp -D
# or
pnpm add agentation-mcp -D
```

**Requirements**: React 18+, Node.js 18+, desktop browser (no mobile support)

---

## 3. React Component Setup

### Basic (Copy-Paste mode — no server needed)

```tsx
import { Agentation } from 'agentation';

function App() {
  return (
    <>
      <YourApp />
      {process.env.NODE_ENV === 'development' && <Agentation />}
    </>
  );
}
```

### Next.js App Router

```tsx
// app/layout.tsx
import { Agentation } from 'agentation';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        {children}
        {process.env.NODE_ENV === 'development' && (
          <Agentation endpoint="http://localhost:4747" />
        )}
      </body>
    </html>
  );
}
```

### Next.js Pages Router

```tsx
// pages/_app.tsx
import { Agentation } from 'agentation';

export default function App({ Component, pageProps }) {
  return (
    <>
      <Component {...pageProps} />
      {process.env.NODE_ENV === 'development' && (
        <Agentation endpoint="http://localhost:4747" />
      )}
    </>
  );
}
```

### Full Props Reference

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `endpoint` | `string` | — | MCP server URL for Agent Sync mode |
| `sessionId` | `string` | — | Pre-existing session ID to join |
| `onAnnotationAdd` | `(a: Annotation) => void` | — | Callback when annotation created |
| `onAnnotationDelete` | `(a: Annotation) => void` | — | Callback when annotation deleted |
| `onAnnotationUpdate` | `(a: Annotation) => void` | — | Callback when annotation edited |
| `onAnnotationsClear` | `(a: Annotation[]) => void` | — | Callback when all cleared |
| `onCopy` | `(markdown: string) => void` | — | Callback with markdown on copy |
| `onSubmit` | `(output: string, annotations: Annotation[]) => void` | — | On "Send Annotations" click |
| `copyToClipboard` | `boolean` | `true` | Set false to suppress clipboard write |
| `onSessionCreated` | `(sessionId: string) => void` | — | Called on new session creation |
| `webhookUrl` | `string` | — | Webhook URL to receive annotation events |

---

## 4. MCP Server Setup — All Platforms

> **Start the server first** before configuring any agent:
> ```bash
> npx agentation-mcp server          # HTTP :4747 + MCP stdio
> npx agentation-mcp server --port 8080   # custom port
> npx agentation-mcp doctor          # verify setup
> ```

---

### Claude Code (`.claude/`)

**Option A — CLI (recommended):**
```bash
claude mcp add agentation -- npx -y agentation-mcp server
```

**Option B — config file** (`~/.claude/claude_desktop_config.json` for global, or `.claude/mcp.json` for project-level):
```json
{
  "mcpServers": {
    "agentation": {
      "command": "npx",
      "args": ["-y", "agentation-mcp", "server"]
    }
  }
}
```

**Interactive wizard (Claude Code only):**
```bash
npx agentation-mcp init
```

**UserPromptSubmit hook** — auto-inject pending annotations on every message.
Add to `.claude/settings.json` (project) or `~/.claude/settings.json` (global):
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "curl -sf --connect-timeout 1 http://localhost:4747/pending 2>/dev/null | python3 -c \"import sys,json;d=json.load(sys.stdin);c=d['count'];exit(0)if c==0 else[print(f'\\n=== AGENTATION: {c} UI annotations ===\\n'),*[print(f\\\"[{i+1}] {a['element']} ({a['elementPath']})\\n    {a['comment']}\\n\\\")for i,a in enumerate(d['annotations'])],print('=== END ===\\n')]\" 2>/dev/null;exit 0"
      }
    ]
  }
}
```

---

### Codex CLI (`~/.codex/`)

Add to `~/.codex/config.toml`:

```toml
# Agentation MCP Server
[[mcp_servers]]
name = "agentation"
command = "npx"
args = ["-y", "agentation-mcp", "server"]

# Optional: teach Codex about watch-loop
developer_instructions = """
When user says "watch mode" or "agentation watch", call agentation_watch_annotations in a loop.
For each annotation: acknowledge it, fix the code using the elementPath CSS selector, resolve with summary.
"""
```

Restart Codex CLI after editing `config.toml`.

---

### Gemini CLI (`~/.gemini/`)

**Option A — CLI:**
```bash
gemini mcp add agentation npx -y agentation-mcp server
# or with explicit scope
gemini mcp add -s user agentation npx -y agentation-mcp server
```

**Option B — config file** (`~/.gemini/settings.json` for global, `.gemini/settings.json` for project):
```json
{
  "mcpServers": {
    "agentation": {
      "command": "npx",
      "args": ["-y", "agentation-mcp", "server"]
    }
  }
}
```

**AfterAgent hook** — trigger annotation check after each agent turn:
```json
{
  "mcpServers": {
    "agentation": {
      "command": "npx",
      "args": ["-y", "agentation-mcp", "server"]
    }
  },
  "hooks": {
    "AfterAgent": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "curl -sf --connect-timeout 1 http://localhost:4747/pending 2>/dev/null | python3 -c \"import sys,json;d=json.load(sys.stdin);c=d.get('count',0);[print(f'[agentation] {c} pending annotations'),exit(1)]if c>0 else exit(0)\" 2>/dev/null;exit 0",
            "description": "Check for pending agentation annotations"
          }
        ]
      }
    ]
  }
}
```

---

### OpenCode (`~/.config/opencode/`)

Add to `~/.config/opencode/opencode.json`:

```json
{
  "mcp": {
    "agentation": {
      "type": "local",
      "command": ["npx", "-y", "agentation-mcp", "server"]
    }
  }
}
```

With environment variables:
```json
{
  "mcp": {
    "agentation": {
      "type": "local",
      "command": ["npx", "-y", "agentation-mcp", "server"],
      "environment": {
        "AGENTATION_STORE": "sqlite",
        "AGENTATION_EVENT_RETENTION_DAYS": "7"
      }
    }
  }
}
```

Restart OpenCode after editing. MCP tools (`agentation_*`) will be available immediately.

---

### Universal (npx add-mcp)

Works for any MCP-compatible agent:
```bash
npx add-mcp "npx -y agentation-mcp server"
```

---

### Quick-Setup Script

Save and run `bash setup-agentation-mcp.sh [--all | --claude | --codex | --gemini | --opencode]`:

```bash
#!/usr/bin/env bash
# setup-agentation-mcp.sh — Register agentation MCP for all agent platforms

set -euo pipefail
SETUP_CLAUDE=false; SETUP_CODEX=false; SETUP_GEMINI=false; SETUP_OPENCODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --claude) SETUP_CLAUDE=true ;;
    --codex) SETUP_CODEX=true ;;
    --gemini) SETUP_GEMINI=true ;;
    --opencode) SETUP_OPENCODE=true ;;
    --all) SETUP_CLAUDE=true; SETUP_CODEX=true; SETUP_GEMINI=true; SETUP_OPENCODE=true ;;
  esac
  shift
done
[[ "$SETUP_CLAUDE$SETUP_CODEX$SETUP_GEMINI$SETUP_OPENCODE" == "falsefalsefalsefalse" ]] && \
  SETUP_CLAUDE=true && SETUP_CODEX=true && SETUP_GEMINI=true && SETUP_OPENCODE=true

MCP_JSON='"agentation": {"command": "npx", "args": ["-y", "agentation-mcp", "server"]}'

# Claude Code
if [[ "$SETUP_CLAUDE" == "true" ]]; then
  mkdir -p ~/.claude
  CFG=~/.claude/claude_desktop_config.json
  if [[ -f "$CFG" ]] && command -v jq &>/dev/null; then
    jq ".mcpServers += {$MCP_JSON}" "$CFG" > "$CFG.tmp" && mv "$CFG.tmp" "$CFG"
  else
    echo "{\"mcpServers\": {$MCP_JSON}}" > "$CFG"
  fi
  echo "✅ Claude Code: $CFG"
fi

# Codex CLI
if [[ "$SETUP_CODEX" == "true" ]]; then
  mkdir -p ~/.codex
  CFG=~/.codex/config.toml
  if ! grep -q "agentation" "$CFG" 2>/dev/null; then
    printf '\n[[mcp_servers]]\nname = "agentation"\ncommand = "npx"\nargs = ["-y", "agentation-mcp", "server"]\n' >> "$CFG"
  fi
  echo "✅ Codex CLI: $CFG"
fi

# Gemini CLI
if [[ "$SETUP_GEMINI" == "true" ]]; then
  mkdir -p ~/.gemini
  CFG=~/.gemini/settings.json
  if [[ -f "$CFG" ]] && command -v jq &>/dev/null; then
    jq ".mcpServers += {$MCP_JSON}" "$CFG" > "$CFG.tmp" && mv "$CFG.tmp" "$CFG"
  else
    echo "{\"mcpServers\": {$MCP_JSON}}" > "$CFG"
  fi
  echo "✅ Gemini CLI: $CFG"
fi

# OpenCode
if [[ "$SETUP_OPENCODE" == "true" ]]; then
  mkdir -p ~/.config/opencode
  CFG=~/.config/opencode/opencode.json
  ENTRY='"agentation": {"type": "local", "command": ["npx", "-y", "agentation-mcp", "server"]}'
  if [[ -f "$CFG" ]] && command -v jq &>/dev/null; then
    jq ".mcp += {$ENTRY}" "$CFG" > "$CFG.tmp" && mv "$CFG.tmp" "$CFG"
  else
    echo "{\"mcp\": {$ENTRY}}" > "$CFG"
  fi
  echo "✅ OpenCode: $CFG"
fi

echo ""
echo "Done. Restart your agent(s) and run: npx agentation-mcp server"
```

---

## 5. MCP Tools (Agent API)

| Tool | Parameters | Description |
|------|-----------|-------------|
| `agentation_list_sessions` | none | List all active annotation sessions |
| `agentation_get_session` | `sessionId: string` | Get session with all annotations |
| `agentation_get_pending` | `sessionId: string` | Get pending annotations for a session |
| `agentation_get_all_pending` | none | Get pending annotations across ALL sessions |
| `agentation_acknowledge` | `annotationId: string` | Mark annotation as acknowledged (agent is working on it) |
| `agentation_resolve` | `annotationId: string, summary?: string` | Mark as resolved with optional summary |
| `agentation_dismiss` | `annotationId: string, reason: string` | Dismiss with required reason |
| `agentation_reply` | `annotationId: string, message: string` | Add reply to annotation thread |
| `agentation_watch_annotations` | `sessionId?: string, batchWindowSeconds?: number (default 10, max 60), timeoutSeconds?: number (default 120, max 300)` | **Block until new annotations arrive** — core watch-loop tool |

---

## 6. Workflow Patterns

### Pattern 1: Copy-Paste (Simplest, No Server)

```
1. Human opens app in browser
2. Clicks agentation toolbar → activates
3. Clicks element → adds comment → clicks Copy
4. Pastes markdown output into agent chat
5. Agent receives CSS selectors, elementPath, boundingBox
6. Agent greps/edits code using selector
```

### Pattern 2: MCP Watch Loop (Recommended for iterative review)

```
Agent: agentation_watch_annotations (blocks up to 120s)
  → Human adds annotation in browser
  → Agent receives batch immediately
  → Agent: agentation_acknowledge(annotationId)
  → Agent makes code changes using elementPath as grep target
  → Agent: agentation_resolve(annotationId, "Changed button color to #3b82f6")
  → Agent: agentation_watch_annotations (loops again)
```

**CLAUDE.md / GEMINI.md / Codex developer_instructions — add for automated watch:**

```markdown
When I say "watch mode" or "agentation watch", call agentation_watch_annotations in a loop.
For each annotation received:
  1. Call agentation_acknowledge(annotationId)
  2. Use elementPath to locate the code: Grep(elementPath) or search codebase for CSS class
  3. Make the minimal change described in the comment
  4. Call agentation_resolve(annotationId, "<brief summary of what was changed>")
Continue watching until I say stop, or until timeout.
```

### Pattern 3: Platform-Specific Hook (Passive Injection)

The hook from Section 4 auto-appends pending annotations to every agent message — no "watch mode" needed. Works across all platforms.

### Pattern 4: Autonomous Self-Driving Critique

Two-agent setup for fully autonomous UI review cycles:

**Session 1 (Critic — uses `agent-browser`):**
```bash
# Start headed browser pointing at your dev server
agent-browser open http://localhost:3000
agent-browser snapshot -i
# Agent navigates, clicks elements via agentation toolbar, adds critique
# Annotations flow to agentation MCP server automatically
```

**Session 2 (Fixer — watches MCP):**
```
agentation_watch_annotations → receives critique → acknowledge → edit → resolve → loop
```

### Pattern 5: Webhook Integration

```tsx
<Agentation webhookUrl="https://your-server.com/webhook" />
# or env var:
# AGENTATION_WEBHOOK_URL=https://your-server.com/webhook
```

---

## 7. Annotation Type (Full Schema)

```typescript
type Annotation = {
  // Core
  id: string;
  x: number;            // % of viewport width (0-100)
  y: number;            // px from document top
  comment: string;      // User's feedback text
  element: string;      // Tag name: "button", "div", etc.
  elementPath: string;  // CSS selector: "body > main > button.cta"  ← grep target
  timestamp: number;

  // Context
  selectedText?: string;
  boundingBox?: { x: number; y: number; width: number; height: number };
  nearbyText?: string;
  cssClasses?: string;
  nearbyElements?: string;
  computedStyles?: string;
  fullPath?: string;
  accessibility?: string;
  reactComponents?: string;  // "App > Dashboard > Button"  ← component grep target
  isMultiSelect?: boolean;
  isFixed?: boolean;

  // Lifecycle (server-synced)
  sessionId?: string;
  url?: string;
  intent?: "fix" | "change" | "question" | "approve";
  severity?: "blocking" | "important" | "suggestion";
  status?: "pending" | "acknowledged" | "resolved" | "dismissed";
  thread?: ThreadMessage[];
  createdAt?: string;
  updatedAt?: string;
  resolvedAt?: string;
  resolvedBy?: "human" | "agent";
};
```

**Annotation lifecycle:**
```
pending → acknowledged → resolved
                      ↘ dismissed (requires reason)
```

---

## 8. HTTP REST API (port 4747)

```bash
# Sessions
POST   /sessions                     # Create session
GET    /sessions                     # List all sessions
GET    /sessions/:id                 # Get session + annotations

# Annotations
POST   /sessions/:id/annotations     # Add annotation
GET    /annotations/:id              # Get annotation
PATCH  /annotations/:id              # Update annotation
DELETE /annotations/:id              # Delete annotation
GET    /sessions/:id/pending         # Pending for session
GET    /pending                      # ALL pending across sessions

# Events (SSE streaming)
GET    /sessions/:id/events          # Session stream
GET    /events                       # Global stream (?domain=filter)

# Health
GET    /health
GET    /status
```

---

## 9. Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AGENTATION_STORE` | `memory` or `sqlite` | `sqlite` |
| `AGENTATION_WEBHOOK_URL` | Single webhook URL | — |
| `AGENTATION_WEBHOOKS` | Comma-separated webhook URLs | — |
| `AGENTATION_EVENT_RETENTION_DAYS` | Days to keep events | `7` |

SQLite storage: `~/.agentation/store.db`

---

## 10. Programmatic Utilities

```typescript
import {
  identifyElement, identifyAnimationElement,
  getElementPath, getNearbyText, getElementClasses,
  isInShadowDOM, getShadowHost, closestCrossingShadow,
  loadAnnotations, saveAnnotations, getStorageKey,
  type Annotation, type Session, type ThreadMessage,
} from 'agentation';
```

---

## 11. Platform Support Matrix

| Platform | Config File | MCP Key | Hook |
|----------|------------|---------|------|
| **Claude Code** | `~/.claude/claude_desktop_config.json` | `mcpServers` | `hooks.UserPromptSubmit` in `settings.json` |
| **Codex CLI** | `~/.codex/config.toml` | `[[mcp_servers]]` (TOML) | `developer_instructions` + `notify` |
| **Gemini CLI** | `~/.gemini/settings.json` | `mcpServers` | `hooks.AfterAgent` in `settings.json` |
| **OpenCode** | `~/.config/opencode/opencode.json` | `mcp` (`type: "local"`) | Skills system (no hook needed) |
| **Cursor / Windsurf** | `.cursor/mcp.json` / `.windsurf/mcp.json` | `mcpServers` | — |

---

## Best practices

1. Always gate `<Agentation>` with `NODE_ENV === 'development'` — never ship to production
2. Use MCP watch-loop over copy-paste for iterative cycles — eliminates context switching
3. Call `agentation_acknowledge` immediately when starting a fix — signals human
4. Include a `summary` in `agentation_resolve` — gives human traceability
5. Process `severity: "blocking"` annotations first in the watch loop
6. Use `elementPath` as the primary grep/search target in code — it's a valid CSS selector
7. Use `reactComponents` field when the codebase is React — matches component names directly
8. Add the appropriate hook for your platform (Section 4) for zero-friction passive injection
9. For autonomous self-driving, use `agent-browser` in headed mode with `agentation` mounted

---

## 12. jeo Integration (annotate keyword)

> agentation은 jeo 스킬의 **VERIFY_UI** 단계로 통합됩니다.
> plannotator가 `planui` / `ExitPlanMode`에서 동작하는 방식과 동일한 패턴입니다.
> `annotate`가 기본 키워드입니다. `agentui`는 하위 호환 별칭으로 유지됩니다.

### 엄게나 작동 방식

```
plannotator (planui):         agentation (annotate):
plan.md 작성                   앱 UI에 <Agentation> 마운트
    ↓ 블로킹                        ↓ 블로킹
plannotator 실행            agentation_watch_annotations
    ↓                              ↓
UI에서 Approve/Feedback       UI에서 어노테이션 생성
    ↓                              ↓
approved:true 확인             annotation ack→fix→resolve
    ↓                              ↓
EXECUTE 진입                  다음 단계 또는 루프
```

### 트리거 키워드

| 키워드 | 플랫폼 | 동작 |
|--------|----------|------|
| `annotate` | Claude Code | `agentation_watch_annotations` MCP 블로킹 호출 |
| `annotate` | Codex | `ANNOTATE_READY` 신호 → `jeo-notify.py` HTTP 폴링 |
| `annotate` | Gemini | GEMINI.md 지시: HTTP REST 폴링 패턴 |
| `/jeo-annotate` | OpenCode | opencode.json `mcp.agentation` + 지시사항 |
| `agentui` *(deprecated)* | 전체 플랫폼 | 위와 동일 동작 — 하위 호환 별칭 |
| `UI검토` | 전체 플랫폼 | `annotate`와 동일 |

### jeo에서 사용하기

```bash
# 1. jeo 실치 시 agentation 자동 등록
bash .agent-skills/jeo/scripts/install.sh --with-agentation
# 또는 전체 설치:
bash .agent-skills/jeo/scripts/install.sh --all

# 2. 앱에 agentation 컴포넌트 마운트
# app/layout.tsx 또는 pages/_app.tsx:
#   <Agentation endpoint="http://localhost:4747" />

# 3. MCP 서버 실행
npx agentation-mcp server

# 4. 에이전트에서 annotate 키워드 입력 → watch loop 시작 (agentui도 하위 호환 동작)
# Claude Code: MCP 도구 직접 호출
# Codex: ANNOTATE_READY (또는 AGENTUI_READY) 출력 → notify hook 자동 폴링
# Gemini: GEMINI.md HTTP 폴링 패턴
# OpenCode: /jeo-annotate 슬래시 커맨드 (또는 /jeo-agentui — deprecated)
```

### plannotator와의 분리 (Phase Guard)

plannotator와 agentation은 동일한 블로킹 루프 패턴을 사용하지만 **다른 phase에서만 동작**합니다:

| 도구 | 허용 phase | Hook Guard |
|------|-----------|------------|
| **plannotator** | `plan` only | `jeo-state.json` → `phase === "plan"` |
| **agentation** | `verify` / `verify_ui` only | `jeo-state.json` → `phase === "verify_ui"` |

각 플랫폼의 hook 스크립트는 `jeo-state.json`의 `phase` 필드를 확인하여 잘못된 phase에서 실행되지 않습니다.
이 guard가 없으면 Gemini의 `AfterAgent` 훅에서 두 도구가 동시에 실행될 수 있습니다.

### Pre-flight Check

VERIFY_UI 진입 전 3단계 확인:
1. **서버 상태**: `GET /health` — agentation-mcp 서버 실행 여부
2. **세션 존재**: `GET /sessions` — `<Agentation>` 컴포넌트 마운트 여부
3. **대기 annotation**: `GET /pending` — 처리할 annotation 수

통과 후 `jeo-state.json`의 `phase`를 `"verify_ui"`로, `agentation.active`를 `true`로 설정.

### Loop 검증 테스트

```bash
# agentation watch loop 통합 테스트 실행
bash .agent-skills/agentation/scripts/verify-loop.sh

# 빠른 테스트 (에러 케이스 생략)
bash .agent-skills/agentation/scripts/verify-loop.sh --quick
```

4단계 검증: Server Health → Annotation CRUD → ACK-RESOLVE Cycle → Error Cases

### 평가 플로우 (jeo VERIFY_UI 단계)

```
jeo "<task>"
    │
[1] PLAN (plannotator loop)    ← plan.md 승인
[2] EXECUTE (team/bmad)
[3] VERIFY
    ├─ agent-browser snapshot
    ├─ Pre-flight check (server + session + pending)
    └─ annotate → VERIFY_UI (agentation loop)   ← 이 단계 (agentui도 하위 호환)
        ├─ ACK → FIND → FIX → RESOLVE
        ├─ RE-SNAPSHOT (agent-browser)  ← 수정 후 재확인
        └─ jeo-state.json agentation 필드 업데이트
[4] CLEANUP
```

> 자세한 jeo 통합 내용: [jeo SKILL.md](../jeo/SKILL.md) Section 3.3.1 상세 워크플로우 확인


## References

- [agentation repo](https://github.com/benjitaylor/agentation)
- [agentation npm](https://www.npmjs.com/package/agentation)
- [agentation-mcp npm](https://www.npmjs.com/package/agentation-mcp)
- [Gemini CLI MCP docs](https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md)
- [agent-browser skill](../agent-browser/SKILL.md)

## Metadata

- Version: 1.0.0
- Source: benjitaylor/agentation (PolyForm Shield 1.0.0)
- Packages: `agentation@2.2.1`, `agentation-mcp@1.2.0`
- Last updated: 2026-03-04
- Scope: UI annotation bridge for human-agent feedback loops — Claude Code, Codex, Gemini CLI, OpenCode
