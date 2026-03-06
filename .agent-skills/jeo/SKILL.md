---
name: jeo
description: "JEO — 통합 AI 에이전트 오케스트레이션 스킬. ralph+plannotator로 계획 수립, team/bmad로 실행, agent-browser로 브라우저 동작 검증, agentation(annotate)으로 UI 피드백 반영, 작업 완료 후 worktree 자동 정리. Claude, Codex, Gemini CLI, OpenCode 모두 지원. 설치: ralph, omc, omx, ohmg, bmad, plannotator, agent-browser, agentation."
compatibility: "Requires git, node>=18, bash. Optional: bun, docker."
allowed-tools: Read Write Bash Grep Glob Task
metadata:
  tags: jeo, orchestration, ralph, plannotator, agentation, annotate, agentui, UI검토, team, bmad, omc, omx, ohmg, agent-browser, multi-agent, workflow, worktree-cleanup, browser-verification, ui-feedback
  platforms: Claude, Codex, Gemini, OpenCode
  keyword: jeo
  version: 1.0.0
  source: supercent-io/skills-template
---


# JEO — Integrated Agent Orchestration

> Keyword: `jeo` · `annotate` · `UI검토` · `agentui (deprecated)` | Platforms: Claude Code · Codex CLI · Gemini CLI · OpenCode
>
> 계획(ralph+plannotator) → 실행(team/bmad) → UI 피드백(agentation/annotate) → 정리(worktree cleanup)
> 의 완전 자동화 오케스트레이션 플로우를 제공하는 통합 스킬.

---

## 0. 에이전트 실행 프로토콜 (jeo 키워드 감지 시 즉시 따를 것)

> 아래는 설명이 아닌 명령이다. 순서대로 정확히 실행한다. 각 단계는 완료 후에만 다음으로 진입한다.

### STEP 0: 상태 파일 부트스트랩 (필수 — 항상 첫 번째)

```bash
mkdir -p .omc/state .omc/plans .omc/logs
```

`.omc/state/jeo-state.json` 이 없으면 생성:

```json
{
  "phase": "plan",
  "task": "<감지된 task>",
  "plan_approved": false,
  "team_available": null,
  "worktrees": [],
  "retry_count": 0,
  "last_error": null,
  "checkpoint": null,
  "created_at": "<ISO 8601>",
  "updated_at": "<ISO 8601>",
  "agentation": {
    "active": false,
    "session_id": null,
    "keyword_used": null,
    "started_at": null,
    "timeout_seconds": 120,
    "annotations": { "total": 0, "acknowledged": 0, "resolved": 0, "dismissed": 0, "pending": 0 },
    "completed_at": null,
    "exit_reason": null
  }
}
```

사용자에게 고지:
> "JEO 활성화됨. Phase: PLAN. UI 피드백 루프 필요 시 `annotate` 키워드를 추가하세요."

---

### STEP 0.1: 에러 복구 프로토콜 (모든 STEP에 적용)

**checkpoint 기록 — 각 STEP 진입 직후:**
```python
# 각 STEP 시작 시 즉시 실행 (에이전트가 직접 jeo-state.json 업데이트)
python3 -c "
import json, datetime, os
f='.omc/state/jeo-state.json'
if os.path.exists(f):
    d=json.load(open(f))
    d['checkpoint']='<current_phase>'   # 'plan'|'execute'|'verify'|'cleanup'
    d['updated_at']=datetime.datetime.utcnow().isoformat()+'Z'
    json.dump(d,open(f,'w'),indent=2)
" 2>/dev/null || true
```

**last_error 기록 — Pre-flight 실패 또는 예외 발생 시:**
```python
python3 -c "
import json, datetime, os
f='.omc/state/jeo-state.json'
if os.path.exists(f):
    d=json.load(open(f))
    d['last_error']='<에러 메시지>'
    d['retry_count']=d.get('retry_count',0)+1
    d['updated_at']=datetime.datetime.utcnow().isoformat()+'Z'
    json.dump(d,open(f,'w'),indent=2)
" 2>/dev/null || true
```

