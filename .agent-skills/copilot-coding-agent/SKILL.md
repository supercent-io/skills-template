---
name: copilot-coding-agent
keyword: copilotview
description: GitHub Copilot Coding Agent를 통한 Issue → Draft PR 자동화. GitHub Actions와 GraphQL API를 연계해 라벨 기반으로 이슈를 Copilot에 자동 할당하고 PR을 생성. planno(plannotator)로 이슈 스펙 독립 검토 지원 (선택적).
allowed-tools: [Read, Write, Bash]
tags: [copilotview, github-copilot, github-actions, issue-automation, draft-pr, graphql, planno, workflow-automation]
platforms: [Claude, Codex, Gemini, OpenCode]
version: 1.0.0
source: docs.github.com/copilot/coding-agent
---

# GitHub Copilot Coding Agent — Issue → Draft PR 자동화

> Keyword: `copilotview` | Part of the **AI Review Tools** family: planno · kanbanview · copilotview

## When to use this skill

- GitHub Issue를 작성하면 Copilot이 자동으로 PR을 생성하게 하고 싶을 때
- `ai-copilot` 라벨 하나로 Copilot 에이전트 작업을 트리거하고 싶을 때
- 리팩터링, 문서화, 테스트 추가 등 백로그 작업을 Copilot에게 위임하고 싶을 때
- planno로 이슈 스펙을 독립적으로 검토·승인한 뒤 Copilot이 구현하도록 자동화하고 싶을 때
- Conductor / Vibe Kanban 패턴과 결합해 "잔업 → Copilot 위임" 파이프라인을 구축하고 싶을 때

---

## 핵심 개념

1. **Copilot은 Issue의 assignee가 되어 작동합니다**
   - Issue 오른쪽 패널에서 Copilot을 assignee로 지정 (UI 방식)
   - 또는 GraphQL API로 자동 assign (Actions 방식)

2. **Copilot이 만드는 PR은 외부 기여자처럼 취급됩니다**
   - Draft PR로 생성됨
   - Actions 워크플로는 사람이 "신뢰" 승인 후 실행
   - Write 권한 있는 사람만 Copilot에게 이슈 할당 가능

3. **필요 플랜**: Copilot Pro, Pro+, Business, Enterprise

---

## Step 1: 사전 준비

```bash
# 1. GitHub Personal Access Token 생성
# → GitHub Settings > Developer settings > Personal access tokens
# → Scopes: repo (full), read:org (필요 시)

# 2. 레포 시크릿에 등록
gh secret set COPILOT_ASSIGN_TOKEN --body "<YOUR_TOKEN>"

# 3. Copilot coding agent 활성화 확인
# → GitHub Settings > Copilot > Coding agent 활성화

# 4. 설정 스크립트 실행
bash scripts/copilot-setup-workflow.sh
```

---

## Step 2: planno로 이슈 스펙 검토 (선택적 독립 단계)

Copilot에게 이슈를 할당하기 전에 planno(plannotator)로 스펙을 독립적으로 검토할 수 있습니다:

```bash
# 에이전트가 이슈 상세 스펙 초안 작성 (Claude Code)
# → planno로 이슈 내용 검토 (선택적)

plannotator review  # 이슈 스펙 어노테이션

# Approve 후 이슈 생성 및 라벨 부착
gh issue create \
  --title "feat: 결제 UI 리팩터링" \
  --body "$(cat issue-spec.md)" \
  --label "ai-copilot"
```

planno 어노테이션 활용:
- `comment`: Copilot이 참고할 구체적 지시사항 추가
- `insert`: 누락된 acceptance criteria 삽입
- `replace`: 모호한 스펙을 명확한 지시로 교체

---

## Step 3: GitHub Actions 워크플로 설정

`.github/workflows/assign-to-copilot.yml` 파일을 배포합니다:

```bash
# 워크플로 파일 복사
cp .github/workflows/assign-to-copilot.yml .github/workflows/

# 커밋 & 푸시
git add .github/workflows/assign-to-copilot.yml
git commit -m "ci: add Copilot auto-assign workflow"
git push
```

### 워크플로 동작 방식

