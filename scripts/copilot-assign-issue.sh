#!/usr/bin/env bash
# copilot-assign-issue.sh — GitHub Issue를 Copilot Coding Agent에 할당
# 사용법: bash scripts/copilot-assign-issue.sh <issue-number>
#
# 전제 조건:
#   - gh CLI 설치 및 인증 (gh auth login)
#   - COPILOT_ASSIGN_TOKEN 환경 변수 또는 시크릿 설정
#     (repo scope가 있는 Personal Access Token)
#   - Copilot Coding Agent 활성화된 플랜 (Pro+, Business, Enterprise)
set -euo pipefail

ISSUE_NUMBER="${1:-}"
if [[ -z "$ISSUE_NUMBER" ]]; then
  echo "사용법: $0 <issue-number>"
  echo "  예시: $0 42"
  exit 1
fi

# ─── 환경 변수 / 토큰 확인 ───────────────────────────────────────────────────
GH_TOKEN="${COPILOT_ASSIGN_TOKEN:-${GH_TOKEN:-}}"
if [[ -z "$GH_TOKEN" ]]; then
  echo "❌ COPILOT_ASSIGN_TOKEN 또는 GH_TOKEN 환경 변수가 설정되어 있지 않습니다."
  echo "   export COPILOT_ASSIGN_TOKEN=<your-pat-with-repo-scope>"
  exit 1
fi

# ─── 레포 정보 추출 ───────────────────────────────────────────────────────────
if ! command -v gh &>/dev/null; then
  echo "❌ gh CLI가 설치되어 있지 않습니다. https://cli.github.com/"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
  echo "❌ 현재 디렉토리가 GitHub 레포와 연결되어 있지 않습니다."
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Copilot Issue 할당"
echo "  레포  : $REPO"
echo "  이슈  : #$ISSUE_NUMBER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Issue node_id 가져오기 ────────────────────────────────────────────────────
echo ""
echo "1️⃣  Issue node_id 조회 중..."
ISSUE_NODE_ID=$(gh api "repos/$REPO/issues/$ISSUE_NUMBER" --jq '.node_id')
if [[ -z "$ISSUE_NODE_ID" ]]; then
  echo "❌ 이슈 #$ISSUE_NUMBER를 찾을 수 없습니다."
  exit 1
fi
echo "   node_id: $ISSUE_NODE_ID"

# ─── Copilot bot ID 조회 ──────────────────────────────────────────────────────
echo ""
echo "2️⃣  Copilot bot ID 조회 중..."
COPILOT_BOT_ID=$(curl -s -X POST https://api.github.com/graphql \
  -H "Authorization: bearer $GH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "GraphQL-Features: issues_copilot_assignment_api_support,coding_agent_model_selection" \
  -d '{"query":"query { user(login: \"copilot\") { id } }"}' \
  | jq -r '.data.user.id // empty')

if [[ -z "$COPILOT_BOT_ID" ]]; then
  echo "❌ Copilot bot ID 조회 실패."
  echo "   - Copilot Coding Agent가 활성화된 플랜인지 확인하세요 (Pro+, Business, Enterprise)"
  echo "   - COPILOT_ASSIGN_TOKEN 권한(repo scope)을 확인하세요"
  exit 1
fi
echo "   Copilot bot ID: $COPILOT_BOT_ID"

# ─── replaceActorsForAssignable 뮤테이션으로 할당 ─────────────────────────────
echo ""
echo "3️⃣  Copilot을 이슈 assignee로 설정 중..."
ASSIGN_RESULT=$(curl -s -X POST https://api.github.com/graphql \
  -H "Authorization: bearer $GH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "GraphQL-Features: issues_copilot_assignment_api_support,coding_agent_model_selection" \
  -d "$(jq -n \
    --arg issueId "$ISSUE_NODE_ID" \
    --arg botId "$COPILOT_BOT_ID" \
    '{
      query: "mutation AssignIssue($issueId: ID!, $botId: ID!) { replaceActorsForAssignable(input: { assignableId: $issueId, actorIds: [$botId] }) { assignable { ... on Issue { id title assignees(first: 5) { nodes { login } } } } } }",
      variables: { issueId: $issueId, botId: $botId }
    }')")

# 결과 확인
ASSIGNED_LOGINS=$(echo "$ASSIGN_RESULT" | jq -r '.data.replaceActorsForAssignable.assignable.assignees.nodes[].login // empty' 2>/dev/null || echo "")
ERRORS=$(echo "$ASSIGN_RESULT" | jq -r '.errors[]?.message // empty' 2>/dev/null || echo "")

if [[ -n "$ERRORS" ]]; then
  echo "❌ 할당 실패: $ERRORS"
  echo "   전체 응답: $ASSIGN_RESULT"
  exit 1
fi

if echo "$ASSIGNED_LOGINS" | grep -qi "copilot"; then
  echo ""
  echo "✅ 이슈 #$ISSUE_NUMBER이 Copilot에 성공적으로 할당되었습니다!"
  echo ""
  echo "  Copilot이 이슈를 처리하고 Draft PR을 생성합니다."
  echo "  PR 확인: gh pr list --search 'head:copilot/'"
  echo "  이슈 확인: gh issue view $ISSUE_NUMBER"
else
  echo "⚠️  할당은 완료되었으나 Copilot 로그인을 확인하지 못했습니다."
  echo "   이슈 페이지에서 직접 확인하세요: gh issue view $ISSUE_NUMBER"
  echo "   응답: $ASSIGN_RESULT"
fi