**재시작 시 checkpoint 기반 재개:**
```python
# jeo-state.json이 이미 존재하면 checkpoint에서 재개
python3 -c "
import json, os
f='.omc/state/jeo-state.json'
if os.path.exists(f):
    d=json.load(open(f))
    cp=d.get('checkpoint')
    err=d.get('last_error')
    if err: print(f'이전 오류: {err}')
    if cp: print(f'재개 위치: {cp}')
" 2>/dev/null || true
```

> **규칙**: Pre-flight에서 `exit 1` 전에 반드시 `last_error` 업데이트 + `retry_count` 증가.
> `retry_count >= 3` 시 사용자에게 중단 여부를 확인하세요.

---

### STEP 1: PLAN (건너뛰기 절대 금지)

**Pre-flight (진입 전 필수):**
```bash
# checkpoint 기록
python3 -c "import json,datetime,os; f='.omc/state/jeo-state.json'; d=json.load(open(f)) if os.path.exists(f) else {}; d.update({'checkpoint':'plan','updated_at':datetime.datetime.utcnow().isoformat()+'Z'}); json.dump(d,open(f,'w'),indent=2)" 2>/dev/null || true

# plannotator 확인
command -v plannotator >/dev/null 2>&1 || {
  python3 -c "import json,datetime,os; f='.omc/state/jeo-state.json'; d=json.load(open(f)) if os.path.exists(f) else {}; d.update({'last_error':'plannotator 미설치','retry_count':d.get('retry_count',0)+1,'updated_at':datetime.datetime.utcnow().isoformat()+'Z'}); json.dump(d,open(f,'w'),indent=2)" 2>/dev/null || true
  echo "❌ plannotator 미설치 — bash scripts/install.sh --with-plannotator"; exit 1
}
mkdir -p .omc/plans .omc/logs
```

1. `plan.md` 작성 (목표, 단계, 리스크, 완료 기준 포함)
2. **plannotator 호출** (플랫폼별):
   - **Claude Code**: `submit_plan` MCP 도구 직접 호출
   - **Codex / Gemini / OpenCode**: blocking CLI 실행 (`&` 절대 금지):
     ```bash
     python3 -c "import json,sys; plan=open('plan.md').read(); sys.stdout.write(json.dumps({'tool_input':{'plan':plan,'permission_mode':'acceptEdits'}}))" | plannotator > /tmp/plannotator_feedback.txt 2>&1
     ```
3. 결과 확인:
   - `approved: true` → `jeo-state.json`의 `phase`를 `"execute"`, `plan_approved`를 `true`로 업데이트 → **STEP 2 진입**
   - 미승인 → `/tmp/plannotator_feedback.txt` 읽고 피드백 반영 → `plan.md` 수정 → 2번 반복

**NEVER: `approved: true` 없이 EXECUTE 진입. NEVER: `&` 백그라운드 실행.**

---

### STEP 2: EXECUTE

**Pre-flight (team 가용 여부 자동 감지):**
```bash
# checkpoint 기록
python3 -c "import json,datetime,os; f='.omc/state/jeo-state.json'; d=json.load(open(f)) if os.path.exists(f) else {}; d.update({'checkpoint':'execute','updated_at':datetime.datetime.utcnow().isoformat()+'Z'}); json.dump(d,open(f,'w'),indent=2)" 2>/dev/null || true

TEAM_AVAILABLE=false
if [[ -n "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-}" ]] || \
   grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" "${HOME}/.claude/settings.json" 2>/dev/null; then
  TEAM_AVAILABLE=true
fi
python3 -c "import json,os; f='.omc/state/jeo-state.json'; d=json.load(open(f)); d['team_available']=('${TEAM_AVAILABLE}'=='true'); json.dump(d,open(f,'w'),indent=2)" 2>/dev/null || true
```

1. `jeo-state.json`의 `phase`를 `"execute"`로 업데이트
2. **team 사용 가능 (Claude Code + omc)**:
   ```
   /omc:team 3:executor "<task>"
   ```
3. **team 없음 (BMAD fallback)**:
   ```
   /workflow-init   # BMAD 초기화
   /workflow-status # 단계 확인
   ```

---

### STEP 3: VERIFY

1. `jeo-state.json`의 `phase`를 `"verify"`로 업데이트
2. **agent-browser로 기본 검증** (브라우저 UI 있을 때):
   ```bash
   agent-browser snapshot http://localhost:3000
   ```
