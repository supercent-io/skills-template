---
name: conductor-pattern
description: git worktree로 AI 에이전트(Claude, Codex, Gemini)를 병렬 실행하는 Conductor 패턴. 충돌 없이 동일 스펙을 여러 에이전트가 동시 구현하고 PR로 비교. planview 계획 검토 후 자동 실행 지원.
allowed-tools: [Read, Write, Bash, Glob, Grep]
tags: [conductor, git-worktree, parallel-agents, claude-code, codex, tmux, pr-comparison, planview, multi-agent]
platforms: [Claude, Codex, Gemini, OpenCode]
version: 1.0.0
source: claude-code-docs/worktrees, dev.to/qlerebours_
---

# Conductor 패턴 — 병렬 AI 에이전트 + git worktree

## When to use this skill

- 동일 스펙을 Claude / Codex / Gemini 등 여러 AI가 동시에 구현하고 결과를 비교하고 싶을 때
- 난이도 높은 리팩터링에서 리스크를 분산하고 싶을 때 (한 에이전트 실패 시 다른 에이전트 성공 확률 유지)
- 역할을 분리해 병렬 작업하고 싶을 때 (Claude: 도메인 로직, Codex: 테스트/타입, Gemini: 문서)
- planview로 계획 승인 후 자동으로 병렬 에이전트를 실행하고 싶을 때
- 여러 에이전트의 구현을 PR로 비교한 뒤 최적 조합으로 merge하고 싶을 때

---

## 핵심 아키텍처

```
repo-root/
  .git/                    # 공유 git 히스토리
  src/ ...
  trees/                   # 에이전트별 worktree (충돌 없음)
    feat-x-claude/         # Claude 전용 샌드박스
    feat-x-codex/          # Codex 전용 샌드박스
    feat-x-gemini/         # Gemini 전용 샌드박스 (선택)
  scripts/
    conductor.sh           # 메인 오케스트레이터
    conductor-pr.sh        # PR 자동 생성
    conductor-planview.sh  # planview + conductor 통합
```

---

## Step 1: planview로 계획 검토 (권장)

Conductor를 실행하기 전에 planview로 구현 계획을 검토하고 승인합니다.

```bash
# 1-1. 에이전트에게 구현 계획 생성 요청
# Claude Code: Shift+Tab×2 (계획 모드 진입)
# → 에이전트가 구현 계획 생성

# 1-2. planview로 계획 검토
plannotator review

# 1-3. 검토 후 결정
# - Approve: conductor.sh 실행으로 진행
# - Request changes: 에이전트가 계획 수정 후 재검토
```

planview + Conductor 통합 스크립트:
```bash
bash scripts/conductor-planview.sh <feature-name> [base-branch]
```

---

## Step 2: Conductor 스크립트 실행

```bash
# 기본 실행 (Claude + Codex 병렬)
bash scripts/conductor.sh user-dashboard main

# 3개 에이전트 병렬 실행
bash scripts/conductor.sh user-dashboard main claude,codex,gemini
```

### conductor.sh 동작 순서

1. `trees/feat-<name>-<agent>` 디렉토리에 worktree 생성
2. 각 worktree에 기본 브랜치에서 분기한 독립 브랜치 생성
3. `.env` 등 공통 설정 파일 복사 (있는 경우)
4. tmux 세션에서 각 에이전트 동시 실행
5. 에이전트 완료 후 PR 생성 안내

### worktree 수동 생성

```bash
# Claude용 worktree + 브랜치
git worktree add trees/feat-dashboard-claude -b feat/dashboard-claude main

# Codex용 worktree + 브랜치
git worktree add trees/feat-dashboard-codex  -b feat/dashboard-codex  main

# 공통 설정 복사
for dir in trees/feat-dashboard-*; do
  [ -f .env ] && cp .env "$dir/.env"
done
```

---

## Step 3: 에이전트 작업

각 tmux pane에서 독립적으로 작업:

