# Agent Skills

> Modular skill system for AI agents
> **60 Skills** | **95% Token Reduction** | **TOON Format by Default**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-60-green.svg)](.agent-skills/)
[![Token](https://img.shields.io/badge/Token%20Savings-95%25-success.svg)](.agent-skills/)

![Agent Skills](AgentSkills.png)

---

## AI CLI Tools — Universal Model Hub

> **OpenCode** and **oh-my-opencode** function as model-agnostic CLI hubs, just like Claude Code, Codex CLI, and Gemini-CLI — but with the ability to route to **any model** from any provider in a single session.

| CLI Tool | Role | Models | Setup |
|----------|------|--------|-------|
| **Claude Code** | Orchestrator + Coder | Claude family | [docs](https://docs.anthropic.com/en/docs/claude-code/getting-started) |
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
| `bmad` | bmad-orchestrator | Claude Code | Claude models — BMAD phase routing (Analysis → Planning → Solutioning → Implementation) |

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

## Quick Install

```bash
# All 60 core skills
npx skills add https://github.com/supercent-io/skills-template

# Individual skill
npx skills add https://github.com/supercent-io/skills-template --skill <skill-name>
```

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

**Version**: 4.4.1 | **Updated**: 2026-02-19 | **Skills**: 60 | **Format**: TOON (Default)

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
