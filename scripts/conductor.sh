#!/usr/bin/env bash
# conductor.sh — AI 에이전트 병렬 실행 오케스트레이터
# 사용법: bash scripts/conductor.sh <feature-name> [base-branch] [agents]
# 예시:
#   bash scripts/conductor.sh user-dashboard main
#   bash scripts/conductor.sh user-dashboard main claude,codex,gemini
#   bash scripts/conductor.sh user-dashboard main claude,codex --no-attach
#
# 플래그:
#   --no-attach   : tmux 세션에 자동으로 attach하지 않음 (비대화형 실행용)
#   --skip-hooks  : 모든 훅 우회 (CONDUCTOR_SKIP_HOOKS=1 과 동일)
#
# planview 통합: bash scripts/conductor-planview.sh <feature-name> 사용 권장
set -euo pipefail

# ─── 훅 라이브러리 로드 ───────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/lib/hooks.sh" ]]; then
  # shellcheck source=lib/hooks.sh
  source "$SCRIPT_DIR/lib/hooks.sh"
else
  # 훅 라이브러리 없으면 no-op stub 사용
  run_hook() { return 0; }
fi

# ─── 인수 파싱 ────────────────────────────────────────────────────────────────
FEATURE_NAME=""
BASE_BRANCH="main"
AGENTS_ARG="claude,codex"
NO_ATTACH=false

for arg in "$@"; do
  case "$arg" in
    --no-attach)   NO_ATTACH=true ;;
    --skip-hooks)  export CONDUCTOR_SKIP_HOOKS=1 ;;
    --*)           echo "알 수 없는 플래그: $arg" >&2; exit 1 ;;
    *)
      if [[ -z "$FEATURE_NAME" ]]; then
        FEATURE_NAME="$arg"
      elif [[ "$BASE_BRANCH" == "main" && "$arg" != *,* ]]; then
        BASE_BRANCH="$arg"
      else
        AGENTS_ARG="$arg"
      fi
      ;;
  esac
done

if [[ -z "$FEATURE_NAME" ]]; then
  echo "사용법: $0 <feature-name> [base-branch] [agents] [--no-attach] [--skip-hooks]"
  echo "  예시: $0 user-dashboard main claude,codex"
  exit 1
fi

# ─── 피처 이름 검증 및 정규화 ────────────────────────────────────────────────
# 허용: 알파벳 소문자, 숫자, 하이픈. 공백과 특수문자를 하이픈으로 변환
FEATURE_NAME_SAFE="$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//')"
if [[ "$FEATURE_NAME_SAFE" != "$FEATURE_NAME" ]]; then
  echo "⚠️  피처 이름 정규화: '$FEATURE_NAME' → '$FEATURE_NAME_SAFE'"
  FEATURE_NAME="$FEATURE_NAME_SAFE"
fi
if [[ -z "$FEATURE_NAME" ]]; then
  echo "❌ 유효하지 않은 피처 이름입니다. 알파벳/숫자/하이픈만 사용하세요."
  exit 1
fi

# 에이전트 배열로 파싱
IFS=',' read -ra AGENTS <<< "$AGENTS_ARG"

# ─── 설정 ─────────────────────────────────────────────────────────────────────
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TREES_DIR="$ROOT_DIR/trees"
SESSION="conductor-$FEATURE_NAME"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Conductor 패턴 시작"
echo "  Feature : $FEATURE_NAME"
echo "  Base    : $BASE_BRANCH"
echo "  Agents  : ${AGENTS[*]}"
echo "  Attach  : $( [[ "$NO_ATTACH" == "true" ]] && echo "아니오 (--no-attach)" || echo "예" )"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── 전제 조건 확인 ───────────────────────────────────────────────────────────
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Git 레포지토리가 아닙니다: $ROOT_DIR"
  exit 1
fi

if ! command -v tmux &>/dev/null; then
  echo "❌ tmux가 설치되어 있지 않습니다. 설치 후 다시 실행하세요."
  echo "   macOS: brew install tmux"
  echo "   Linux: sudo apt install tmux"
  exit 1
fi

mkdir -p "$TREES_DIR"

# ─── Pre-conductor 훅 ─────────────────────────────────────────────────────────
run_hook pre-conductor "$FEATURE_NAME" "$BASE_BRANCH" "${AGENTS[*]}"

# ─── 기존 tmux 세션 정리 ──────────────────────────────────────────────────────
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "⚠️  기존 tmux 세션 '$SESSION' 발견. 정리 중..."
  tmux kill-session -t "$SESSION"
fi