3. `annotate` 키워드 감지 → **STEP 3.1로 진입**
4. 없으면 → **STEP 4로 진입**

---

### STEP 3.1: VERIFY_UI (annotate 키워드 감지 시만)

1. Pre-flight 확인 (진입 전 필수):
   ```bash
   curl -sf --connect-timeout 2 http://localhost:4747/health || { echo '❌ agentation-mcp 미실행'; exit 1; }
   ```
2. `jeo-state.json` 업데이트: `phase = "verify_ui"`, `agentation.active = true`
3. **Claude Code (MCP)**: `agentation_watch_annotations` 블로킹 호출 (`batchWindowSeconds:10`, `timeoutSeconds:120`)
4. **Codex / Gemini / OpenCode (HTTP)**: `GET http://localhost:4747/pending` 폴링 루프
5. 각 annotation 처리: `acknowledge` → `elementPath`로 코드 탐색 → 수정 → `resolve`
6. `count=0` 또는 timeout → **STEP 4로 진입**

---

### STEP 4: CLEANUP

**Pre-flight (진입 전 확인):**
```bash
# checkpoint 기록
python3 -c "import json,datetime,os; f='.omc/state/jeo-state.json'; d=json.load(open(f)) if os.path.exists(f) else {}; d.update({'checkpoint':'cleanup','updated_at':datetime.datetime.utcnow().isoformat()+'Z'}); json.dump(d,open(f,'w'),indent=2)" 2>/dev/null || true

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "⚠️ git 저장소 아님 — worktree 정리 건너뜀"
else
  UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  [[ "$UNCOMMITTED" -gt 0 ]] && echo "⚠️ 미커밋 변경 ${UNCOMMITTED}건 존재 — 정리 전 커밋/stash 권장"
fi
```

1. `jeo-state.json`의 `phase`를 `"cleanup"`으로 업데이트
2. worktree 정리:
   ```bash
   bash scripts/worktree-cleanup.sh || git worktree prune
   ```
3. `jeo-state.json`의 `phase`를 `"done"`으로 업데이트

---

## 1. Quick Start

> **소스 오브 트루스**: `https://github.com/supercent-io/skills-template`
> `~/.claude/skills/jeo/` 등 로컬 경로는 `npx skills add`로 설치된 사본입니다.
> 최신 버전으로 업데이트하려면 아래 명령으로 재설치하세요.

```bash
# JEO 설치 (npx skills add — 권장)
npx skills add https://github.com/supercent-io/skills-template --skill jeo

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
| **agentation** | UI 어노테이션 → 에이전트 코드 수정 연동 (`annotate` 키워드, `agentui` 호환 유지) | `bash scripts/install.sh --with-agentation` |
| **agent-browser** | AI 에이전트용 헤드리스 브라우저 — **브라우저 동작 검증 기본 도구** | `npm install -g agent-browser` |
| **playwriter** | Playwright 기반 브라우저 자동화 (선택) | `npm install -g playwriter` |

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
[3] VERIFY (agent-browser — 기본 동작)
    agent-browser로 브라우저 동작 검증
    → 스냅샷 캡처 → UI/기능 정상 여부 확인
    │
    ├─ annotate 키워드 시 → [3.3.1] VERIFY_UI (agentation watch loop)
    │   agentation_watch_annotations 블로킹 → annotation ack→fix→resolve 루프
    │
    ▼
[4] CLEANUP
    모든 작업 완료 후 → bash scripts/worktree-cleanup.sh
    git worktree prune
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
# 1. plan.md 직접 작성 후 plannotator로 검토 (블로킹 실행 — & 없음)
python3 -c "
import json
print(json.dumps({'tool_input': {'plan': open('plan.md').read(), 'permission_mode': 'acceptEdits'}}))
" | plannotator > /tmp/plannotator_feedback.txt 2>&1
# ↑ & 없이 실행: 사용자가 브라우저에서 Approve/Send Feedback 클릭까지 대기

# 2. 결과 확인 후 분기
if grep -q '"approved":true' /tmp/plannotator_feedback.txt 2>/dev/null; then
  echo "PLAN_APPROVED"   # → EXECUTE 단계 진입
else
  echo "PLAN_FEEDBACK"   # → cat /tmp/plannotator_feedback.txt 읽고 재계획 후 위 과정 반복
fi
```

