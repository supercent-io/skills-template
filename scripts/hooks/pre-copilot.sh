#!/usr/bin/env bash
# hooks/pre-copilot.sh — Copilot 할당 전 실행되는 pre-copilot 훅 예시
#
# 인수: <issue-number>
# 반환: 0 = 계속 진행 / 비제로 = 할당 중단
#
# 이 파일을 편집하여 Copilot 할당 전 이슈 검증 등을 추가하세요.
set -euo pipefail

ISSUE_NUMBER="${1:-}"

echo "  [pre-copilot] Copilot 할당 전 점검: 이슈 #$ISSUE_NUMBER"

# ─── 예시 1: 이슈 번호 유효성 확인 ───────────────────────────────────────────
if [[ -z "$ISSUE_NUMBER" ]]; then
  echo "  ❌ 이슈 번호가 없습니다"
  exit 1
fi

if ! [[ "$ISSUE_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "  ❌ 유효하지 않은 이슈 번호: $ISSUE_NUMBER"
  exit 1
fi

# ─── 예시 2: 이슈가 열려 있는지 확인 ─────────────────────────────────────────
# if command -v gh &>/dev/null; then
#   STATE=$(gh issue view "$ISSUE_NUMBER" --json state -q .state 2>/dev/null || echo "")
#   if [[ "$STATE" != "OPEN" ]]; then
#     echo "  ❌ 이슈 #$ISSUE_NUMBER 가 열려 있지 않습니다 (상태: $STATE)"
#     exit 1
#   fi
# fi

# ─── 예시 3: planno 승인 여부 확인 (planno는 독립 선택 단계) ─────────────────
# APPROVAL_FILE="$(git rev-parse --show-toplevel)/.conductor-planno-approved"
# if [[ ! -f "$APPROVAL_FILE" ]]; then
#   echo "  ❌ planno 승인이 없습니다. conductor-planno.sh를 먼저 실행하세요."
#   exit 1
# fi

echo "  ✅ pre-copilot 점검 통과"
exit 0