# ─── 에이전트별 worktree 생성 ─────────────────────────────────────────────────
declare -A TREE_PATHS
declare -A BRANCH_NAMES

for AGENT in "${AGENTS[@]}"; do
  TREE_PATH="$TREES_DIR/feat-$FEATURE_NAME-$AGENT"
  BRANCH_NAME="feat/$FEATURE_NAME-$AGENT"
  TREE_PATHS[$AGENT]="$TREE_PATH"
  BRANCH_NAMES[$AGENT]="$BRANCH_NAME"

  if [[ -d "$TREE_PATH" ]]; then
    echo "⚠️  worktree 이미 존재: $TREE_PATH (건너뜀)"
  else
    echo "📁 worktree 생성: $TREE_PATH (브랜치: $BRANCH_NAME)"
    git worktree add "$TREE_PATH" -b "$BRANCH_NAME" "$BASE_BRANCH"
  fi

  # 공통 설정 파일 복사
  for CONFIG_FILE in .env .env.local; do
    if [[ -f "$ROOT_DIR/$CONFIG_FILE" ]]; then
      cp "$ROOT_DIR/$CONFIG_FILE" "$TREE_PATH/$CONFIG_FILE" 2>/dev/null || true
      echo "   📄 복사: $CONFIG_FILE → $TREE_PATH/"
    fi
  done
done

# ─── 에이전트 CLI 명령 결정 ────────────────────────────────────────────────────
get_agent_cmd() {
  local agent="$1"
  case "$agent" in
    claude)  echo "claude" ;;
    codex)   echo "codex" ;;
    gemini)  echo "gemini" ;;
    *)       echo "bash" ;;
  esac
}

# ─── tmux 세션에서 에이전트 실행 ─────────────────────────────────────────────
echo ""
echo "🚀 tmux 세션 '$SESSION' 시작..."

FIRST_AGENT="${AGENTS[0]}"
FIRST_TREE="${TREE_PATHS[$FIRST_AGENT]}"

# 첫 번째 에이전트로 세션 생성
FIRST_CMD=$(get_agent_cmd "$FIRST_AGENT")
tmux new-session -d -s "$SESSION" -c "$FIRST_TREE" \
  -x "$(tput cols 2>/dev/null || echo 220)" \
  -y "$(tput lines 2>/dev/null || echo 50)"

# 첫 번째 pane에 에이전트 실행
tmux rename-window -t "$SESSION:0" "conductor"
tmux send-keys -t "$SESSION:0" "echo '=== [$FIRST_AGENT] worktree: $FIRST_TREE ===' && $FIRST_CMD" Enter

# 나머지 에이전트는 가로 분할로 추가
for i in "${!AGENTS[@]}"; do
  if [[ $i -eq 0 ]]; then continue; fi
  AGENT="${AGENTS[$i]}"
  TREE="${TREE_PATHS[$AGENT]}"
  CMD=$(get_agent_cmd "$AGENT")

  tmux split-window -h -t "$SESSION:0" -c "$TREE"
  tmux send-keys -t "$SESSION:0" "echo '=== [$AGENT] worktree: $TREE ===' && $CMD" Enter
done

# 균등 레이아웃
tmux select-layout -t "$SESSION:0" tiled

# ─── Post-conductor 훅 ────────────────────────────────────────────────────────
run_hook post-conductor "$FEATURE_NAME" "$SESSION"

# ─── 완료 안내 ────────────────────────────────────────────────────────────────
echo ""
echo "✅ Conductor 세션 준비 완료!"
echo ""
echo "  Worktrees 위치:"
for AGENT in "${AGENTS[@]}"; do
  echo "    [$AGENT] ${TREE_PATHS[$AGENT]}"
  echo "           브랜치: ${BRANCH_NAMES[$AGENT]}"
done
echo ""
echo "  tmux 세션 attach:"
echo "    tmux attach-session -t $SESSION"
echo ""
echo "  작업 완료 후 PR 생성:"
echo "    bash scripts/conductor-pr.sh $FEATURE_NAME"
echo ""
echo "  Worktree 정리:"
echo "    bash scripts/conductor-cleanup.sh $FEATURE_NAME"

# ─── tmux 세션 attach (대화형 모드에서만) ─────────────────────────────────────
if [[ "$NO_ATTACH" == "false" ]]; then
  # 터미널이 대화형인 경우에만 attach
  if [[ -t 0 && -t 1 ]]; then
    tmux attach-session -t "$SESSION"
  else
    echo ""
    echo "  ℹ️  비대화형 환경 감지 — attach 건너뜀"
    echo "     수동 접속: tmux attach-session -t $SESSION"
  fi
fi