> **중요**: `&` (백그라운드) 실행 금지. 블로킹으로 실행해야 사용자 피드백을 수신할 수 있습니다.

공통 플로우:
- 계획 문서 (`plan.md`) 생성
- plannotator 블로킹 실행 → 브라우저 UI 자동 오픈
- 브라우저에서 계획 검토 → Approve 또는 Send Feedback
- Approve (`"approved":true`) → [2] EXECUTE 단계 진입
- Feedback → `/tmp/plannotator_feedback.txt` annotations 읽고 재계획 (루프)

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

### 3.3 VERIFY 단계 (agent-browser — 기본 동작)

브라우저 기반 기능이 있을 경우 `agent-browser`로 동작을 검증합니다.

```bash
# 앱 실행 중인 URL에서 스냅샷 캡처
agent-browser snapshot http://localhost:3000

# 특정 요소 확인 (accessibility tree ref 방식)
agent-browser snapshot http://localhost:3000 -i
# → @eN ref 번호로 요소 상태 확인

# 스크린샷 저장
agent-browser screenshot http://localhost:3000 -o verify.png
```

> **기본 동작**: 브라우저 관련 작업 완료 시 자동으로 agent-browser 검증 단계를 실행합니다.
> 브라우저 UI가 없는 백엔드/CLI 작업은 이 단계를 건너뜁니다.

### 3.3.1 VERIFY_UI 단계 (annotate — agentation watch loop)

`annotate` 키워드 감지 시 agentation watch loop를 실행합니다. (`agentui` 키워드도 하위 호환으로 지원됩니다.)
plannotator가 `planui` / `ExitPlanMode`에서 동작하는 방식과 동일한 패턴입니다.

**전제 조건:**
1. `npx agentation-mcp server` (HTTP :4747) 실행 중
2. 앱에 `<Agentation endpoint="http://localhost:4747" />` 마운트

**Pre-flight Check (진입 전 확인 — 모든 플랫폼 공통):**
```bash
# Step 1: 서버 상태 확인
curl -sf --connect-timeout 2 http://localhost:4747/health >/dev/null 2>&1 \
  || { echo "❌ agentation-mcp 서버 미실행 — npx agentation-mcp server 실행 필요"; exit 1; }

# Step 2: 세션 존재 확인 (<Agentation> 컴포넌트 마운트 여부)
SESSIONS=$(curl -sf http://localhost:4747/sessions 2>/dev/null)
S_COUNT=$(echo "$SESSIONS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)
[ "$S_COUNT" -eq 0 ] && echo "⚠️ 활성 세션 없음 — <Agentation endpoint='http://localhost:4747' /> 마운트 필요"

# Step 3: 대기 annotation 확인
PENDING=$(curl -sf http://localhost:4747/pending 2>/dev/null)
P_COUNT=$(echo "$PENDING" | python3 -c "import sys,json; print(json.load(sys.stdin)['count'])" 2>/dev/null || echo 0)
echo "✅ agentation 준비 완료 — 서버 정상, 세션 ${S_COUNT}개, 대기 annotation ${P_COUNT}개"
```

> Pre-flight 통과 후 jeo-state.json `phase`를 `"verify_ui"`로 업데이트하고 `agentation.active`를 `true`로 설정.

**Claude Code (MCP 도구 직접 호출):**
```
# annotate 키워드 감지 (또는 agentui — 하위 호환) → MCP 통해 agentation_watch_annotations 블로킹 호출
# batchWindowSeconds:10 — 10초 단위로 annotation 일괄 수신
# timeoutSeconds:120   — 120초 동안 annotation 없으면 자동 종료
#
# 각 annotation 처리 루프:
# 1. agentation_acknowledge_annotation({id})           — UI에 '처리중' 표시
# 2. annotation.elementPath (CSS selector)로 코드 탐색 → 수정
# 3. agentation_resolve_annotation({id, summary})      — '완료' 마킹 + 요약 저장
#
# annotation이 없으면(count=0) 또는 timeout 시 루프 종료
```

