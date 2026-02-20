#!/usr/bin/env bash
# copilot-setup-workflow.sh — Copilot Coding Agent GitHub Actions 워크플로 설정
# 사용법: bash scripts/copilot-setup-workflow.sh
#
# 동작:
#   1. COPILOT_ASSIGN_TOKEN 시크릿 설정 안내
#   2. GitHub Actions 워크플로 파일 배포
#   3. ai-copilot 라벨 생성
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORKFLOW_SRC="$SCRIPT_DIR/../.github/workflows/assign-to-copilot.yml"
WORKFLOW_DST="$ROOT_DIR/.github/workflows/assign-to-copilot.yml"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Copilot Coding Agent 설정"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── 전제 조건 확인 ───────────────────────────────────────────────────────────
if ! command -v gh &>/dev/null; then
  echo "❌ gh CLI가 설치되어 있지 않습니다. https://cli.github.com/"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "❌ gh CLI 인증이 필요합니다. 'gh auth login' 실행 후 다시 시도하세요."
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
  echo "❌ GitHub 레포와 연결된 디렉토리에서 실행하세요."
  exit 1
fi
echo "  레포: $REPO"
echo ""

# ─── Step 1: PAT 시크릿 설정 ─────────────────────────────────────────────────
echo "1️⃣  COPILOT_ASSIGN_TOKEN 시크릿 설정"
echo ""
echo "   GitHub Personal Access Token이 필요합니다:"
echo "   1. https://github.com/settings/tokens 접속"
echo "   2. 'Generate new token (classic)' 클릭"
echo "   3. Scopes: 'repo' 체크"
echo "   4. 토큰 복사"
echo ""

if [[ -n "${COPILOT_ASSIGN_TOKEN:-}" ]]; then
  echo "   COPILOT_ASSIGN_TOKEN 환경 변수에서 토큰을 감지했습니다."
  read -r -p "   이 토큰을 레포 시크릿으로 설정하시겠습니까? [y/N] " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    gh secret set COPILOT_ASSIGN_TOKEN --body "$COPILOT_ASSIGN_TOKEN"
    echo "   ✅ 시크릿 설정 완료"
  fi
else
  read -r -s -p "   PAT를 입력하세요 (입력 내용 숨김): " PAT
  echo ""
  if [[ -n "$PAT" ]]; then
    gh secret set COPILOT_ASSIGN_TOKEN --body "$PAT"
    echo "   ✅ 시크릿 설정 완료"
  else
    echo "   ⚠️  시크릿 설정을 건너뜁니다. 나중에 직접 설정하세요:"
    echo "      gh secret set COPILOT_ASSIGN_TOKEN --body <YOUR_TOKEN>"
  fi
fi

# ─── Step 2: 워크플로 파일 배포 ───────────────────────────────────────────────
echo ""
echo "2️⃣  GitHub Actions 워크플로 파일 배포"
mkdir -p "$ROOT_DIR/.github/workflows"

if [[ -f "$WORKFLOW_SRC" ]]; then
  cp "$WORKFLOW_SRC" "$WORKFLOW_DST"
  echo "   ✅ 워크플로 배포: $WORKFLOW_DST"
else
  echo "   ⚠️  워크플로 소스 파일을 찾을 수 없습니다: $WORKFLOW_SRC"
  echo "   .github/workflows/assign-to-copilot.yml 파일을 수동으로 배포하세요."
fi

# ─── Step 3: ai-copilot 라벨 생성 ────────────────────────────────────────────
echo ""
echo "3️⃣  'ai-copilot' 라벨 생성"
if gh label create "ai-copilot" \
    --color "0075ca" \
    --description "Copilot Coding Agent가 처리할 이슈" \
    2>/dev/null; then
  echo "   ✅ 라벨 생성 완료"
else
  echo "   ℹ️  라벨이 이미 존재합니다."
fi

# ─── 완료 안내 ────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ 설정 완료!"
echo ""
echo "  사용법:"
echo "  1. planno로 이슈 스펙 검토 후 승인 (선택적 독립 단계)"
echo "  2. 이슈에 'ai-copilot' 라벨 부착:"
echo "     gh issue create --label ai-copilot --title '...' --body '...'"
echo "  3. GitHub Actions가 Copilot에 자동 할당"
echo "  4. Copilot이 Draft PR 생성 → 검토 → Merge"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
