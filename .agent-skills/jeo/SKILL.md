---
name: jeo
keyword: jeo
description: JEO — 통합 AI 에이전트 오케스트레이션 스킬. ralph+plannotator로 계획 수립, team/bmad로 실행, agent-browser로 vibe-kanban 상태 업데이트, 작업 완료 후 worktree 자동 정리. Claude, Codex, Gemini CLI, OpenCode 모두 지원. 설치: ralph, omc, omx, ohmg, bmad, agent-browser, playwriter, plannotator, vibe-kanban.
allowed-tools: [Read, Write, Bash, Grep, Glob, Task]
tags: [jeo, orchestration, ralph, plannotator, team, bmad, vibe-kanban, agent-browser, omc, omx, ohmg, playwriter, multi-agent, workflow, kanban, worktree-cleanup]
platforms: [Claude, Codex, Gemini, OpenCode]
version: 1.0.0
source: supercent-io/skills-template
compatibility: Requires git, node>=18, bash. Optional: bun, docker.
metadata:
  author: supercent-io
  keyword: jeo
---

# JEO — Integrated Agent Orchestration

> Keyword: `jeo` | Platforms: Claude Code · Codex CLI · Gemini CLI · OpenCode
>
> 계획(ralph+plannotator) → 실행(team/bmad) → 추적(vibe-kanban+agent-browser) → 정리(worktree cleanup)
> 의 완전 자동화 오케스트레이션 플로우를 제공하는 통합 스킬.

---

## 1. Quick Start

```bash
# 전체 설치 (모든 AI 툴 + 모든 컴포넌트)
bash scripts/install.sh --all

# 상태 확인
bash scripts/check-status.sh

# 각 AI 툴 개별 설정
bash scripts/setup-claude.sh      # Claude Code 플러그인 + 훅
bash scripts/setup-codex.sh       # Codex CLI developer_instructions
bash scripts/setup-gemini.sh      # Gemini CLI 훅 + GEMINI.md
bash scripts/setup-opencode.sh    # OpenCode 플러그인 등록
```

---

## 2. 설치 컴포넌트

JEO가 설치하고 설정하는 도구 목록:

| 도구 | 설명 | 설치 명령 |
|------|------|-----------|
| **omc** (oh-my-claudecode) | Claude Code 멀티에이전트 오케스트레이션 | `/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode` |
| **omx** | OpenCode용 멀티에이전트 오케스트레이션 | `bunx oh-my-opencode setup` |
| **ohmg** | Gemini CLI용 멀티에이전트 프레임워크 | `bunx oh-my-ag` |
| **bmad** | BMAD 워크플로우 오케스트레이션 | skills에 포함됨 |
| **ralph** | 자기참조 완료 루프 | omc에 포함 또는 별도 설치 |
| **plannotator** | 계획/diff 시각적 리뷰 | `bash scripts/install.sh --with-plannotator` |
| **agent-browser** | AI 에이전트용 헤드리스 브라우저 | `npm install -g agent-browser` |
| **playwriter** | Playwright 기반 브라우저 자동화 | `npm install -g playwriter` |
| **vibe-kanban** | AI Kanban 보드 (git worktree 자동화) | `npx vibe-kanban` |

---

## 3. JEO 워크플로우

### 전체 플로우

```
jeo "<task>"
    │
    ▼
[1] PLAN (ralph + plannotator)
    ralph으로 계획 수립 → plannotator로 시각적 검토 → Approve/Feedback
    │
    ▼
[2] EXECUTE
    ├─ team 사용 가능? → /omc:team N:executor "<task>"
    │                    staged pipeline: plan→prd→exec→verify→fix
    └─ team 없음?     → /bmad /workflow-init → BMAD 단계 실행
    │
    ▼
[3] TRACK (vibe-kanban + agent-browser)
    agent-browser로 vibe-kanban 보드 접속
    → 작업 카드 상태 실시간 업데이트 (In Progress → Review → Done)
    │
    ▼
[4] CLEANUP
    모든 작업 완료 후 → bash scripts/worktree-cleanup.sh
    git worktree prune + vibe-kanban 생성 worktree 삭제
```

