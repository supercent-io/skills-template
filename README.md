# Agent Skills

> Modular skill system for AI agents
> **60 Skills** | **95% Token Reduction** | **TOON Format by Default**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-60-green.svg)](.agent-skills/)
[![Token](https://img.shields.io/badge/Token%20Savings-95%25-success.svg)](.agent-skills/)

![Agent Skills](AgentSkills.png)


---

## Quick Install

```bash
# All 60 core skills
npx skills add https://github.com/supercent-io/skills-template

# Individual skill
npx skills add https://github.com/supercent-io/skills-template --skill <skill-name>
```

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
| `bmad` | bmad-orchestrator | Claude Code | Claude models — BMAD phase routing (Analysis → Planning → Solutioning → Implementation) · [detailed guide](docs/bmad/README.md) |

### How to Activate

> **Important**: `ohmg`, `omx`, `bmad`, `playwriter`, `agent-browser` require **explicit skill activation** before first use.

Tell your AI agent to set up the skill by ending your request with **"기억해"** (remember):

```text
# Example activation pattern
ohmg 스킬을 설정하고 사용해줘. 기억해.
omx 스킬을 설정하고 사용해줘. 기억해.
bmad 스킬을 설정하고 사용해줘. 기억해.
playwriter 스킬을 설정하고 사용해줘. 기억해.
agent-browser 스킬을 설정하고 사용해줘. 기억해.
```

> Without "기억해", the agent will use the skill for the current session only and may not retain configuration.

### Keyword Usage Examples by CLI

**Claude Code** — `bmad` harness (Claude models)
```text
# In Claude Code terminal
bmad 스킬을 설정하고 사용해줘. 기억해.
bmad로 이 프로젝트 API 설계해줘.
/workflow-init
```

**Codex CLI** — `omx` harness (OpenAI models)
```text
# In Codex CLI terminal
omx 스킬을 설정하고 사용해줘. 기억해.
$autopilot 전체 인증 모듈 구현해줘
$team 백엔드 API 개발 시작해줘
```

**Gemini-CLI** — `ohmg` harness (Google models)
```text
# In Gemini-CLI terminal
ohmg 스킬을 설정하고 사용해줘. 기억해.
/coordinate PM Agent에게 요구사항 분석 요청해줘
```

**OpenCode / oh-my-opencode** — all keywords available
```text
# Supports all harnesses in one session
ralph-loop로 이 작업 완료될 때까지 반복해줘
ohmg 스킬로 멀티 에이전트 워크플로우 시작해줘. 기억해.
```

---

## bmad-orchestrator — Claude Code Harness

> **bmad-orchestrator** routes AI-driven development through four structured phases: Analysis → Planning → Solutioning → Implementation. The `bmad` keyword activates it in Claude Code.

### Quick Start

**Step 1: Install**
```bash
npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator
```

**Step 2: Activate in Claude Code**
```text
bmad 스킬을 설정하고 사용해줘. 기억해.
```

**Step 3: Initialize your project**
```text
/workflow-init
```

### Core Commands

| Command | Phase | Purpose |
|---------|-------|---------|
| `/workflow-init` | Setup | Initialize BMAD in project |
| `/workflow-status` | Any | Check current phase & next step |
| `/product-brief` | 1 Analysis | Define product vision |
| `/prd` | 2 Planning | Product Requirements Document |
| `/tech-spec` | 2 Planning | Technical Specification |
| `/architecture` | 3 Solutioning | System architecture design |
| `/sprint-planning` | 4 Implementation | Break into sprints & stories |
| `/dev-story` | 4 Implementation | Implement a specific story |

### Project Levels

BMAD adapts to your project size automatically:

| Level | Size | Examples | Required Phases |
|-------|------|---------|----------------|
| **0** | Single change | Bug fix, config tweak | Planning + Implementation |
| **1** | Small feature | New API endpoint | Planning + Implementation |
| **2** | Feature set | Auth system | All 4 phases |
| **3** | Integration | Multi-tenant SaaS | All 4 phases (detailed) |
| **4** | Enterprise | Platform migration | All 4 phases (extensive) |

### Detailed Documentation

| Document | Contents |
|----------|---------|
| [Overview](docs/bmad/README.md) | What is BMAD, quick start, phase overview |
| [Installation & Setup](docs/bmad/installation.md) | Full install, `기억해` activation, troubleshooting |
| [Workflow Guide](docs/bmad/workflow.md) | All 4 phases, commands, level decision matrix |
| [Configuration Reference](docs/bmad/configuration.md) | Config files, status tracking, variable substitution |
| [Practical Examples](docs/bmad/examples.md) | Bug fix → enterprise project walkthroughs |

---

## oh-my-claudecode — Claude Code Native Plugin

> **oh-my-claudecode** is a Teams-first multi-agent orchestration layer for Claude Code. Install it as a native plugin and get 32 specialized agents, smart model routing, and a persistent execution loop — all without any learning curve.

[![GitHub Stars](https://img.shields.io/github/stars/Yeachan-Heo/oh-my-claudecode?style=flat)](https://github.com/Yeachan-Heo/oh-my-claudecode)
[![GitHub Forks](https://img.shields.io/github/forks/Yeachan-Heo/oh-my-claudecode?style=flat)](https://github.com/Yeachan-Heo/oh-my-claudecode)

### Installation (3 Steps)

**Step 1: Add from Plugin Marketplace**

```bash
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/plugin install oh-my-claudecode
```

**Step 2: Run Setup**

```bash
/omc:omc-setup
```

**Step 3: Start Building**

```text
autopilot: build a REST API for managing tasks
```

> **npm package name**: If installing via npm/bun, use `oh-my-claude-sisyphus`

### Updating

```bash
# 1. Sync latest version from marketplace
/plugin marketplace update omc

# 2. Re-run setup to refresh configuration
/omc:omc-setup

# If you hit issues after update
/omc:omc-doctor
```

> **Important**: If marketplace auto-update is not enabled, you must manually run `/plugin marketplace update omc` before setup.

### Orchestration Modes

| Mode | What it is | Use For |
|------|-----------|---------|
| **Team** (recommended) | Staged pipeline: `team-plan → team-prd → team-exec → team-verify → team-fix` | Coordinated agents on shared task list |
| **Autopilot** | Autonomous single lead agent | End-to-end feature work |
| **Ultrawork** | Maximum parallelism (non-team) | Burst parallel fixes/refactors |
| **Ralph** | Persistent mode with verify/fix loops | Tasks that must complete fully |
| **Pipeline** | Sequential staged processing | Multi-step transformations |
| **Swarm/Ultrapilot** | Legacy facades → route to Team | Existing workflows |

### Team Mode (Canonical)

```bash
/omc:team 3:executor "fix all TypeScript errors"
```

Enable Claude Code native teams in `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Magic Keywords

```text
team          # Canonical Team orchestration
autopilot     # Full autonomous execution
ralph         # Persistence mode
ulw           # Maximum parallelism
plan          # Planning interview
ralplan       # Iterative planning consensus
swarm         # Legacy (routes to Team)
ultrapilot    # Legacy (routes to Team)
```

### Why oh-my-claudecode?

- **Zero configuration** — Works out of the box with intelligent defaults
- **Team-first orchestration** — Team is the canonical multi-agent surface
- **Natural language interface** — No commands to memorize
- **Automatic parallelization** — Complex tasks distributed across 32 specialized agents
- **Persistent execution** — Won't stop until the job is verified complete
- **Cost optimization** — Smart model routing saves 30–50% on tokens
- **Real-time visibility** — HUD statusline shows what's happening under the hood

### Requirements

- Claude Code CLI
- Claude Max/Pro subscription **or** Anthropic API key

### Optional: Multi-AI Orchestration

| Provider | Install | What it enables |
|----------|---------|----------------|
| Gemini CLI | `npm install -g @google/gemini-cli` | Design review, UI consistency (1M token context) |
| Codex CLI | `npm install -g @openai/codex` | Architecture validation, code review cross-check |

→ [Full documentation](https://github.com/Yeachan-Heo/oh-my-claudecode) · [Migration Guide](https://github.com/Yeachan-Heo/oh-my-claudecode#migration-guide)

---

## ralph-loop — Completion Loop

> **ralph-loop** enforces task completion across all CLI tools. Enabling it activates `ohmg`, `omx`, `bmad`, `playwriter`, and `agent-browser` as usable keywords in your workflow.

```text
/ralph-loop "<task>" [--completion-promise=DONE] [--max-iterations=100]
```

| Keyword | Availability |
|---------|-------------|
| `ralph-loop` | OpenCode, oh-my-opencode, Claude Code, Gemini-CLI |
| `ohmg` | Available when ralph-loop is active |
| `omx` | Available when ralph-loop is active |
| `bmad` | Available when ralph-loop is active |
| `playwriter` | Available for browser verification |
| `agent-browser` | Available for headless verification |


---

## Skills (60 Total)

### Orchestration & Utilities (13)
| Skill | Keyword | Description |
|-------|---------|-------------|
| `ohmg` | `ohmg` | Multi-agent orchestration — Gemini + Google models harness |
| `oh-my-codex` | `omx` | Multi-agent orchestration — Codex CLI harness |
| `bmad-orchestrator` | `bmad` | BMAD phase routing — Claude Code harness |
| `ralph-loop` | `ralph-loop` | Completion enforcement loop for all CLIs |
| `agent-browser` | `agent-browser` | Headless browser for AI agents |
| `opencontext` | — | Persistent memory across sessions |
| `workflow-automation` | — | Workflow automation scripts |
| `environment-setup` | — | Dev environment setup |
| `file-organization` | — | File & folder organization |
| `git-submodule` | — | Git submodule management |
| `git-workflow` | — | Git workflow management |
| `npm-git-install` | — | Install npm packages from GitHub |
| `skill-standardization` | — | SKILL.md standardization |

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
| `oh-my-claudecode` | Yeachan-Heo | `/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode` (Claude Code native plugin) |
| `oh-my-codex` | Yeachan-Heo | `npx skills add https://github.com/supercent-io/skills-template --skill oh-my-codex` |
| `bmad-orchestrator` | bmad-code-org | `npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator` |
| `ralph-loop` | opencode/oh-my-opencode | `npx skills add https://github.com/supercent-io/skills-template --skill ralph-loop` |
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
└── [60 skill folders]       # All skills at root level
```

> **v4.3.0+**: All skills flattened to root level (no category subfolders)

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

**Version**: 4.4.3 | **Updated**: 2026-02-20 | **Skills**: 60 | **Format**: TOON (Default)

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
- **ralph-loop integration**: Clarified ralph-loop as gateway for ohmg/omx/bmad/playwriter/agent-browser
- **README**: Streamlined to list/usability format, removed verbose installation guides

**Changelog v4.3.8**:
- **Primary Orchestrator**: Integrated `ohmg` (oh-my-ag) as default multi-agent orchestration skill

**Changelog v4.3.7**:
- **Cleanup**: Removed legacy `bmad` skill files, standardized to `bmad-orchestrator`

**Changelog v4.3.6**:
- **New skill: genkit**: Firebase Genkit AI workflow orchestration

**Changelog v4.3.5**:
- **New skill: oh-my-codex**: Multi-agent orchestration for OpenAI Codex CLI
