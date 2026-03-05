# Agent Skills — LLM 설치 위임 가이드

> 이 파일을 AI 에이전트에게 전달하면 설치를 자동으로 진행합니다.
>
> ```bash
> curl -s https://raw.githubusercontent.com/supercent-io/skills-template/main/setup-all-skills-prompt.md
> ```

---

## 에이전트 지침 (Agent Instructions)

이 파일을 받은 AI 에이전트는 다음 단계를 **순서대로** 실행하세요.

### UltraTeam 합의 원칙 (시스템엔지니어 · 초심 사용자 · 가이드라이너)

- 시스템엔지니어 관점: 실행 결과가 항상 같도록 기본값을 명확히 고정하고(Full install), 설치 경로를 탐지/동기화해 플랫폼별 경로 차이를 제거합니다.
- 초심 사용자 관점: 모호한 조건부 문구를 제거하고, 별도 요청이 없으면 자동으로 전체 설치를 수행합니다.
- 가이드라이너 관점: "건너뛰기" 조건은 명시적으로 제한합니다. 사용자가 `핵심만`, `최소 설치`, `빠른 설치`를 정확히 요청한 경우에만 Step 2를 생략합니다.

### 실행 정책 (필수)

- 기본 실행: `Step 1` 실행 후 `Step 2`까지 연속 실행 (기본값은 전체 설치)
- 예외 실행: 사용자가 `핵심만` 또는 `최소 설치`를 명시한 경우에만 `Step 2` 생략
- 금지: `Step 2` 실행 전에 추가 확인 질문으로 멈추는 동작

---

### Step 0: 사용자 환경 파악

설치 전 다음을 확인하세요:

1. **사용 중인 AI 플랫폼은 무엇인가요?**
   - Claude Code → `omc`, `plannotator`, `ralph`, `bmad-orchestrator` 권장
   - Gemini CLI → `ohmg`, `ralph`, `jeo` 권장
   - OpenAI Codex CLI → `oh-my-codex`, `ralph`, `jeo` 권장
   - OpenCode → oh-my-opencode 설치 필요 (Step 3 참조)
   - 모두 사용 / 모르겠음 → `jeo` 단일 설치 (전 플랫폼 통합)

2. **`skills` CLI가 설치되어 있나요?**

```bash
if command -v skills &> /dev/null; then
    echo "skills CLI available"
else
    echo "npx를 통해 설치합니다"
fi
```

3. **설치 경로 표준화 변수 선언**

```bash
# Canonical path (권장 기본 경로)
export SKILLS_CANONICAL="${HOME}/.agent-skills"
# 기존 설치 디렉터리가 있으면 제거 후 새로 생성
if [ -d "${SKILLS_CANONICAL}" ]; then
    echo "기존 설치 디렉터리 제거: ${SKILLS_CANONICAL}"
    rm -rf "${SKILLS_CANONICAL}"
fi
mkdir -p "${SKILLS_CANONICAL}"
```

---

### Step 1: 핵심 스킬 설치 (플랫폼별 최소 설치)

Step 0 결과에 따라 실행하세요:

**모든 플랫폼 (권장 시작점):**
```bash
npx skills add https://github.com/supercent-io/skills-template --skill jeo
```

**Claude Code 전용:**
```bash
npx skills add https://github.com/supercent-io/skills-template \
  --skill omc --skill plannotator --skill ralph --skill vibe-kanban
```

**Gemini CLI 전용:**
```bash
npx skills add https://github.com/supercent-io/skills-template \
  --skill ohmg --skill ralph --skill vibe-kanban
```

**Codex CLI 전용:**
```bash
npx skills add https://github.com/supercent-io/skills-template \
  --skill oh-my-codex --skill ralph
```

**Gemini CLI (확장 설치):**
```bash
gemini extensions install https://github.com/supercent-io/skills-template
```

---

### Step 2: 전체 70개 스킬 설치 (기본 실행 단계)

```bash
npx skills add https://github.com/supercent-io/skills-template \
  --skill agent-configuration --skill agent-evaluation \
  --skill agentic-development-principles --skill agentic-principles \
  --skill agentic-workflow --skill bmad-orchestrator \
  --skill bmad-gds --skill bmad-idea \
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
  --skill llm-monitoring-dashboard \
  --skill image-generation --skill pollinations-ai \
  --skill video-production --skill marketing-automation \
  --skill agent-browser --skill agentation --skill copilot-coding-agent \
  --skill ai-tool-compliance \
  --skill environment-setup --skill file-organization \
  --skill git-submodule --skill git-workflow --skill jeo \
  --skill npm-git-install --skill ohmg --skill oh-my-codex \
  --skill omc --skill opencontext --skill plannotator \
  --skill ralph --skill skill-standardization \
  --skill vibe-kanban --skill workflow-automation
```

> 생략 조건은 사용자 명시 요청(`핵심만`, `최소 설치`, `빠른 설치`)일 때만 허용합니다.

---

### Step 3: 플랫폼별 추가 도구 설치

#### Claude Code — oh-my-claudecode

```bash
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/omc:omc-setup
```

또는 Claude Code 대화에서:
```
jeo 스킬을 설정하고 사용해줘. 기억해.
```

#### OpenCode — oh-my-opencode

최신 설치 가이드를 fetch해서 구독 환경에 맞게 설치하세요:

```bash
# oh-my-opencode 최신 설치 가이드 fetch — 구독 환경에 맞는 플래그 확인 후 실행
curl -s https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/refs/heads/master/docs/guide/installation.md
```

