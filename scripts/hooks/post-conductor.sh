#!/usr/bin/env bash
# hooks/post-conductor.sh — tmux 세션 시작 후 실행되는 post-conductor 훅 예시
#
# 인수: <feature-name> <session-name>
# 반환: 0 = OK / 비제로 = 경고만 (파이프라인은 계속)
#
# 이 파일을 편집하여 세션 시작 후 알림/로깅을 추가하세요.
set -euo pipefail

FEATURE_NAME="${1:-}"
SESSION="${2:-}"

echo "  [post-conductor] 세션 '$SESSION' 시작됨 (피처: $FEATURE_NAME)"

# ─── 예시 1: 슬랙 알림 ────────────────────────────────────────────────────────
# SLACK_WEBHOOK="${SLACK_WEBHOOK_URL:-}"
# if [[ -n "$SLACK_WEBHOOK" ]]; then
#   curl -s -X POST "$SLACK_WEBHOOK" \
#     -H 'Content-type: application/json' \
#     -d "{\"text\":\"🚀 Conductor 시작: \`$FEATURE_NAME\` — tmux 세션: \`$SESSION\`\"}" \
#     > /dev/null
#   echo "  📢 슬랙 알림 전송"
# fi

# ─── 예시 2: 로그 파일 기록 ──────────────────────────────────────────────────
# LOG_DIR="$(git rev-parse --show-toplevel 2>/dev/null)/.conductor-logs"
# mkdir -p "$LOG_DIR"
# echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) STARTED feature=$FEATURE_NAME session=$SESSION" \
#   >> "$LOG_DIR/conductor.log"

echo "  ✅ post-conductor 완료"
exit 0
