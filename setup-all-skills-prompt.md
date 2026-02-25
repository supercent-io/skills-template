# Agent Skills — 전체 설정 프롬프트

이 파일을 AI 에이전트에게 전달하면 모든 스킬을 한 번에 설정합니다.

---

## 실행 지침

다음 명령을 실행해서 65개 스킬을 설치하세요:

```bash
npx skills add https://github.com/supercent-io/skills-template \
  --skill agent-configuration --skill agent-evaluation \
  --skill agentic-development-principles --skill agentic-principles \
  --skill agentic-workflow --skill bmad-orchestrator \
  --skill prompt-repetition --skill api-design \
  --skill api-documentation --skill authentication-setup \
  --skill backend-testing --skill database-schema-design \
  --skill design-system --skill react-best-practices \
  --skill responsive-design --skill state-management \
  --skill ui-component-patterns --skill web-accessibility \
  --skill web-design-guidelines --skill code-refactoring \
  --skill code-review --skill debugging \
  --skill performance-optimization --skill testing-strategies \
  --skill deployment-automation --skill firebase-ai-logic \
  --skill genkit --skill looker-studio-bigquery \
  --skill monitoring-observability --skill security-best-practices \
  --skill system-environment-setup --skill vercel-deploy \
  --skill changelog-maintenance --skill presentation-builder \
  --skill technical-writing --skill user-guide-writing \
  --skill sprint-retrospective --skill standup-meeting \
  --skill task-estimation --skill task-planning \
  --skill codebase-search --skill data-analysis \
  --skill log-analysis --skill pattern-detection \
  --skill image-generation --skill pollinations-ai \
  --skill video-production --skill marketing-automation \
  --skill agent-browser --skill copilot-coding-agent \
  --skill environment-setup --skill file-organization \
  --skill git-submodule --skill git-workflow --skill jeo \
  --skill npm-git-install --skill ohmg --skill oh-my-codex \
  --skill omc --skill opencontext --skill plannotator \
  --skill ralph --skill skill-standardization \
  --skill vibe-kanban --skill workflow-automation
```

---

## 각 AI 플랫폼별 설정

### Claude Code

설치 후 Claude Code 대화에서:

```
jeo 스킬을 설정하고 사용해줘. 기억해.
```

또는 oh-my-claudecode 전체 설치:

```bash
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/omc:omc-setup
```

### Gemini CLI

```bash
gemini extensions install https://github.com/supercent-io/skills-template
```

### OpenAI Codex CLI

```bash
npx skills add https://github.com/supercent-io/skills-template --skill oh-my-codex
```

### OpenCode

```bash
npx skills add https://github.com/supercent-io/skills-template
```

---

## 핵심 스킬 빠른 활성화

| 스킬 | 활성화 키워드 | 설명 |
|------|-------------|------|
| `jeo` | `jeo` | 통합 오케스트레이션 (권장 시작점) |
| `omc` | `omc`, `autopilot` | Claude Code 멀티에이전트 |
| `ralph` | `ralph` | 완료 루프 |
| `plannotator` | `plan`, `계획` | 계획 검토 + Feedback loop |
| `vibe-kanban` | `kanbanview` | 칸반 보드 |
| `bmad-orchestrator` | `bmad` | 구조화 개발 |
| `agent-browser` | `agent-browser` | 헤드리스 브라우저 자동화 |
| `oh-my-codex` | `omx` | Codex CLI 멀티에이전트 |
| `ohmg` | `ohmg` | Gemini / Antigravity 워크플로우 |

---

## 설치 확인

설치 후 다음으로 확인:

```bash
# 설치된 스킬 목록 확인
npx skills list

# jeo 스킬 개별 확인
npx skills info jeo
```

설치 후 Claude Code 대화에서 jeo 스킬을 활성화하려면:

```
jeo 스킬을 설정하고 사용해줘. 기억해.
```

---

> 전체 스킬 목록 및 상세 설명: [README.md](README.md)
