#!/usr/bin/env bash
# hooks/pre-conductor.sh — worktree 생성 전 실행되는 pre-conductor 훅 예시
#
# 인수: <feature-name> <base-branch> <agents>
# 반환: 0 = 계속 진행 / 비제로 = 파이프라인 중단
#
# 이 파일을 편집하여 프로젝트별 사전 조건을 추가하세요.
# 예: 브랜치 보호 확인, 이슈 번호 검증, 팀 슬랙 알림 등
set -euo pipefail

FEATURE_NAME="${1:-}"
BASE_BRANCH="${2:-main}"
AGENTS="${3:-}"

echo "  [pre-conductor] 피처: $FEATURE_NAME / 베이스: $BASE_BRANCH / 에이전트: $AGENTS"

# ─── 예시 1: feature name 길이 제한 ──────────────────────────────────────────
if [[ ${#FEATURE_NAME} -gt 50 ]]; then
  echo "  ❌ 피처 이름이 너무 깁니다 (최대 50자): ${#FEATURE_NAME}자"
  exit 1
fi

# ─── 예시 2: base branch가 main 또는 develop인지 확인 ────────────────────────
# if [[ "$BASE_BRANCH" != "main" && "$BASE_BRANCH" != "develop" ]]; then
#   echo "  ❌ 허용되지 않는 base branch: $BASE_BRANCH (main 또는 develop만 허용)"
#   exit 1
# fi

# ─── 예시 3: 원격 브랜치 최신 상태 확인 ─────────────────────────────────────
# git fetch origin "$BASE_BRANCH" --quiet 2>/dev/null || true

# ─── 예시 4: Jira/Linear 이슈 번호 패턴 검증 ─────────────────────────────────
# if ! echo "$FEATURE_NAME" | grep -qE '^[a-z]+-[0-9]+-'; then
#   echo "  ⚠️  피처 이름에 이슈 번호 없음 (권장: PROJ-123-description)"
# fi

echo "  ✅ pre-conductor 점검 통과"
exit 0