> **중요**: `agentation_watch_annotations`는 블로킹 호출입니다. `&` 백그라운드 실행 금지.
> plannotator의 `approved:true` 루프와 동일하게: annotation count=0 또는 timeout = 완료 신호.
> `annotate` 키워드가 기본입니다. `agentui`는 하위 호환 별칭으로 동일하게 동작합니다.

**Codex / Gemini / OpenCode (HTTP REST API 폴백):**
```bash
# 1. Pending annotations 조회 (없으면 종료)
PENDING=$(curl -sf http://localhost:4747/pending 2>/dev/null)
COUNT=$(echo "$PENDING" | python3 -c "import sys,json; print(json.load(sys.stdin)['count'])" 2>/dev/null || echo 0)
[ "$COUNT" -eq 0 ] && echo 'No pending annotations — done' && exit 0

# 2. 각 annotation 보내 루프 (다음 코드를 count=0이 될 때까지 반복)
# a) Acknowledge (처리 중 표시)
curl -X PATCH http://localhost:4747/annotations/<id> \
  -H 'Content-Type: application/json' \
  -d '{"status": "acknowledged"}'

# b) elementPath (CSS selector)로 코드 탐색 → 수정 적용

# c) Resolve (완료 표시 + 수정 요약)
curl -X PATCH http://localhost:4747/annotations/<id> \
  -H 'Content-Type: application/json' \
  -d '{"status": "resolved", "resolution": "<수정 요약>"}'
```

### 3.4 CLEANUP 단계 (worktree 자동 정리)

```bash
# 모든 작업 완료 후 자동 실행
bash scripts/worktree-cleanup.sh

# 개별 명령
git worktree list                         # 현재 worktree 목록 확인
git worktree prune                        # 삭제된 브랜치 worktree 정리
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
    "PermissionRequest": [{
      "matcher": "ExitPlanMode",
      "hooks": [{
        "type": "command",
        "command": "plannotator",
        "timeout": 1800
      }]
    }]
  }
}
```

**agentation MCP 설정** (`~/.claude/settings.json` 또는 `.claude/mcp.json`):
```json
{
  "mcpServers": {
    "agentation": {
      "command": "npx",
      "args": ["-y", "agentation-mcp", "server"]
    }
  },
  "hooks": {
    "UserPromptSubmit": [{
      "type": "command",
      "command": "curl -sf --connect-timeout 1 http://localhost:4747/pending 2>/dev/null | python3 -c \"import sys,json;d=json.load(sys.stdin);c=d['count'];exit(0)if c==0 else print(f'=== AGENTATION: {c} annotations pending ===')\" 2>/dev/null;exit 0"
    }]
  }
}
```


### 4.2 Codex CLI

```bash
# 자동 설정
bash scripts/setup-codex.sh

# 설정 내용:
# - developer_instructions: ~/.codex/config.toml
# - prompt 파일: ~/.codex/prompts/jeo.md
# - notify hook: ~/.codex/hooks/jeo-notify.py
# - [tui] notifications: agent-turn-complete
```

**agentation MCP 설정** (`~/.codex/config.toml`):
```toml
[[mcp_servers]]
name = "agentation"
command = "npx"
args = ["-y", "agentation-mcp", "server"]
```


**notify hook** (`~/.codex/hooks/jeo-notify.py`):
- 에이전트 턴 완료 시 `last-assistant-message`에서 `PLAN_READY` 신호 감지
- `plan.md` 존재 확인 후 plannotator 자동 실행
- 결과를 `/tmp/plannotator_feedback.txt`에 저장
- `ANNOTATE_READY` 신호 (또는 하위 호환 `AGENTUI_READY`) 감지 시 `http://localhost:4747/pending` 폴링 → annotation HTTP API로 처리

**`~/.codex/config.toml`** 설정:
```toml
developer_instructions = """
# JEO Orchestration Workflow
# ...
"""

notify = ["python3", "~/.codex/hooks/jeo-notify.py"]

[tui]
notifications = ["agent-turn-complete"]
notification_method = "osc9"
```

> `developer_instructions`는 반드시 **top-level string**이어야 합니다.
> `[developer_instructions]` 테이블 형식으로 작성하면 Codex가 `invalid type: map, expected a string` 오류로 시작 실패할 수 있습니다.

