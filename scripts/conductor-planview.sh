#!/usr/bin/env bash
# conductor-planview.sh — planview 검토 후 Conductor 자동 실행
# 사용법: bash scripts/conductor-planview.sh <feature-name> [base-branch] [agents]
#
# 동작 순서:
#   1. plannotator가 설치되어 있으면 planview 검토 실행
#   2. 사용자 승인(Approve) 확인
#   3. conductor.sh 실행
set -euo pipefail

FEATURE_NAME="${1:-}"
BASE_BRANCH="${2:-main}"
AGENTS_ARG="${3:-claude,codex}"

if [[ -z "$FEATURE_NAME" ]]; then
  echo "사용법: $0 <feature-name> [base-branch] [agents]"
  echo "  예시: $0 user-dashboard main claude,codex"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Conductor + planview 통합 워크플로우"
echo "  Feature : $FEATURE_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Step 1: planview 검토 (plannotator가 설치된 경우) ───────────────────────
if command -v plannotator &>/dev/null; then
  echo ""
  echo "📋 planview 계획 검토를 시작합니다..."
  echo "   에이전트가 생성한 구현 계획을 검토하고 Approve 또는 Request Changes를 선택하세요."
  echo ""

  # plannotator review 실행
  if plannotator review; then
    echo ""
    echo "✅ 계획이 승인되었습니다. Conductor를 실행합니다..."
  else
    REVIEW_EXIT=$?
    echo ""
    echo "❌ 계획이 반려되었거나 검토가 취소되었습니다. (exit code: $REVIEW_EXIT)"
    echo "   에이전트에게 피드백을 전달하고 계획을 수정한 후 다시 실행하세요."
    exit 1
  fi
else
  echo ""
  echo "ℹ️  plannotator가 설치되어 있지 않습니다. 검토 단계를 건너뜁니다."
  echo "   plannotator 설치: curl -fsSL https://plannotator.ai/install.sh | bash"
  echo ""

  # 수동 확인
  read -r -p "   계획이 검토/승인되었습니까? Conductor를 실행하시겠습니까? [y/N] " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "   취소되었습니다."
    exit 0
  fi
fi

# ─── Step 2: Conductor 실행 ──────────────────────────────────────────────────
echo ""
echo "🚀 Conductor 실행 중..."
bash "$SCRIPT_DIR/conductor.sh" "$FEATURE_NAME" "$BASE_BRANCH" "$AGENTS_ARG"
