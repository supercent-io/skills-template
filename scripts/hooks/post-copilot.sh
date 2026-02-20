#!/usr/bin/env bash
# hooks/post-copilot.sh — Copilot 할당 후 실행되는 post-copilot 훅 예시
#
# 인수: <issue-number>
# 반환: 0 = OK / 비제로 = 경고만 (계속 진행)
#
# 이 파일을 편집하여 Copilot 할당 후 알림/추적 등을 추가하세요.
set -euo pipefail

ISSUE_NUMBER="${1:-}"

echo "  [post-copilot] Copilot 할당 완료: 이슈 #$ISSUE_NUMBER"

# ─── 예시 1: 이슈에 댓글 추가 ────────────────────────────────────────────────
# if command -v gh &>/dev/null && [[ -n "$ISSUE_NUMBER" ]]; then
#   gh issue comment "$ISSUE_NUMBER" \
#     --body "🤖 Copilot Coding Agent에게 할당되었습니다. Draft PR을 기다려 주세요." \
#     2>/dev/null || true
# fi

# ─── 예시 2: 슬랙 알림 ────────────────────────────────────────────────────────
# SLACK_WEBHOOK="${SLACK_WEBHOOK_URL:-}"
# REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
# if [[ -n "$SLACK_WEBHOOK" ]]; then
#   curl -s -X POST "$SLACK_WEBHOOK" \
#     -H 'Content-type: application/json' \
#     -d "{\"text\":\"🤖 Copilot 할당: $REPO #$ISSUE_NUMBER\"}" > /dev/null
# fi

echo "  ✅ post-copilot 완료"
exit 0