Codex에서 사용:
```bash
/prompts:jeo    # JEO 워크플로우 활성화
# 에이전트가 plan.md 작성 후 "PLAN_READY" 출력 → notify hook 자동 실행
```

### 4.3 Gemini CLI

```bash
# 자동 설정
bash scripts/setup-gemini.sh

# 설정 내용:
# - AfterAgent backup hook: ~/.gemini/hooks/jeo-plannotator.sh
# - 지시사항 (MANDATORY loop): ~/.gemini/GEMINI.md
```

**핵심 원칙**: 에이전트가 plannotator를 **직접 blocking 호출**해야 같은 턴 피드백 가능.
AfterAgent 훅은 안전망 역할만 함 (턴 종료 후 실행 → 다음 턴에 주입).

**AfterAgent backup hook** (`~/.gemini/settings.json`):
```json
{
  "hooks": {
    "AfterAgent": [{
      "matcher": "",
      "hooks": [{
        "name": "plannotator-review",
        "type": "command",
        "command": "bash ~/.gemini/hooks/jeo-plannotator.sh",
        "description": "plan.md 감지 시 plannotator 실행 (AfterAgent backup)"
      }]
    }]
  }
}
```

**GEMINI.md에 추가되는 PLAN 지시 (mandatory loop)**:
```
1. plan.md 작성
2. plannotator blocking 실행 (& 금지) → /tmp/plannotator_feedback.txt
3. approved=true → EXECUTE / 미승인 → 수정 후 2번 반복
NEVER proceed to EXECUTE without approved=true.
```

**agentation MCP 설정** (`~/.gemini/settings.json`):
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

> **참고**: Gemini CLI 훅 이벤트는 `BeforeTool`, `AfterAgent`를 사용합니다.
> `ExitPlanMode`는 Claude Code 전용 훅입니다.

> [Hooks 공식 가이드](https://developers.googleblog.com/tailor-gemini-cli-to-your-workflow-with-hooks/)

### 4.4 OpenCode

```bash
# 자동 설정
bash scripts/setup-opencode.sh

# opencode.json에 추가됨:
# "@plannotator/opencode@latest" 플러그인
# "@oh-my-opencode/opencode@latest" 플러그인 (omx)
```

OpenCode 슬래시 커맨드:
- `/jeo-plan` — ralph + plannotator로 계획 수립
- `/jeo-exec` — team/bmad로 실행
- `/jeo-annotate` — agentation watch loop 시작 (annotate; `/jeo-agentui`는 deprecated 별칭)
- `/jeo-cleanup` — worktree 정리




**plannotator 연동** (MANDATORY blocking loop):
```bash
# plan.md 작성 후 blocking 실행 (& 금지) — 같은 턴 피드백 수신
python3 -c "import json,sys; plan=open('plan.md').read(); sys.stdout.write(json.dumps({'tool_input':{'plan':plan,'permission_mode':'acceptEdits'}}))" | plannotator > /tmp/plannotator_feedback.txt 2>&1

# 결과 확인 후 분기
# approved=true  → EXECUTE 진입
# not approved   → 피드백 반영 후 plan.md 수정 → 위 과정 반복
```


**agentation MCP 설정** (`opencode.json`):
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
  "phase": "plan|execute|verify|verify_ui|cleanup|done",
  "task": "현재 작업 설명",
  "plan_approved": true,
  "team_available": true,
  "worktrees": ["path/to/worktree1", "path/to/worktree2"],
  "retry_count": 0,
  "last_error": null,
  "checkpoint": "plan|execute|verify|verify_ui|cleanup",
  "created_at": "2026-02-24T00:00:00Z",
  "updated_at": "2026-02-24T00:00:00Z",
  "agentation": {
    "active": false,
    "session_id": null,
    "keyword_used": null,
    "started_at": null,
    "timeout_seconds": 120,
    "annotations": {
      "total": 0, "acknowledged": 0, "resolved": 0, "dismissed": 0, "pending": 0
    },
    "completed_at": null,
    "exit_reason": null
  }
}
```

> **agentation 필드**: `active` — watch loop 실행 여부 (hook guard 사용), `session_id` — 재개용,
> `exit_reason` — `"all_resolved"` | `"timeout"` | `"user_cancelled"` | `"error"`

> **에러 복구 필드**:
> - `retry_count` — 에러 후 재시도 횟수. Pre-flight 실패 때마다 +1. `≥ 3`이면 사용자에게 확인 요청.
> - `last_error` — 가장 최근 에러 메시지. 재시작 시 원인 파악에 사용.
> - `checkpoint` — 마지막으로 시작된 phase. 재시작 시 이 phase부터 재개 (`plan|execute|verify|cleanup`).

**Checkpoint 기반 재개 플로우:**
```bash
# 재시작 시 checkpoint 확인
python3 -c "
import json, os
f='.omc/state/jeo-state.json'
if os.path.exists(f):
    d=json.load(open(f))
    cp=d.get('checkpoint')
    err=d.get('last_error')
    rc=d.get('retry_count',0)
    print(f'재개 위치: {cp or \"처음부터\"}')
    if err: print(f'이전 오류 ({rc}회): {err}')
    if rc >= 3: print('⚠️ 재시도 3회 초과 — 사용자 확인 필요')