```
이슈에 'ai-copilot' 라벨 부착
         ↓
GitHub Actions 트리거 (issues: opened/labeled)
         ↓
GraphQL: Copilot bot ID 조회
         ↓
GraphQL: replaceActorsForAssignable → Copilot을 assignee로 설정
         ↓
Copilot Coding Agent 활성화
         ↓
브랜치 생성 → 코드 수정 → Draft PR 생성
         ↓
사람이 PR 리뷰 → 승인 → CI 실행 → Merge
```

---

## Step 4: 이슈 라벨링으로 트리거

```bash
# 새 이슈 생성과 동시에 라벨 부착
gh issue create \
  --title "refactor: auth 모듈 JWT 마이그레이션" \
  --body "상세 설명..." \
  --label "ai-copilot"

# 기존 이슈에 라벨 추가
gh issue edit <issue-number> --add-label "ai-copilot"
```

---

## Step 5: Copilot PR 검토 및 승인

Copilot이 Draft PR을 생성하면:

1. **PR 확인**: `gh pr list --search "copilot"`
2. **첫 번째 승인**: Copilot PR은 처음에 Actions 실행이 보류됨
   ```bash
   gh pr review <pr-number> --approve  # 또는 UI에서 "Approve and run"
   ```
3. **CI 실행**: 승인 후 `.github/workflows/copilot-pr-ci.yml` 실행
4. **Merge**: CI 통과 후 merge

### planno로 Copilot PR diff 검토 (선택적)

```bash
# Copilot이 생성한 변경사항을 planno(plannotator)로 검토
gh pr checkout <pr-number>
plannotator review  # diff 어노테이션

# Request Changes → Copilot PR 코멘트로 피드백
gh pr review <pr-number> --request-changes --body "$(cat feedback.md)"
# → Copilot이 코멘트를 읽고 추가 수정
```

---

## 수동 Copilot 할당 (GraphQL)

```bash
# 스크립트 실행
bash scripts/copilot-assign-issue.sh <issue-number>

# 또는 직접 실행
ISSUE_NODE_ID=$(gh api repos/:owner/:repo/issues/<number> --jq '.node_id')
bash scripts/copilot-graphql-assign.sh "$ISSUE_NODE_ID"
```

---

## planno + Copilot 전체 워크플로우 (선택적 독립 구성)

```
[이슈 초안 작성 (에이전트)]
    ↓
[planno로 이슈 스펙 검토] ← Request Changes → 재작성  ← 선택적 독립 단계
    ↓ Approve (또는 건너뜀)
[gh issue create --label ai-copilot]
    ↓
[GitHub Actions → Copilot 자동 할당]
    ↓
[Copilot: 브랜치 생성 → 코드 작성 → Draft PR]
    ↓
[planno로 PR diff 검토] ← Request Changes → Copilot 재작업  ← 선택적 독립 단계
    ↓ Approve (또는 건너뜀)
[Actions 실행 승인 → CI 통과 → Merge]
```

---

## 대표 사용 케이스

| 시나리오 | 트리거 방법 | 효과 |
|---------|-----------|------|
| 백로그 자동 처리 | `ai-copilot` 라벨 | Copilot이 PR 자동 생성 |
| Jira 연동 | 외부 이슈 → GitHub Issue → 라벨 | 완전 자동화 파이프라인 |
| Conductor + Copilot | Conductor 결과 후속 이슈 | 리팩터링/테스트 자동 위임 |
| PM 주도 개발 | PM이 이슈 작성 + 라벨 | 에이전트가 PR 자동 생성 |

---

## 제약 사항

- Copilot은 단일 레포에서만 작동 (멀티 레포 이슈 불가)
- 한 이슈당 하나의 PR만 생성
- 특정 브랜치 보호 규칙 우회 불가
- GitHub.com 호스팅 레포만 지원
- 첫 PR은 Actions 실행 전 수동 승인 필요

---

## 참고 링크

- [GitHub Copilot coding agent 개요](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-coding-agent)
- [Ask Copilot to create a PR (GraphQL 예제)](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-a-pr)
- [.github/workflows/assign-to-copilot.yml](../../.github/workflows/assign-to-copilot.yml)
- [scripts/copilot-assign-issue.sh](../scripts/copilot-assign-issue.sh)
