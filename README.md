# Agent Skills

> Modular skill system for AI agents
> **57 Skills** | **95% Token Reduction** | **TOON Format by Default**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-57-green.svg)](.agent-skills/)
[![Token](https://img.shields.io/badge/Token%20Savings-95%25-success.svg)](.agent-skills/)

![Agent Skills](AgentSkills.png)

---

## Installation

### Install Skills Using NPX (Recommended)

```bash
# Install all skills at once (57 skills)
npx skills add https://github.com/supercent-io/skills-template --skill \
  agent-configuration \
  agent-evaluation \
  agentic-development-principles \
  agentic-principles \
  agentic-workflow \
  prompt-repetition \
  api-design \
  api-documentation \
  authentication-setup \
  backend-testing \
  database-schema-design \
  code-refactoring \
  code-review \
  debugging \
  performance-optimization \
  testing-strategies \
  changelog-maintenance \
  presentation-builder \
  technical-writing \
  user-guide-writing \
  design-system \
  react-best-practices \
  responsive-design \
  state-management \
  ui-component-patterns \
  web-accessibility \
  web-design-guidelines \
  deployment-automation \
  firebase-ai-logic \
  looker-studio-bigquery \
  monitoring-observability \
  security-best-practices \
  system-environment-setup \
  vercel-deploy \
  marketing-automation \
  sprint-retrospective \
  standup-meeting \
  task-estimation \
  task-planning \
  codebase-search \
  data-analysis \
  log-analysis \
  pattern-detection \
  image-generation \
  video-production \
  environment-setup \
  file-organization \
  git-submodule \
  git-workflow \
  kling-ai \
  mcp-codex \
  npm-git-install \
  opencontext \
  skill-standardization \
  workflow-automation
```

### Individual Skill Installation

```bash
# Install specific skills
npx skills add https://github.com/supercent-io/skills-template --skill api-design
npx skills add https://github.com/supercent-io/skills-template --skill code-review
npx skills add https://github.com/supercent-io/skills-template --skill oh-my-ag-mcp-integration
```

### oh-my-ag MCP Setup Guide

- Guide: `oh-my-ag-mcp-setup-guide.md`
- Skill: `oh-my-ag-mcp-integration`

```bash
# Install only oh-my-ag MCP integration skill
npx skills add https://github.com/supercent-io/skills-template --skill oh-my-ag-mcp-integration
```

---

### 🌟 Explore More Skills from the Community

**Want even more Claude skills?** Check out the **[Awesome Claude Skills](https://github.com/ComposioHQ/awesome-claude-skills)** repository - a curated collection of 100+ skills covering automation, development, and productivity workflows!

**Quick install from Awesome Claude Skills:**
```bash
# Example: Install GitHub automation skill
npx skills add https://github.com/ComposioHQ/awesome-claude-skills --skill github-automation

# Example: Install Slack automation skill  
npx skills add https://github.com/ComposioHQ/awesome-claude-skills --skill slack-automation

# Browse all skills at: https://github.com/ComposioHQ/awesome-claude-skills
```

---

## Skills Overview (57 Total - Flat Structure)

All skills are now at the root level (no category folders).

### Backend (5 skills)
- `api-design` - RESTful and GraphQL API design
- `api-documentation` - API documentation generation
- `authentication-setup` - Authentication & authorization systems
- `backend-testing` - Backend testing strategies
- `database-schema-design` - Database schema design & optimization

### Frontend (7 skills)
- `design-system` - Design system implementation
- `react-best-practices` - React & Next.js best practices
- `responsive-design` - Responsive web design
- `state-management` - State management patterns
- `ui-component-patterns` - UI component patterns
- `web-accessibility` - Web accessibility (a11y) standards
- `web-design-guidelines` - Web design guidelines compliance

### Code Quality (5 skills)
- `code-refactoring` - Code refactoring strategies
- `code-review` - Code review practices
- `debugging` - Systematic debugging methodologies
- `performance-optimization` - Performance optimization techniques
- `testing-strategies` - Comprehensive testing strategies

### Infrastructure (7 skills)
- `deployment-automation` - CI/CD and deployment automation
- `firebase-ai-logic` - Firebase AI Logic integration
- `looker-studio-bigquery` - Looker Studio & BigQuery integration
- `monitoring-observability` - Monitoring and observability setup
- `security-best-practices` - Security best practices
- `system-environment-setup` - Environment configuration
- `vercel-deploy` - Vercel deployment automation

### Documentation (4 skills)
- `changelog-maintenance` - Changelog management
- `presentation-builder` - Presentation builder
- `technical-writing` - Technical documentation writing
- `user-guide-writing` - User guide & tutorial writing

### Project Management (4 skills)
- `sprint-retrospective` - Sprint retrospective facilitation
- `standup-meeting` - Daily standup management
- `task-estimation` - Task estimation techniques
- `task-planning` - Task planning & organization

### Search & Analysis (4 skills)
- `codebase-search` - Codebase search & navigation
- `data-analysis` - Data analysis & insights
- `log-analysis` - Log analysis & debugging
- `pattern-detection` - Pattern detection in code/data

### Creative Media (2 skills)
- `image-generation` - AI image generation
- `video-production` - Video production workflows

### Marketing (1 skill)
- `marketing-automation` - Marketing automation workflows

### Agent Development (6 skills)
- `agent-configuration` - AI agent configuration & security policies
- `agent-evaluation` - AI agent evaluation systems
- `agentic-development-principles` - Universal agentic development principles
- `agentic-principles` - Core AI agent collaboration principles
- `agentic-workflow` - Practical AI agent workflows & productivity
- `prompt-repetition` - Prompt repetition techniques for LLM accuracy

### Utilities (11 skills)
- `environment-setup` - Development environment setup
- `file-organization` - File & folder organization
- `git-submodule` - Git submodule management
- `git-workflow` - Git workflow management
- `kling-ai` - Kling AI video generation
- `oh-my-ag-mcp-integration` - oh-my-ag MCP integration setup for ulw workflows
- `mcp-codex` - MCP Codex integration
- `npm-git-install` - Install npm packages from GitHub
- `opencontext` - AI agent persistent memory with OpenContext
- `skill-standardization` - SKILL.md standardization
- `vercel-deploy` - Vercel deployment
- `workflow-automation` - Workflow automation scripts

---

## TOON Format (Default)

Skills use the **TOON format** by default, achieving 95% token reduction.

### TOON Format Structure

```
N:skill-name                           # Skill name
D:Description in 2-3 sentences...      # Description
G:keyword1 keyword2 keyword3           # Search keywords

U[5]:                                  # Use cases
  Use case 1
  Use case 2
  ...

S[6]{n,action,details}:                # Execution steps
  1,Analyze,Understand the request
  2,Plan,Create approach
  ...

R[5]:                                  # Rules/Best practices
  Best practice 1
  Best practice 2
  ...

E[2]{desc,in,out}:                     # Examples
  "Basic usage","Input","Output"
```

### Token Optimization Comparison

| Mode | File | Avg Tokens | Reduction |
|:-----|:-----|:-----------|:----------|
| **full** | SKILL.md | ~2,198 | - |
| **toon** | SKILL.toon | ~112 | **94.9%** |

---

## Architecture (Flat Structure)

```
.agent-skills/
├── skills.json              # Skill manifest (auto-generated)
├── skills.toon              # Token-optimized summary (auto-generated)
├── skill_loader.py          # Skill loading core
├── skill-query-handler.py   # Natural language query handler
│
├── agent-configuration/     # All 57 skill folders at root level
├── api-design/
├── authentication-setup/
├── ... (all skills)
│
└── templates/               # Skill templates
    ├── toon-skill-template/ # TOON format (default)
    ├── basic-skill-template/
    └── advanced-skill-template/
```

> **v4.3.0 Change**: Category folders removed, all skills flattened to root level

---

## Explore Additional Skills

Looking for more AI agent skills?

Visit **[Awesome Claude Skills](https://github.com/ComposioHQ/awesome-claude-skills)** to explore and install 100+ community-created skills.

```bash
# Search skills
npx skills search "code review"

# Install from Awesome Claude Skills
npx skills add https://github.com/ComposioHQ/awesome-claude-skills --skill github-automation

# Browse all: https://github.com/ComposioHQ/awesome-claude-skills
```

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Version**: 4.3.0 | **Updated**: 2026-02-06 | **Skills**: 57 | **Format**: TOON (Default) | **Structure**: Flat

**Changelog v4.3.0**:
- **Flat structure**: Removed category folders, all 57 skills at root level
- **English translations**: Translated all agentic skills to English
- **Awesome Claude Skills integration**: Added prominent installation guide for community skills
- **Documentation update**: Comprehensive README updates reflecting new structure

**Changelog v4.2.0**:
- **Superwork skill added**: Opus extended thinking for analysis/synthesis/decision-making
- **Alias support**: `superwork`, `spw`, `super-work`, `opus-work` keywords

**Changelog v4.0.0**:
- **Installation method change**: Unified to `npx skills add` format
- **TOON format by default**: 95% token reduction
- **Compact file removal**: Integrated into TOON
- **README simplification**: Core content only