"
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

# 5단계: 완료 후 정리
bash scripts/worktree-cleanup.sh
```

---

## 7. Best Practices

1. **계획 먼저**: ralph+plannotator로 항상 계획 검토 후 실행 (잘못된 접근 조기 차단)
2. **team 우선**: Claude Code에서는 omc team 모드 사용이 가장 효율적
3. **bmad fallback**: team 없는 환경(Codex, Gemini)에서 BMAD 사용
4. **worktree 정리**: 작업 완료 즉시 `worktree-cleanup.sh` 실행 (브랜치 오염 방지)
5. **상태 저장**: `.omc/state/jeo-state.json`으로 세션 간 상태 유지
6. **annotate**: 복잡한 UI 수정이 필요할 때 `annotate` 키워드로 agentation watch loop 실행 (CSS selector 기반 정밀 코드 변경). `agentui`는 하위 호환 별칭.

---

## 8. Troubleshooting

| 문제 | 해결 |
|------|------|
| plannotator 미실행 | `bash .agent-skills/plannotator/scripts/check-status.sh` |
| plannotator 피드백 미수신 | `&` 백그라운드 실행 제거 → 블로킹 실행 후 `/tmp/plannotator_feedback.txt` 확인 |
| Codex 시작 실패 (`invalid type: map, expected a string`) | `bash scripts/setup-codex.sh` 재실행 후 `~/.codex/config.toml`의 `developer_instructions`가 top-level string인지 확인 |
| Gemini 피드백 루프 없음 | `~/.gemini/GEMINI.md`에 블로킹 직접 호출 지시 추가 |
| worktree 충돌 | `git worktree prune && git worktree list` |
| team 모드 미동작 | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 환경변수 설정 |
| omc 설치 실패 | `/omc:omc-doctor` 실행 |
| agent-browser 오류 | `agent-browser --version` 확인 |
| annotate(agentation) 안 열림 | `curl http://localhost:4747/pending` 확인 — agentation-mcp server 실행 여부 |
| annotation 코드에 반영 안됨 | `agentation_resolve_annotation` 호출 시 `summary` 필드 있는지 확인 |
| `agentui` 키워드로 활성화 안됨 | `annotate` 키워드(신규)를 사용하세요. `agentui`는 deprecated 별칭이지만 여전히 동작합니다. |
| MCP 툴 미등록 (Codex/Gemini) | `bash scripts/setup-codex.sh` / `setup-gemini.sh` 재실행 |

---

## 9. References

- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — Claude Code 멀티에이전트
- [plannotator](https://plannotator.ai) — 계획/diff 시각적 리뷰
- [BMAD Method](https://github.com/bmad-dev/BMAD-METHOD) — 구조화된 AI 개발 워크플로우
- [Agent Skills Spec](https://agentskills.io/specification) — 스킬 포맷 명세
- [agentation](https://github.com/benjitaylor/agentation) — UI 어노테이션 → 에이전트 코드 수정 연동 (`annotate`; `agentui` 하위 호환)
