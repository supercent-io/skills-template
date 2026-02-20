---
name: vibe-kanban
keyword: kanbanview
description: AI 코딩 에이전트를 Kanban 보드에서 통합 관리. Conductor 패턴(git worktree 병렬 실행) 내장. 태스크 카드 → git worktree 자동 생성 → 에이전트 실행 → PR 생성까지 시각적으로 관리. planview 계획 검토와 통합 지원.
allowed-tools: [Read, Write, Bash]
tags: [vibe-kanban, kanbanview, kanban, ai-agents, worktree, pr-management, claude-code, codex, gemini, planview, task-management, conductor, parallel-agents]
platforms: [Claude, Codex, Gemini, OpenCode]
version: 1.0.0
source: BloopAI/vibe-kanban
---

# Vibe Kanban — AI 에이전트 통합 Kanban 보드 (kanbanview)

> Keyword: `kanbanview` | Includes: Conductor Pattern (parallel git worktree execution)
> Part of the **AI Review Tools** family: planno · kanbanview · copilotview

## When to use this skill

- 여러 AI 코딩 에이전트(Claude, Codex, Gemini)의 작업을 하나의 Kanban에서 시각적으로 관리하고 싶을 때
- 에픽을 여러 독립 태스크로 쪼개 에이전트에게 병렬로 배분하고 싶을 때
- To Do → In Progress → Review → Done 플로우로 AI 작업을 팀 GitHub PR 프로세스와 연결하고 싶을 때
- planview로 태스크 스펙을 검토하고 승인된 태스크만 에이전트에게 실행시키고 싶을 때
- diff/로그를 UI에서 확인하고 에이전트를 교체하거나 재시도하고 싶을 때

---

## 핵심 아키텍처

```
Vibe Kanban (로컬 서버)
  ├── 백엔드: Rust (SQLite DB — 워크플로 상태)
  ├── 프론트엔드: React/TypeScript (Kanban UI)
  └── Git 연동: git worktree (코드 상태)

Kanban 칼럼 플로우:
  [To Do] → [In Progress] → [Review] → [Done]
               ↓                ↓
         worktree 생성      diff 확인
         에이전트 실행       재시도/교체
         로그 스트리밍       PR 생성
```

---

## Step 1: 설치 및 실행

### 빠른 시작 (npx)

```bash
# 에이전트 CLI 인증 먼저 완료 (claude, codex, gemini 등)
npx vibe-kanban
# → 브라우저에서 Kanban UI 자동 오픈
```

### 개발 모드 (소스 클론)

```bash
git clone https://github.com/BloopAI/vibe-kanban.git
cd vibe-kanban
pnpm i
pnpm run dev  # Rust 백엔드 + React 프론트 동시 실행
```

### 빠른 설정 스크립트

```bash
bash scripts/vibe-kanban-start.sh
```

### 주요 환경 변수

| 변수 | 설명 |
|------|------|
| `PORT` | 서버 포트 (기본: 자동 할당) |
| `HOST` | 백엔드 주소 (기본: 127.0.0.1) |
| `VK_ALLOWED_ORIGINS` | 허용 오리진 (원격 접속 시 설정) |
| `GITHUB_CLIENT_ID` | GitHub OAuth (self-host 시) |
| `DISABLE_WORKTREE_ORPHAN_CLEANUP` | orphan worktree 자동 정리 끄기 (디버깅용) |

---

## Conductor Pattern (Built-in)

Vibe Kanban은 Conductor 패턴을 내부적으로 통합합니다. UI 없이 CLI만으로도 동일한 병렬 워크트리 실행이 가능합니다.

### UI 모드 (기본)

카드가 **In Progress**로 이동할 때마다 자동으로:

1. `git worktree add` 로 독립 샌드박스 생성
2. 지정된 에이전트(Claude/Codex/Gemini) 실행
3. 작업 완료 시 PR 자동 생성

여러 카드가 동시에 In Progress 상태이면 각 카드가 별도 worktree에서 병렬로 실행됩니다 — 이것이 Conductor 패턴의 핵심입니다.

### CLI 모드 (Kanban UI 없이)

Kanban UI 없이 순수 CLI로 Conductor 패턴을 실행하려면:

```bash
# 단일 파이프라인 실행 (체크 → Conductor → PR)
bash scripts/pipeline.sh <feature-name> --stages check,conductor,pr

# Conductor만 직접 실행 (worktree 병렬 에이전트)
bash scripts/conductor.sh <feature-name>
```

`scripts/conductor.sh` 는 태스크 목록을 읽어 각 태스크마다 git worktree를 생성하고 에이전트를 병렬로 실행합니다. `scripts/pipeline.sh` 는 사전 검사 → conductor → PR 생성 단계를 순서대로 연결합니다.

### UI vs CLI 선택 기준

