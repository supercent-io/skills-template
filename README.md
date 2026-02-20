# Agent Skills

> Modular skill system for AI agents
> **65 Skills** | **95% Token Reduction** | **TOON Format by Default**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-65-green.svg)](.agent-skills/)
[![Token](https://img.shields.io/badge/Token%20Savings-95%25-success.svg)](.agent-skills/)

![Agent Skills](AgentSkills.png)


---

## Quick Install

```bash
# All 65 core skills
npx skills add https://github.com/supercent-io/skills-template

# Individual skill
npx skills add https://github.com/supercent-io/skills-template --skill <skill-name>
```

---

## plannotator — AI Review Tool

> Keyword: `planno` (formerly `planview`) | [Full guide](docs/plannotator/README.md)

Use the `planno` keyword to review coding plans and diffs visually with Plannotator.

```bash
# Install only plannotator skill
npx skills add https://github.com/supercent-io/skills-template --skill planview
```

```text
planno로 이번 구현 계획을 검토하고 수정 코멘트를 만들어줘.
```

Plannotator quick setup (official):

```bash
# macOS / Linux / WSL
curl -fsSL https://plannotator.ai/install.sh | bash
```

Claude Code plugin:

```bash
/plugin marketplace add backnotprop/plannotator
/plugin install plannotator@plannotator
```

For diff annotation, run `/plannotator-review`, add inline comments, then choose approve or request changes.

→ [Full guide: plan review loop, diff annotation, env vars, integrations](docs/plannotator/README.md)

---

## AI CLI Tools — Universal Model Hub

> **OpenCode** and **oh-my-opencode** function as model-agnostic CLI hubs, just like Claude Code, Codex CLI, and Gemini-CLI — but with the ability to route to **any model** from any provider in a single session.

| CLI Tool | Role | Models | Setup |
|----------|------|--------|-------|
| **Claude Code** | Orchestrator + Coder | Claude family | [docs](https://docs.anthropic.com/en/docs/claude-code/getting-started) · [oh-my-claudecode plugin](https://github.com/Yeachan-Heo/oh-my-claudecode) |
| **Codex CLI** | Executor + Builder | OpenAI / GPT family | [docs](https://github.com/openai/codex) |
| **Gemini-CLI** | Analyst + Researcher | Gemini / Google family | [docs](https://github.com/google-gemini/gemini-cli) |
| **OpenCode** | Universal Hub | All providers | [opencode.ai](https://opencode.ai) · `curl -fsSL https://opencode.ai/install \| bash` |
| **oh-my-opencode** | Universal Hub + Loop | All providers | [guide](https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/refs/heads/master/docs/guide/installation.md) · [repo](https://github.com/code-yeongyu/oh-my-opencode) |

These tools are **interoperable** — Agent Skills work across all of them via the same keyword system.

---

## Harness Engineering — Orchestrator Skills

> Three specialized orchestration skills, each engineered as a harness for a specific CLI and model ecosystem.

| Keyword | Skill | Best With | Harness For |
|---------|-------|-----------|-------------|
| `ohmg` | oh-my-ag | Gemini-CLI | Google models (Gemini, Gemma) — multi-domain agent coordination via Serena Memory |
| `omx` | oh-my-codex | Codex CLI | OpenAI models — 30 agents, 40+ workflow skills, tmux team mode, MCP servers |
| `bmad` | bmad-orchestrator | **All CLIs** | Universal — BMAD phase routing (Analysis → Planning → Solutioning → Implementation) · [detailed guide](docs/bmad/README.md) |

> **Note on bmad**: While `bmad-orchestrator` is listed as a Claude Code harness above, the **BMAD methodology and core skills are fully universal** — they work with Claude Code, Codex CLI, Gemini-CLI, OpenCode, and any AI CLI tool. The skill encodes fundamental engineering principles, not Claude-specific APIs.

### Activation

> **Important**: `ohmg`, `omx`, `bmad`, `playwriter`, `agent-browser` require **explicit skill activation** before first use.

Tell your AI agent to set up the skill by ending your request with **"기억해"** (remember):

```text
<harness> 스킬을 설정하고 사용해줘. 기억해.
```

> Without "기억해", the agent will use the skill for the current session only and may not retain configuration.

→ [Per-CLI activation examples & troubleshooting](docs/harness/README.md)

---

## bmad-orchestrator — Universal Engineering Harness

> **bmad-orchestrator** routes AI-driven development through four structured phases: Analysis → Planning → Solutioning → Implementation. The `bmad` keyword activates it across **all AI CLI tools** — Claude Code, Codex CLI, Gemini-CLI, and OpenCode.
>
> Unlike tool-specific orchestrators (`ohmg`, `omx`, `omc`), **bmad encodes universal engineering principles** — structured thinking, architectural discipline, and phase-gated delivery — that apply regardless of which AI model or CLI you're using.

### Quick Start

**Step 1: Install**
```bash
npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator
```

**Step 2: Activate in your CLI** (Claude Code, Codex CLI, Gemini-CLI, OpenCode)
```text
bmad 스킬을 설정하고 사용해줘. 기억해.
```

**Step 3: Initialize your project**
```text
/workflow-init
```

→ [Full guide: commands, project levels, examples](docs/bmad/README.md)

---

## Claude Code 사용 케이스 — omc (oh-my-claudecode)

> **oh-my-claudecode**는 Claude Code 전용 Teams-first 멀티 에이전트 오케스트레이션 레이어입니다. `omc` 키워드로 활성화하며, 32개 전문 에이전트, 스마트 모델 라우팅, 지속 실행 루프를 제공합니다 — 별도 학습 없이 바로 사용 가능합니다.

> **다른 CLI 사용자**: OpenAI Codex CLI → [oh-my-codex](#codex-cli-사용-케이스--omx-oh-my-codex) (`omx` 키워드)

[![GitHub Stars](https://img.shields.io/github/stars/Yeachan-Heo/oh-my-claudecode?style=flat)](https://github.com/Yeachan-Heo/oh-my-claudecode)
[![GitHub Forks](https://img.shields.io/github/forks/Yeachan-Heo/oh-my-claudecode?style=flat)](https://github.com/Yeachan-Heo/oh-my-claudecode)

### 키워드: `omc`

```text
omc 스킬을 설정하고 사용해줘. 기억해.
```

### Installation

```bash
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/plugin install oh-my-claudecode
/omc:omc-setup
```

> **npm alternative**: `npm install -g oh-my-claude-sisyphus`

### Updating

```bash
/plugin marketplace update omc && /omc:omc-setup
# If issues: /omc:omc-doctor
```

→ [Full guide: modes, keywords, team setup, multi-AI](docs/omc/README.md) · [GitHub](https://github.com/Yeachan-Heo/oh-my-claudecode)

---

## Codex CLI 사용 케이스 — omx (oh-my-codex)

> **oh-my-codex**는 Codex CLI 전용 멀티 에이전트 오케스트레이션 레이어입니다. `omx` 키워드로 활성화하며, 30개 전문 에이전트와 autopilot/team 모드, MCP 서버 통합을 제공합니다.

> **다른 CLI 사용자**: Claude Code → [oh-my-claudecode](#claude-code-사용-케이스--omc-oh-my-claudecode) (`omc` 키워드)

### 키워드: `omx`

```text
omx 스킬을 설정하고 사용해줘. 기억해.
```

### Installation

```bash
npx skills add https://github.com/supercent-io/skills-template --skill oh-my-codex
```

### Quick Usage

```text
$autopilot 전체 인증 모듈 구현해줘
$team 백엔드 API 개발 시작해줘
```

→ [GitHub](https://github.com/Yeachan-Heo/oh-my-codex)

---

## ralph — Completion Loop

> **ralph** is a self-referential completion loop for AI CLI tools. It runs the agent on the same task across turns with fresh context each iteration, until the completion promise is detected or max iterations is reached.

```text
/ralph "<task>" [--completion-promise=DONE] [--max-iterations=5]
```

→ [Full guide: options, examples, prompt best practices](docs/ralph/README.md)

---

## AI Review Tools

> Three tools for visually managing, reviewing, and automating AI agent workflows.

| Tool | Keyword | Description | Guide |
|------|---------|-------------|-------|
| **plannotator** | `planno` | Visual plan/diff review with inline annotations | [docs](docs/plannotator/README.md) |
| **vibe-kanban** | `kanbanview` | Kanban board for AI agents — includes Conductor Pattern | [docs](docs/vibe-kanban/README.md) |
| **copilot-coding-agent** | `copilotview` | GitHub Copilot issue-to-Draft-PR automation | [docs](docs/copilot-coding-agent/README.md) |

### kanbanview — Vibe Kanban + Conductor Pattern

> Visual Kanban board for managing AI coding agents. Includes Conductor Pattern (parallel git worktree execution) built-in.

```bash
# Launch Kanban UI
npx vibe-kanban

# CLI-only pipeline (no Kanban UI)
bash scripts/pipeline.sh my-feature --stages check,conductor,pr
```

→ [Full guide: setup, conductor CLI mode, planno integration, git worktree](docs/vibe-kanban/README.md)

---

### copilotview — Copilot Coding Agent

> Automate GitHub Copilot Coding Agent: add `ai-copilot` label to an issue → Copilot auto-assigns and creates a Draft PR.

```bash
# One-time setup
bash scripts/copilot-setup-workflow.sh

# Create issue for Copilot
gh issue create --label ai-copilot --title "Add auth" --body "..."
```

→ [Full guide: setup, GraphQL API, GitHub Actions, planno integration](docs/copilot-coding-agent/README.md)

---

## Skills (65 Total)

### Orchestration & Utilities (18)
| Skill | Keyword | Description |
|-------|---------|-------------|
| `omc` | `omc` | oh-my-claudecode — Claude Code multi-agent orchestration (32 agents, Team/Autopilot/Ralph modes) |
| `ohmg` | `ohmg` | Multi-agent orchestration — Gemini + Google models harness |
| `oh-my-codex` | `omx` | Multi-agent orchestration — Codex CLI harness |
| `bmad-orchestrator` | `bmad` | **Universal** — BMAD phase routing (Analysis → Planning → Solutioning → Implementation) · works with all CLIs |
| `ralph` | `ralph` | Self-referential completion loop — iterates across agent turns until done |
| `planview` | `planno` | Visual plan/diff review with Plannotator — annotate, approve, or request changes |
| `agent-browser` | `agent-browser` | Headless browser for AI agents |
| `opencontext` | — | Persistent memory across sessions |
| `workflow-automation` | — | Workflow automation scripts |
| `environment-setup` | — | Dev environment setup |
| `file-organization` | — | File & folder organization |
| `git-submodule` | — | Git submodule management |
| `git-workflow` | — | Git workflow management |
| `npm-git-install` | — | Install npm packages from GitHub |
| `skill-standardization` | — | SKILL.md standardization |
| `conductor-pattern` | `conductor` | [→kanbanview] Conductor Pattern CLI — parallel agents via git worktree; merged into kanbanview (vibe-kanban) |
| `vibe-kanban` | `kanbanview` | Kanban board for AI agent management — includes Conductor Pattern; To Do → In Progress → Review → Done |
| `copilot-coding-agent` | `copilotview` | GitHub Copilot issue-to-PR automation — label issue → Copilot creates Draft PR |

### Backend (5)
`api-design` · `api-documentation` · `authentication-setup` · `backend-testing` · `database-schema-design`

### Frontend (7)
`design-system` · `react-best-practices` · `responsive-design` · `state-management` · `ui-component-patterns` · `web-accessibility` · `web-design-guidelines`

### Code Quality (5)
`code-refactoring` · `code-review` · `debugging` · `performance-optimization` · `testing-strategies`

### Infrastructure (8)
`deployment-automation` · `firebase-ai-logic` · `genkit` · `looker-studio-bigquery` · `monitoring-observability` · `security-best-practices` · `system-environment-setup` · `vercel-deploy`

### Agent Development (6)
`agent-configuration` · `agent-evaluation` · `agentic-development-principles` · `agentic-principles` · `agentic-workflow` · `prompt-repetition`

### Documentation (4)
`changelog-maintenance` · `presentation-builder` · `technical-writing` · `user-guide-writing`

### Project Management (4)
`sprint-retrospective` · `standup-meeting` · `task-estimation` · `task-planning`

### Search & Analysis (4)
`codebase-search` · `data-analysis` · `log-analysis` · `pattern-detection`

### Creative Media (3)
`image-generation` · `pollinations-ai` · `video-production`

### Marketing (1)
`marketing-automation`

---

## Community & Specialized Skills

| Skill | Provider | Install |
|-------|----------|---------|
| `awesome-skills` | Composio | `npx skills add https://github.com/ComposioHQ/awesome-claude-skills` |
| `ohmg` | first-fluke | `npx skills add https://github.com/supercent-io/skills-template --skill ohmg` |
| `omc` | Yeachan-Heo | `/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode` (Claude Code native plugin, keyword: `omc`) |
| `oh-my-codex` | Yeachan-Heo | `npx skills add https://github.com/supercent-io/skills-template --skill oh-my-codex` (Codex CLI native plugin, keyword: `omx`) |
| `bmad-orchestrator` | bmad-code-org | `npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator` |
| `ralph` | gemini-cli-extensions | `npx skills add https://github.com/supercent-io/skills-template --skill ralph` |
| `Playwriter` | remorses | `npx -y skills add remorses/playwriter` |
| `agent-browser` | vercel-labs | `npx skills add vercel-labs/agent-browser` |

> **100+ community skills**: [Awesome Claude Skills](https://github.com/ComposioHQ/awesome-claude-skills)

---

## TOON Format (Default — 95% Token Reduction)

```
N:skill-name          # Name
D:Description...      # Description
G:keyword1 keyword2   # Search keywords
U[5]:                 # Use cases
S[6]{n,action,details}: # Steps
R[5]:                 # Rules
E[2]{desc,in,out}:    # Examples
```

| Mode | File | Avg Tokens | Reduction |
|:-----|:-----|:-----------|:----------|
| **full** | SKILL.md | ~2,198 | — |
| **toon** | SKILL.toon | ~112 | **94.9%** |

---

## Architecture

```
.agent-skills/
├── skills.json              # Skill manifest
├── skills.toon              # Token-optimized summary
├── skill_loader.py
├── skill-query-handler.py
└── [65 skill folders]       # All skills at root level
```

> **v4.3.0+**: All skills flattened to root level (no category subfolders)

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

**Version**: 4.9.0 | **Updated**: 2026-02-20 | **Skills**: 65 | **Format**: TOON (Default)

**Changelog v4.9.0**:
- **AI Review Tools**: Introduced new "AI Review Tools" category grouping planno, kanbanview, copilotview
- **plannotator** (keyword: `planno`): Renamed from `planview` keyword; same Plannotator tool, cleaner keyword
- **kanbanview** (keyword: `kanbanview`): Vibe Kanban now includes Conductor Pattern (parallel git worktree execution) built-in; CLI mode via `scripts/pipeline.sh`
- **copilotview** (keyword: `copilotview`): Renamed from `copilot` keyword for clarity
- **conductor-pattern**: Merged into `kanbanview` (vibe-kanban); CLI scripts (`conductor.sh`, `pipeline.sh`) remain available

**Changelog v4.8.0**:
- **conductor-pattern**: Added Conductor Pattern skill — parallel AI agents via git worktree, unified pipeline runner with hooks, state-based resume, planview integration
- **vibe-kanban**: Added Vibe Kanban skill — visual Kanban board for AI agent task management with git worktree and planview integration
- **copilot-coding-agent**: Added Copilot Coding Agent skill — GitHub issue-to-Draft-PR automation via GraphQL assignment and GitHub Actions

**Changelog v4.7.0**:
- **README restructured**: Moved detailed usage docs to `docs/` — `docs/omc/`, `docs/ralph/`, `docs/harness/`; README now links to detailed guides instead of embedding them
- **omx (oh-my-codex)**: Added dedicated Codex CLI use case section for `omx` keyword, mirroring `omc` pattern

**Changelog v4.6.0**:
- **omc skill**: Added `omc` skill (oh-my-claudecode) for Claude Code multi-agent orchestration — Team/Autopilot/Ralph/Ultrawork modes, 32 specialized agents, magic keywords; activate with `omc` keyword → `/omc:omc-setup`
- **bmad universal**: Clarified `bmad-orchestrator` as a **universal** engineering harness — works across Claude Code, Codex CLI, Gemini-CLI, and OpenCode (not Claude Code exclusive)
- **Claude Code 사용 케이스**: Reframed oh-my-claudecode section as Claude Code-specific use case with `omc` keyword

**Changelog v4.5.0**:
- **ralph**: Renamed `ralph-loop` → `ralph` keyword; rewrote skill based on [gemini-cli-extensions/ralph](https://github.com/gemini-cli-extensions/ralph) — self-referential loop across agent turns, fresh context per iteration, `--completion-promise` and `--max-iterations` options, `/ralph:cancel` and `/ralph:help` commands

**Changelog v4.4.3**:
- **bmad-orchestrator Guide**: Added comprehensive guide for `bmad` harness in README with quick start, core commands, and project level matrix; created detailed docs in `docs/bmad/` covering installation, workflow phases, configuration reference, and practical examples (bug fix → enterprise)

**Changelog v4.4.2**:
- **oh-my-claudecode Plugin Guide**: Added comprehensive guide for installing and using oh-my-claudecode as a Claude Code native plugin — covering installation, Team mode, orchestration modes, magic keywords, and multi-AI orchestration setup

**Changelog v4.4.1**:
- **CLI Setup Links**: Added hyperlinks for OpenCode, oh-my-opencode, Claude Code, Codex CLI, Gemini-CLI setup guides
- **Usage Examples**: Added per-CLI keyword usage examples (bmad→Claude Code, omx→Codex, ohmg→Gemini-CLI, all→OpenCode)

**Changelog v4.4.0**:
- **Harness Engineering**: Documented ohmg→Gemini, omx→Codex, bmad→Claude as specialized harnesses
- **Keyword System**: Added keyword aliases (`ohmg`, `omx`, `bmad`) and "기억해" activation requirement
- **CLI Hub**: Positioned OpenCode and oh-my-opencode as universal model-agnostic hubs
- **ralph integration**: Clarified ralph as gateway for ohmg/omx/bmad/playwriter/agent-browser
- **README**: Streamlined to list/usability format, removed verbose installation guides

<!-- plannotator-temp-check -->
