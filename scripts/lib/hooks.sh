#!/usr/bin/env bash
# lib/hooks.sh — Conductor 파이프라인 훅 실행 라이브러리
#
# 사용법:
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/hooks.sh"
#   run_hook pre-conductor "$FEATURE_NAME" "$BASE_BRANCH"
#
# 훅 파일 위치: scripts/hooks/<event>.sh
#   pre-conductor   : worktree 생성 전 실행 (실패 시 파이프라인 중단)
#   post-conductor  : tmux 세션 시작 후 실행 (실패해도 계속)
#   pre-pr          : PR 생성 전 실행 (실패 시 해당 PR 스킵)
#   post-pr         : PR 생성 후 실행 (실패해도 계속)
#   pre-copilot     : Copilot 할당 전 실행 (실패 시 중단)
#   post-copilot    : Copilot 할당 후 실행 (실패해도 계속)
#   pre-pipeline    : pipeline.sh 전체 실행 전 (실패 시 중단)
#   post-pipeline   : pipeline.sh 완료 후 (실패해도 계속)
#
# 환경 변수:
#   CONDUCTOR_SKIP_HOOKS=1  : 모든 훅 우회
#   CONDUCTOR_HOOKS_DIR     : 훅 디렉토리 경로 오버라이드

# 훅 디렉토리 결정
_get_hooks_dir() {
  if [[ -n "${CONDUCTOR_HOOKS_DIR:-}" ]]; then
    echo "$CONDUCTOR_HOOKS_DIR"
    return
  fi
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  echo "$root/scripts/hooks"
}

# 훅 실행 함수
# 인수: <event> [args...]
# 반환: pre-* 훅 실패 시 훅의 exit code / post-* 훅 실패 시 0 (경고만)
run_hook() {
  local event="${1:-}"
  if [[ -z "$event" ]]; then
    echo "run_hook: event 인수가 필요합니다" >&2
    return 1
  fi
  shift
  local args=("$@")

  # 훅 건너뜀 플래그
  if [[ "${CONDUCTOR_SKIP_HOOKS:-0}" == "1" ]]; then
    return 0
  fi

  local hooks_dir
  hooks_dir="$(_get_hooks_dir)"
  local hook_file="$hooks_dir/${event}.sh"

  # 훅 파일이 없으면 정상 (선택적)
  if [[ ! -f "$hook_file" ]]; then
    return 0
  fi

  echo ""
  echo "🪝 훅 실행: $event"

  if bash "$hook_file" "${args[@]}"; then
    echo "   ✅ 훅 완료: $event"
    return 0
  else
    local exit_code=$?
    if [[ "$event" == pre-* ]]; then
      echo "   ❌ Pre-훅 실패: $event (exit $exit_code) → 파이프라인 중단"
      return "$exit_code"
    else
      echo "   ⚠️  Post-훅 경고: $event (exit $exit_code) → 계속 진행"
      return 0
    fi
  fi
}

# 훅 목록 출력 (디버그용)
list_hooks() {
  local hooks_dir
  hooks_dir="$(_get_hooks_dir)"
  echo "훅 디렉토리: $hooks_dir"
  if [[ -d "$hooks_dir" ]]; then
    local count=0
    for f in "$hooks_dir"/*.sh; do
      [[ -f "$f" ]] || continue
      echo "  $(basename "$f")"
      count=$((count + 1))
    done
    if [[ $count -eq 0 ]]; then
      echo "  (훅 없음)"
    fi
  else
    echo "  (디렉토리 없음)"
  fi
}