| 상황 | 권장 모드 |
|------|----------|
| 팀 공유 보드, 시각적 진행 추적 필요 | UI 모드 (`npx vibe-kanban`) |
| CI/CD 파이프라인, 자동화 스크립트 | CLI 모드 (`scripts/pipeline.sh`) |
| 빠른 로컬 실험, UI 오버헤드 불필요 | CLI 모드 (`scripts/conductor.sh`) |
| diff/로그를 브라우저에서 검토 필요 | UI 모드 |

---

## Step 2: 프로젝트 및 태스크 생성

### 2-1. 프로젝트 생성

1. Vibe Kanban UI에서 **New Project** 클릭
2. GitHub repo URL 또는 로컬 repo 경로 선택
3. (옵션) GitHub OAuth로 브랜치/PR 생성 권한 연동

### 2-2. 에픽 → 태스크 분해 (planview 통합)

에픽을 독립 태스크로 쪼개기 전에 planview로 검토합니다:

```bash
# 에이전트에게 에픽 분해 계획 생성 요청
# Claude Code: Shift+Tab×2 → 계획 모드

# planview로 분해 계획 검토
plannotator review

# Approve 후 Vibe Kanban에서 태스크 생성
```

태스크 카드에 포함할 내용:
- 제목: 명확한 구현 단위 (예: "결제 UI 컴포넌트 구현")
- 설명: 입력/출력, 제약 조건, 완료 기준
- 우선순위: High / Medium / Low
- 담당 에이전트: Claude / Codex / Gemini 선택

---

## Step 3: In Progress → 에이전트 실행

카드를 **In Progress**로 드래그하면 자동 실행:

1. `vk/<hash>-<slug>` 형태의 브랜치 생성
2. 해당 브랜치용 git worktree 생성 (에이전트별 독립 샌드박스)
3. 선택한 에이전트 CLI 실행 + 로그 스트리밍

```
[To Do 카드: "결제 UI 구현"]
   ↓ In Progress로 드래그

Auto:
  git worktree add .vk/trees/vk-abc123-payment-ui -b vk/abc123-payment-ui main
  claude -p "결제 UI 구현: [태스크 설명]" --cwd .vk/trees/vk-abc123-payment-ui

UI: 로그 실시간 스트리밍
```

---

## Step 4: Review 칼럼에서 코드 검토

카드가 **Review** 상태가 되면:

1. **Diff 확인**: 브랜치 변경 사항을 UI에서 시각적 비교
2. **로그 확인**: 에이전트의 작업 과정과 "생각 과정" 확인
3. **재시도**: 결과가 만족스럽지 않으면 같은 에이전트로 재시도
4. **에이전트 교체**: 다른 에이전트(예: Claude → Codex)로 교체 후 재실행

### planview로 diff 검토

```bash
# 에이전트가 생성한 diff를 planview로 상세 검토
plannotator review --branch vk/abc123-payment-ui

# 어노테이션:
# - comment: 수정이 필요한 부분 명시
# - replace: 다른 접근법 제안
# → Request Changes → 에이전트 재실행
```

---

## Step 5: PR 생성 및 Done

검토 완료 후:

1. **Approve**: Vibe Kanban UI에서 PR 생성 버튼 클릭
2. GitHub에 PR 자동 생성 (브랜치명 기준)
3. PR merge 완료 → 태스크 카드 **Done**으로 자동 이동

---

## planview 통합 워크플로우 전체

```
[에픽 정의]
    ↓
[planview로 에픽 분해 계획 검토] ← Request Changes
    ↓ Approve
[Vibe Kanban 태스크 카드 생성]
    ↓
[In Progress → 에이전트 실행]
    ↓
[planview로 diff 검토] ← Request Changes → 에이전트 재실행
    ↓ Approve
[PR 생성] → [Done]
```

---

## 대표 사용 케이스

### 에픽 병렬 처리 예시

```
에픽: "결제 플로우 v2"
  ├── 카드1: 프론트엔드 UI    → Claude (설계/UI 중심)
  ├── 카드2: 백엔드 API       → Codex (타입/구현)
  └── 카드3: 통합 테스트      → Claude (테스트 전략)
```

### 역할별 전문 에이전트 배치

| 에이전트 | 최적 태스크 유형 |
|---------|--------------|
| Claude | 도메인 로직, 설계, 복잡한 비즈니스 규칙 |
| Codex | 타입 정의, 테스트, 보일러플레이트 |
| Gemini | 문서화, 스토리북, 코드 리뷰 |

---

## 참고 링크

- [GitHub: BloopAI/vibe-kanban](https://github.com/BloopAI/vibe-kanban)
- [공식 사이트: vibekanban.com](https://vibekanban.com)
- [VirtusLab 분석: vibe-kanban architecture](https://virtuslab.com/blog/ai/vibe-kanban/)
- [scripts/vibe-kanban-start.sh](../scripts/vibe-kanban-start.sh)
- [scripts/conductor.sh](../scripts/conductor.sh)
- [scripts/pipeline.sh](../scripts/pipeline.sh)