```bash
# Claude 세션 (trees/feat-dashboard-claude/)
claude  # Claude Code CLI 실행
# → /init  (CLAUDE.md 생성, 프로젝트 분석)
# → 스펙 붙여넣고 구현 시작

# Codex 세션 (trees/feat-dashboard-codex/)
codex   # Codex CLI 실행
# → 동일 스펙으로 구현 시작
```

---

## Step 4: 커밋 및 PR 생성

```bash
# 각 에이전트 worktree에서 커밋
cd trees/feat-dashboard-claude
git add . && git commit -m "feat: dashboard (Claude version)"

# PR 자동 생성
bash scripts/conductor-pr.sh feat-dashboard
```

또는 수동으로:

```bash
gh pr create -B main -H feat/dashboard-claude \
  -t "feat: dashboard (Claude)" \
  -b "Claude 에이전트 구현 버전"

gh pr create -B main -H feat/dashboard-codex \
  -t "feat: dashboard (Codex)" \
  -b "Codex 에이전트 구현 버전"
```

---

## Step 5: 결과 비교 및 병합

```bash
# 두 PR 나란히 비교
gh pr list --search "feat: dashboard"

# 최적 조합으로 merge 브랜치 생성
git checkout -b feat/dashboard-best main
git cherry-pick <claude-commit-hash>   # UI 구조
git cherry-pick <codex-commit-hash>    # 타입/테스트
gh pr create -B main -H feat/dashboard-best -t "feat: dashboard (best-of-both)"
```

---

## planview 통합 상세

### 계획 검토 → 에이전트 실행 루프

```
[계획 생성] → [planview 검토] → [Approve] → [conductor.sh 실행]
                      ↓ Request Changes
                [에이전트 재계획] → [planview 재검토]
```

### planview 어노테이션 활용

planview에서 계획 어노테이션 시:
- `delete`: 불필요한 구현 단계 제거
- `insert`: 빠진 스텝 추가 (예: 에러 처리, 테스트)
- `replace`: 에이전트별 역할 분담 재조정
- `comment`: 각 에이전트에 대한 구체적 제약 조건 명시

### 어노테이션 → conductor 실행 예시

```bash
# planview 검토 완료 후, 승인된 계획으로 conductor 실행
# conductor-planview.sh 는 plannotator 승인 상태를 확인 후 실행
bash scripts/conductor-planview.sh dashboard main
```

---

## 대표 사용 케이스

| 시나리오 | 에이전트 배치 | 병합 전략 |
|---------|------------|--------|
| UI 리디자인 | Claude(UI 구조) + Codex(스타일링) | UI: Claude, 스타일: Codex |
| API 개발 | Claude(비즈니스 로직) + Codex(타입/테스트) | 로직: Claude, 테스트: Codex |
| 대규모 리팩터링 | Claude + Codex (리스크 헷징) | 성공한 버전 선택 |
| 문서화 | Gemini(문서) + Claude(코드 예시) | 문서: Gemini, 예시: Claude |

---

## 정리 / 마무리

```bash
# 작업 완료 후 worktree 정리
git worktree list
git worktree remove trees/feat-dashboard-claude
git worktree remove trees/feat-dashboard-codex

# 병합된 브랜치 삭제
git branch -d feat/dashboard-claude feat/dashboard-codex
```

---

## 참고 링크

- [Claude Code 공식: Run parallel sessions with Git worktrees](https://code.claude.com/docs/en/common-workflows)
- [dev.to: Leverage git worktree with Codex, Claude Code, etc.](https://dev.to/qlerebours_/leverage-git-worktree-to-parallelize-work-with-codex-claude-code-etc-1np1)
- [parallel-ai-coding-with-gitworktrees](https://docs.agentinterviews.com/blog/parallel-ai-coding-with-gitworktrees/)
- [scripts/conductor.sh](../scripts/conductor.sh)
- [scripts/conductor-planview.sh](../scripts/conductor-planview.sh)