### 3.1 PLAN 단계 (ralph + plannotator)

> **플랫폼 노트**: `/ralph` 슬래시 커맨드는 Claude Code (omc)에서만 사용 가능합니다.
> Codex/Gemini/OpenCode에서는 아래 "대체 방법"을 사용하세요.

**Claude Code (omc):**
```bash
/ralph "jeo-plan: <task>" --completion-promise="PLAN_APPROVED" --max-iterations=5
```

**Codex / Gemini / OpenCode (대체):**
```bash
# 1. plan.md 직접 작성 후 plannotator로 검토
cat plan.md | python3 -c "
import json, sys
plan = sys.stdin.read()
print(json.dumps({'tool_input': {'plan': plan, 'permission_mode': 'acceptEdits'}}))
" | plannotator > /tmp/plannotator_feedback.txt 2>&1 &
```

공통 플로우:
- 계획 문서 (`plan.md`) 생성
- plannotator UI 실행 (ExitPlanMode 훅 또는 수동)
- 브라우저에서 계획 검토 → Approve 또는 Send Feedback
- Approve → [2] EXECUTE 단계 진입
- Feedback → 재계획 (루프)

**Claude Code 수동 실행:**
```
Shift+Tab×2 → plan mode 진입 → 계획 완료 시 plannotator 자동 실행
```

### 3.2 EXECUTE 단계

**team 사용 가능한 경우 (Claude Code + omc):**
```bash
/omc:team 3:executor "jeo-exec: <task based on approved plan>"
```
- staged pipeline: team-plan → team-prd → team-exec → team-verify → team-fix
- 병렬 에이전트 실행으로 속도 최대화

**team 없는 경우 (BMAD fallback):**
```bash
/workflow-init   # BMAD 워크플로우 초기화
/workflow-status # 현재 단계 확인
```
- Analysis → Planning → Solutioning → Implementation 순서로 진행
- 각 단계 완료 시 plannotator로 문서 검토

### 3.3 TRACK 단계 (vibe-kanban + agent-browser)

```bash
# vibe-kanban 시작 (별도 터미널)
npx vibe-kanban

# agent-browser로 Kanban 보드 자동 업데이트
agent-browser open http://localhost:3000
agent-browser snapshot -i
# → @eN ref로 카드 상태 조작
```

**MCP 모드 사용 시 (에이전트 직접 API 호출):**
```bash
npx vibe-kanban --mcp
# 에이전트가 MCP 프로토콜로 카드 CRUD 직접 처리
```

### 3.4 CLEANUP 단계 (worktree 자동 정리)

```bash
# 모든 작업 완료 후 자동 실행
bash scripts/worktree-cleanup.sh

# 개별 명령
git worktree list              # 현재 worktree 목록 확인
git worktree prune             # 삭제된 브랜치 worktree 정리
bash scripts/worktree-cleanup.sh --force  # 강제 정리
```

---

## 4. 플랫폼별 플러그인 설정

### 4.1 Claude Code

```bash
# 자동 설정
bash scripts/setup-claude.sh

# 또는 수동으로:
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/plugin install oh-my-claudecode
/omc:omc-setup

# plannotator 훅 추가
bash .agent-skills/plannotator/scripts/setup-hook.sh
```

**설정 파일**: `~/.claude/settings.json`
```json
{
  "hooks": {
    "ExitPlanMode": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "plannotator plan -"
      }]
    }]
  }
}
```

### 4.2 Codex CLI

```bash
# 자동 설정
bash scripts/setup-codex.sh

# developer_instructions 추가됨: ~/.codex/config.toml
# prompt 파일 생성됨: ~/.codex/prompts/jeo.md
```

Codex에서 사용:
```bash
/prompts:jeo    # JEO 워크플로우 활성화
```

### 4.3 Gemini CLI

```bash
# 자동 설정
bash scripts/setup-gemini.sh

# ExitPlanMode 훅 추가됨: ~/.gemini/settings.json
# 지시사항 추가됨: ~/.gemini/GEMINI.md
```

