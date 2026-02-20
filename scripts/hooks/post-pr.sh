#!/usr/bin/env bash
# hooks/post-pr.sh — PR 생성 후 실행되는 post-pr 훅 예시
#
# 인수: <feature-name> <agent-suffix> <pr-url>
# 반환: 0 = OK / 비제로 = 경고만 (계속 진행)
#
# 이 파일을 편집하여 PR 생성 후 알림/라벨/리뷰어 추가 등을 설정하세요.
set -euo pipefail

FEATURE_NAME="${1:-}"
AGENT_SUFFIX="${2:-}"
PR_URL="${3:-}"

echo "  [post-pr] PR 생성됨: [$AGENT_SUFFIX] $PR_URL"

# ─── 예시 1: 리뷰어 자동 추가 ────────────────────────────────────────────────
# REVIEWERS="${CONDUCTOR_REVIEWERS:-}"
# if [[ -n "$REVIEWERS" && -n "$PR_URL" ]]; then
#   PR_NUMBER=$(echo "$PR_URL" | grep -o '[0-9]*$')
#   gh pr edit "$PR_NUMBER" --add-reviewer "$REVIEWERS" 2>/dev/null || true
#   echo "  👥 리뷰어 추가: $REVIEWERS"
# fi

# ─── 예시 2: PR에 라벨 추가 ───────────────────────────────────────────────────
# if [[ -n "$PR_URL" ]]; then
#   PR_NUMBER=$(echo "$PR_URL" | grep -o '[0-9]*$')
#   gh pr edit "$PR_NUMBER" --add-label "conductor,ai-generated" 2>/dev/null || true
# fi

# ─── 예시 3: 슬랙 알림 ────────────────────────────────────────────────────────
# SLACK_WEBHOOK="${SLACK_WEBHOOK_URL:-}"
# if [[ -n "$SLACK_WEBHOOK" && -n "$PR_URL" ]]; then
#   curl -s -X POST "$SLACK_WEBHOOK" \
#     -H 'Content-type: application/json' \
#     -d "{\"text\":\"🔗 PR 생성됨 [$AGENT_SUFFIX]: $PR_URL\"}" > /dev/null
# fi

echo "  ✅ post-pr 완료"
exit 0
