#!/usr/bin/env bash
# pipeline-check.sh — Conductor 파이프라인 사전 점검
# 사용법: bash scripts/pipeline-check.sh [--agents claude,codex,gemini]
#
# 필수 도구와 설정이 갖춰졌는지 확인합니다.
# 모든 점검 통과 시 exit 0, 실패 시 exit 1
set -euo pipefail

AGENTS_ARG="${1:-claude,codex}"
if [[ "$AGENTS_ARG" == --agents=* ]]; then
  AGENTS_ARG="${AGENTS_ARG#--agents=}"
elif [[ "$AGENTS_ARG" == --agents ]]; then
  AGENTS_ARG="${2:-claude,codex}"
fi

IFS=',' read -ra AGENTS <<< "$AGENTS_ARG"

PASS=0
FAIL=0
WARN=0

check_pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
check_fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check_warn() { echo "  ⚠️  $1"; WARN=$((WARN + 1)); }

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Conductor 파이프라인 사전 점검"
echo "  에이전트: ${AGENTS[*]}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─── 필수 시스템 도구 ────────────────────────────────────────────────────────
echo "[ 시스템 도구 ]"

if command -v git &>/dev/null; then
  GIT_VER=$(git --version | awk '{print $3}')
  check_pass "git $GIT_VER"
else
  check_fail "git (필수)"
fi

if command -v tmux &>/dev/null; then
  TMUX_VER=$(tmux -V | awk '{print $2}')
  check_pass "tmux $TMUX_VER"
else
  check_fail "tmux (필수) — macOS: brew install tmux / Linux: apt install tmux"
fi

if command -v gh &>/dev/null; then
  GH_VER=$(gh --version | head -1 | awk '{print $3}')
  check_pass "gh $GH_VER"
else
  check_warn "gh CLI (PR 생성에 필요) — https://cli.github.com/"
fi

if command -v jq &>/dev/null; then
  JQ_VER=$(jq --version)
  check_pass "jq $JQ_VER"
else
  check_fail "jq (필수) — macOS: brew install jq / Linux: apt install jq"
fi

if command -v curl &>/dev/null; then
  check_pass "curl"
else
  check_fail "curl (필수)"
fi

echo ""

# ─── Git 레포지토리 ──────────────────────────────────────────────────────────
echo "[ Git 설정 ]"

if git rev-parse --git-dir > /dev/null 2>&1; then
  ROOT_DIR="$(git rev-parse --show-toplevel)"
  check_pass "Git 레포: $ROOT_DIR"
else
  check_fail "Git 레포지토리가 아닙니다"
  ROOT_DIR="$(pwd)"
fi

if git worktree list &>/dev/null; then
  check_pass "git worktree 지원"
else
  check_warn "git worktree를 지원하지 않는 버전일 수 있습니다"
fi

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
check_pass "현재 브랜치: $CURRENT_BRANCH"

# 미커밋 변경사항 경고
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
  check_warn "미커밋 변경사항 있음 — worktree 생성 전 커밋 권장"
fi

echo ""

# ─── GitHub 인증 ─────────────────────────────────────────────────────────────
echo "[ GitHub 인증 ]"

if command -v gh &>/dev/null; then
  if gh auth status &>/dev/null 2>&1; then
    GH_USER=$(gh api user --jq .login 2>/dev/null || echo "unknown")
    check_pass "gh 인증 완료 (사용자: $GH_USER)"
  else
    check_warn "gh 인증 필요 — 'gh auth login' 실행"
  fi

  REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
  if [[ -n "$REPO" ]]; then
    check_pass "GitHub 레포: $REPO"
  else
    check_warn "GitHub 레포 연결 없음 (로컬에서만 실행 가능)"
  fi
fi

echo ""

# ─── 에이전트 CLI ─────────────────────────────────────────────────────────────
echo "[ 에이전트 CLI ]"

for AGENT in "${AGENTS[@]}"; do
  case "$AGENT" in
    claude)
      if command -v claude &>/dev/null; then
        check_pass "claude CLI"
      else
        check_warn "claude CLI 미설치 — https://claude.ai/claude-code"
      fi
      ;;
    codex)
      if command -v codex &>/dev/null; then
        check_pass "codex CLI"
      else
        check_warn "codex CLI 미설치 — npm install -g @openai/codex"
      fi
      ;;
    gemini)
      if command -v gemini &>/dev/null; then
        check_pass "gemini CLI"
      else
        check_warn "gemini CLI 미설치 — https://github.com/google-gemini/gemini-cli"
      fi
      ;;
    *)
      if command -v "$AGENT" &>/dev/null; then
        check_pass "$AGENT CLI"
      else
        check_warn "$AGENT CLI 미설치 또는 알 수 없는 에이전트"
      fi
      ;;
  esac
done

echo ""

# ─── Copilot 관련 (선택) ──────────────────────────────────────────────────────
echo "[ Copilot 설정 (선택) ]"

if [[ -n "${COPILOT_ASSIGN_TOKEN:-}" ]]; then
  check_pass "COPILOT_ASSIGN_TOKEN 설정됨"
else
  check_warn "COPILOT_ASSIGN_TOKEN 미설정 (Copilot 할당 불가)"
fi

# plannotator 체크
if command -v plannotator &>/dev/null; then
  check_pass "plannotator (planview 통합 가능)"
else
  check_warn "plannotator 미설치 (planview 없이 진행)"
fi

echo ""

# ─── 파이프라인 상태 ──────────────────────────────────────────────────────────
echo "[ 파이프라인 상태 ]"

STATE_FILE="${ROOT_DIR:-$(pwd)}/.conductor-pipeline-state.json"
if [[ -f "$STATE_FILE" ]]; then
  LAST_STAGE=$(jq -r '.stage // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
  LAST_FEATURE=$(jq -r '.feature // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
  LAST_STATUS=$(jq -r '.status // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
  check_warn "미완료 파이프라인 발견: $LAST_FEATURE @ $LAST_STAGE ($LAST_STATUS)"
  echo "         → 재개: bash scripts/pipeline.sh --resume"
  echo "         → 초기화: rm $STATE_FILE"
else
  check_pass "파이프라인 상태 없음 (새로 시작)"
fi

# ─── 결과 요약 ────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: 통과 $PASS / 경고 $WARN / 실패 $FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $FAIL -gt 0 ]]; then
  echo ""
  echo "❌ 필수 도구가 없습니다. 위의 실패 항목을 해결 후 다시 실행하세요."
  exit 1
elif [[ $WARN -gt 0 ]]; then
  echo ""
  echo "⚠️  경고가 있지만 기본 기능은 사용 가능합니다."
  exit 0
else
  echo ""
  echo "✅ 모든 점검 통과! 파이프라인을 시작할 수 있습니다."
  exit 0
fi