Gemini에서 사용:
```bash
gemini --approval-mode plan    # plan 모드로 진입 → plannotator 자동 실행
```

### 4.4 OpenCode

```bash
# 자동 설정
bash scripts/setup-opencode.sh

# opencode.json에 추가됨:
# "@jeo/opencode@latest" 플러그인
```

OpenCode 슬래시 커맨드:
- `/jeo-plan` — ralph + plannotator로 계획 수립
- `/jeo-exec` — team/bmad로 실행
- `/jeo-status` — vibe-kanban 상태 확인
- `/jeo-cleanup` — worktree 정리

---

## 5. 기억/상태 유지 (Memory & State)

JEO는 아래 경로에 상태를 저장합니다:

```
{worktree}/.omc/state/jeo-state.json   # JEO 실행 상태
{worktree}/.omc/plans/jeo-plan.md      # 승인된 계획
{worktree}/.omc/logs/jeo-*.log         # 실행 로그
```

**상태 파일 구조:**
```json
{
  "phase": "plan|execute|track|cleanup",
  "task": "현재 작업 설명",
  "plan_approved": true,
  "team_available": true,
  "kanban_url": "http://localhost:3000",
  "worktrees": ["path/to/worktree1", "path/to/worktree2"],
  "created_at": "2026-02-24T00:00:00Z",
  "updated_at": "2026-02-24T00:00:00Z"
}
```

재시작 후 복원:
```bash
# 상태 확인 및 재개
bash scripts/check-status.sh --resume
```

---

## 6. 권장 워크플로우

```
# 1단계: 설치 (최초 1회)
bash scripts/install.sh --all
bash scripts/check-status.sh

# 2단계: 작업 시작
jeo "<작업 설명>"           # 키워드로 활성화
# 또는 Claude에서: Shift+Tab×2 → plan mode

# 3단계: plannotator로 계획 검토
# 브라우저 UI에서 Approve 또는 Send Feedback

# 4단계: 자동 실행
# team 또는 bmad가 작업 처리
# vibe-kanban에서 진행 상황 시각적 확인

# 5단계: 완료 후 정리
bash scripts/worktree-cleanup.sh
```

---

## 7. Best Practices

1. **계획 먼저**: ralph+plannotator로 항상 계획 검토 후 실행 (잘못된 접근 조기 차단)
2. **team 우선**: Claude Code에서는 omc team 모드 사용이 가장 효율적
3. **bmad fallback**: team 없는 환경(Codex, Gemini)에서 BMAD 사용
4. **worktree 정리**: 작업 완료 즉시 `worktree-cleanup.sh` 실행 (브랜치 오염 방지)
5. **kanban 범위**: vibe-kanban 카드는 1카드=1커밋 단위로 좁게 유지
6. **상태 저장**: `.omc/state/jeo-state.json`으로 세션 간 상태 유지

---

## 8. Troubleshooting

| 문제 | 해결 |
|------|------|
| plannotator 미실행 | `bash .agent-skills/plannotator/scripts/check-status.sh` |
| vibe-kanban 포트 충돌 | `PORT=3001 npx vibe-kanban` |
| worktree 충돌 | `git worktree prune && git worktree list` |
| team 모드 미동작 | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 환경변수 설정 |
| omc 설치 실패 | `/omc:omc-doctor` 실행 |
| agent-browser 오류 | `agent-browser --version` 확인 |

---

## 9. References

- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — Claude Code 멀티에이전트
- [plannotator](https://plannotator.ai) — 계획/diff 시각적 리뷰
- [vibe-kanban](https://github.com/BloopAI/vibe-kanban) — AI Kanban 보드
- [agent-browser](https://github.com/anthropics/agent-browser) — AI 헤드리스 브라우저
- [BMAD Method](https://github.com/bmad-dev/BMAD-METHOD) — 구조화된 AI 개발 워크플로우
- [Agent Skills Spec](https://agentskills.io/specification) — 스킬 포맷 명세
