#!/usr/bin/env bash
# hooks/pre-pr.sh — PR 생성 전 실행되는 pre-pr 훅 예시
#
# 인수: <feature-name> <base-branch>
# 반환: 0 = 계속 진행 / 비제로 = PR 생성 중단
#
# 이 파일을 편집하여 PR 생성 전 테스트/린트/검증을 추가하세요.
set -euo pipefail

FEATURE_NAME="${1:-}"
BASE_BRANCH="${2:-main}"

echo "  [pre-pr] PR 생성 전 점검: $FEATURE_NAME → $BASE_BRANCH"

# ─── 예시 1: 각 worktree에서 테스트 실행 ─────────────────────────────────────
# ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
# TREES_DIR="$ROOT_DIR/trees"
#
# for TREE_PATH in "$TREES_DIR"/feat-"$FEATURE_NAME"-*; do
#   [[ -d "$TREE_PATH" ]] || continue
#   AGENT_SUFFIX="${TREE_PATH##*feat-$FEATURE_NAME-}"
#   echo "  🧪 [$AGENT_SUFFIX] 테스트 실행 중..."
#   if [[ -f "$TREE_PATH/package.json" ]]; then
#     ( cd "$TREE_PATH" && npm test --silent 2>/dev/null ) || {
#       echo "  ❌ [$AGENT_SUFFIX] 테스트 실패"
#       exit 1
#     }
#   fi
# done

# ─── 예시 2: PR 제목/본문 커스터마이징을 위한 메타 파일 생성 ─────────────────
# echo "$FEATURE_NAME" > /tmp/conductor-pr-feature.txt

echo "  ✅ pre-pr 점검 통과"
exit 0