가이드에서 구독 상태(Claude Pro/Max, Gemini, Copilot 등)에 맞는 설치 플래그를 확인하고 설치를 진행합니다.

설치 후 스킬 추가:
```bash
npx skills add https://github.com/supercent-io/skills-template
```

#### Gemini CLI — 확인

```bash
# Gemini CLI 훅 설정 확인
ls ~/.gemini/ 2>/dev/null && echo "Gemini configured" || echo "Gemini not configured"
```

> [Hooks 공식 가이드](https://developers.googleblog.com/tailor-gemini-cli-to-your-workflow-with-hooks/)

---

### Step 4: 설치 확인 및 활성화 안내

```bash
# 설치 디렉터리 자동 탐지
if [ -d "${HOME}/.agent-skills" ]; then
  SKILL_SRC="${HOME}/.agent-skills"
elif [ -d "${PWD}/.agent-skills" ]; then
  SKILL_SRC="${PWD}/.agent-skills"
elif [ -d "${PWD}/.agents/skills" ]; then
  SKILL_SRC="${PWD}/.agents/skills"
else
  echo "skills directory not found"; exit 1
fi

echo "Detected skills dir: ${SKILL_SRC}"

# Canonical 경로로 동기화
mkdir -p "${HOME}/.agent-skills"
if [ "${SKILL_SRC}" != "${HOME}/.agent-skills" ]; then
  cp -R "${SKILL_SRC}"/. "${HOME}/.agent-skills"/
fi

# 플랫폼별 기존 skills 디렉터리 제거 후 새로 생성
for dest in \
    "${HOME}/.claude/skills" "${PWD}/.claude/skills" \
    "${HOME}/.codex/skills" "${PWD}/.codex/skills" \
    "${HOME}/.gemini/skills" "${PWD}/.gemini/skills" \
    "${HOME}/.opencode/skills" "${PWD}/.opencode/skills" \
    "${HOME}/.config/opencode/skills" "${PWD}/.config/opencode/skills"; do
    rm -rf "${dest}"
    mkdir -p "${dest}"
done

cp -R "${HOME}/.agent-skills"/. "${HOME}/.claude/skills"/
cp -R "${HOME}/.agent-skills"/. "${PWD}/.claude/skills"/
cp -R "${HOME}/.agent-skills"/. "${HOME}/.codex/skills"/
cp -R "${HOME}/.agent-skills"/. "${PWD}/.codex/skills"/
cp -R "${HOME}/.agent-skills"/. "${HOME}/.gemini/skills"/
cp -R "${HOME}/.agent-skills"/. "${PWD}/.gemini/skills"/
cp -R "${HOME}/.agent-skills"/. "${HOME}/.opencode/skills"/
cp -R "${HOME}/.agent-skills"/. "${PWD}/.opencode/skills"/
cp -R "${HOME}/.agent-skills"/. "${HOME}/.config/opencode/skills"/
cp -R "${HOME}/.agent-skills"/. "${PWD}/.config/opencode/skills"/

# 설치된 스킬 목록 확인
ls "${HOME}/.agent-skills" 2>/dev/null
ls "${HOME}/.claude/skills" 2>/dev/null
ls "${HOME}/.codex/skills" 2>/dev/null
ls "${HOME}/.gemini/skills" 2>/dev/null
ls "${HOME}/.opencode/skills" 2>/dev/null
ls "${HOME}/.config/opencode/skills" 2>/dev/null

# 개별 스킬 확인
npx skills info jeo
```

설치 완료 후 플랫폼별 첫 실행:

| 플랫폼 | 실행 명령 |
|--------|-----------|
| Claude Code | `jeo "작업 내용"` 또는 `/omc:team "작업"` |
| Gemini CLI | `/jeo "작업 내용"` |
| Codex CLI | `/jeo "작업 내용"` |
| OpenCode | `/jeo "작업 내용"` |

---

## 핵심 스킬 키워드 참조

| 스킬 | 활성화 키워드 | 설명 |
|------|-------------|------|
| `jeo` | `jeo` | 통합 오케스트레이션 (권장 시작점) |
| `omc` | `omc`, `autopilot` | Claude Code 멀티에이전트 |
| `ralph` | `ralph`, `ooo`, `ooo ralph`, `ooo interview` | Ouroboros 기반 specification-first 개발 (Interview→Seed→Execute→Evaluate→Evolve) + 영구 완료 루프 |
| `plannotator` | `plan`, `계획` | 계획 검토 + Feedback loop |
| `vibe-kanban` | `kanbanview` | 칸반 보드 |
| `bmad-orchestrator` | `bmad` | 구조화 개발 |
| `bmad-gds` | `bmad-gds` | 게임 개발 스튜디오 (Unity/Unreal/Godot) |
| `bmad-idea` | `bmad-idea` | 창의적 아이디어 · 디자인 씽킹 · 혁신 전략 |
| `ai-tool-compliance` | `ai-tool-compliance` | 내부 AI 툴 컴플라이언스 자동화(P0/P1) |
| `agent-browser` | `agent-browser` | 헤드리스 브라우저 자동화 |
| `llm-monitoring-dashboard` | `llm-monitoring-dashboard` | LLM 사용량 모니터링 대시보드 생성 |
| `agentation` | `annotate`, `UI검토`, `agentui` | UI 어노테이션 → 에이전트 코드 수정 (annotate watch loop) |
| `oh-my-codex` | `omx` | Codex CLI 멀티에이전트 |
| `ohmg` | `ohmg` | Gemini / Antigravity 워크플로우 |

---

> 전체 스킬 목록 및 상세 설명: [README.md](README.md)
