#!/usr/bin/env bash
# pipeline.sh — Conductor 통합 파이프라인 러너
# 사용법: bash scripts/pipeline.sh <feature-name> [옵션]
#
# 옵션:
#   --base <branch>         : 기반 브랜치 (기본: main)
#   --agents <list>         : 에이전트 목록 (기본: claude,codex)
#   --stages <list>         : 실행할 스테이지 (기본: check,plan,conductor,pr)
#                             가능 값: check,plan,conductor,pr,copilot
#   --resume                : 마지막 상태에서 재개
#   --no-attach             : tmux attach 하지 않음
#   --skip-hooks            : 모든 훅 우회
#   --dry-run               : 실제 실행 없이 단계 출력만
#   --state-file <path>     : 상태 파일 경로 오버라이드
#
# 스테이지:
#   check     : 사전 점검 (pipeline-check.sh)
#   plan      : plannotator(planno)로 계획 검토 (conductor-planno.sh 호출)
#   conductor : worktree 생성 및 에이전트 실행
#   pr        : PR 생성 (conductor-pr.sh)
#   copilot   : Copilot에 이슈 할당 (copilot-assign-issue.sh)
set -euo pipefail

# ─── 훅 라이브러리 로드 ───────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/lib/hooks.sh" ]]; then
  # shellcheck source=lib/hooks.sh
  source "$SCRIPT_DIR/lib/hooks.sh"
else
  run_hook() { return 0; }
fi

# ─── 기본값 ───────────────────────────────────────────────────────────────────
FEATURE_NAME=""
BASE_BRANCH="main"
AGENTS_ARG="claude,codex"
STAGES="check,conductor,pr"
RESUME=false
NO_ATTACH=false
DRY_RUN=false
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$ROOT_DIR/.conductor-pipeline-state.json"

# ─── 인수 파싱 ────────────────────────────────────────────────────────────────
i=0
ARGS=("$@")
while [[ $i -lt ${#ARGS[@]} ]]; do
  arg="${ARGS[$i]}"
  case "$arg" in
    --base)        i=$((i+1)); BASE_BRANCH="${ARGS[$i]}" ;;
    --agents)      i=$((i+1)); AGENTS_ARG="${ARGS[$i]}" ;;
    --stages)      i=$((i+1)); STAGES="${ARGS[$i]}" ;;
    --state-file)  i=$((i+1)); STATE_FILE="${ARGS[$i]}" ;;
    --resume)      RESUME=true ;;
    --no-attach)   NO_ATTACH=true ;;
    --skip-hooks)  export CONDUCTOR_SKIP_HOOKS=1 ;;
    --dry-run)     DRY_RUN=true ;;
    --*)           echo "알 수 없는 옵션: $arg" >&2; exit 1 ;;
    *)
      if [[ -z "$FEATURE_NAME" ]]; then
        FEATURE_NAME="$arg"
      fi
      ;;
  esac
  i=$((i+1))
done

# ─── Resume 처리 ──────────────────────────────────────────────────────────────
if [[ "$RESUME" == "true" ]]; then
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "❌ 재개할 파이프라인 상태 파일이 없습니다: $STATE_FILE"
    exit 1
  fi
  SAVED_FEATURE=$(jq -r '.feature // ""' "$STATE_FILE")
  SAVED_BASE=$(jq -r '.base_branch // "main"' "$STATE_FILE")
  SAVED_AGENTS=$(jq -r '.agents // "claude,codex"' "$STATE_FILE")
  SAVED_STAGES=$(jq -r '.stages // "check,conductor,pr"' "$STATE_FILE")
  SAVED_STAGE=$(jq -r '.stage // "check"' "$STATE_FILE")
  SAVED_STATUS=$(jq -r '.status // "pending"' "$STATE_FILE")

  echo "📂 파이프라인 재개"
  echo "   피처   : $SAVED_FEATURE"
  echo "   스테이지: $SAVED_STAGE ($SAVED_STATUS)"

  FEATURE_NAME="$SAVED_FEATURE"
  BASE_BRANCH="$SAVED_BASE"
  AGENTS_ARG="$SAVED_AGENTS"
  STAGES="$SAVED_STAGES"   # 원래 실행의 스테이지 목록 복원

  # 실패한 스테이지부터 재시작하도록 STAGES 조정
  ALL_STAGES="check,plan,conductor,pr,copilot"
  IFS=',' read -ra ALL_STAGE_ARR <<< "$ALL_STAGES"
  IFS=',' read -ra CUR_STAGES <<< "$STAGES"
  RESUME_FROM="$SAVED_STAGE"

  # 재개 시 스테이지 재설정: 저장된 스테이지부터
  STAGES_REMAINING=()
  FOUND_STAGE=false
  for s in "${ALL_STAGE_ARR[@]}"; do
    if [[ "$s" == "$RESUME_FROM" ]]; then
      FOUND_STAGE=true
    fi
    if [[ "$FOUND_STAGE" == "true" ]]; then
      # 원래 STAGES에 있는 스테이지만 포함
      for cs in "${CUR_STAGES[@]}"; do
        if [[ "$cs" == "$s" ]]; then
          STAGES_REMAINING+=("$s")
          break
        fi
      done
    fi
  done
  if [[ ${#STAGES_REMAINING[@]} -gt 0 ]]; then
    STAGES=$(IFS=','; echo "${STAGES_REMAINING[*]}")
  fi
fi

if [[ -z "$FEATURE_NAME" ]]; then
  echo "사용법: $0 <feature-name> [옵션]"
  echo ""
  echo "옵션:"
  echo "  --base <branch>     기반 브랜치 (기본: main)"
  echo "  --agents <list>     에이전트 목록 (기본: claude,codex)"
  echo "  --stages <list>     스테이지 (기본: check,conductor,pr)"
  echo "  --resume            마지막 상태에서 재개"
  echo "  --no-attach         tmux attach 안 함"
  echo "  --skip-hooks        훅 우회"
  echo "  --dry-run           실제 실행 없이 단계 출력"
  echo ""
  echo "예시:"
  echo "  $0 user-auth --base main --agents claude,codex"
  echo "  $0 user-auth --stages check,conductor,pr,copilot"
  echo "  $0 --resume"
  exit 1
fi

# ─── 피처 이름 정규화 ─────────────────────────────────────────────────────────
FEATURE_NAME_SAFE="$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//')"
if [[ "$FEATURE_NAME_SAFE" != "$FEATURE_NAME" ]]; then
  echo "⚠️  피처 이름 정규화: '$FEATURE_NAME' → '$FEATURE_NAME_SAFE'"
  FEATURE_NAME="$FEATURE_NAME_SAFE"
fi

IFS=',' read -ra STAGE_LIST <<< "$STAGES"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Conductor 파이프라인"
echo "  피처    : $FEATURE_NAME"
echo "  브랜치  : $BASE_BRANCH"
echo "  에이전트: $AGENTS_ARG"
echo "  스테이지: ${STAGE_LIST[*]}"
[[ "$DRY_RUN" == "true" ]] && echo "  모드    : DRY-RUN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─── 상태 관리 함수 ───────────────────────────────────────────────────────────
save_state() {
  local stage="$1"
  local status="$2"   # pending | running | done | failed
  local extra="${3:-}"

  jq -n \
    --arg feature "$FEATURE_NAME" \
    --arg base "$BASE_BRANCH" \
    --arg agents "$AGENTS_ARG" \
    --arg stages "$STAGES" \
    --arg stage "$stage" \
    --arg status "$status" \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --argjson extra "${extra:-null}" \
    '{
      feature: $feature,
      base_branch: $base,
      agents: $agents,
      stages: $stages,
      stage: $stage,
      status: $status,
      updated_at: $ts,
      extra: $extra
    }' > "$STATE_FILE"
}

clear_state() {
  rm -f "$STATE_FILE" 2>/dev/null || true
}

# ─── Pre-pipeline 훅 ──────────────────────────────────────────────────────────
run_hook pre-pipeline "$FEATURE_NAME" "$BASE_BRANCH" "$STAGES"

# ─── 스테이지 실행 ────────────────────────────────────────────────────────────
PIPELINE_FAILED=false

run_stage() {
  local stage="$1"
  echo ""
  echo "▶ 스테이지: $stage"
  echo "  ─────────────────────────────────────"

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [dry-run] $stage 스킵"
    return 0
  fi

  save_state "$stage" "running"

  case "$stage" in
    # ── 사전 점검 ──────────────────────────────────────────────────────────
    check)
      if bash "$SCRIPT_DIR/pipeline-check.sh" --agents="$AGENTS_ARG"; then
        save_state "$stage" "done"
      else
        save_state "$stage" "failed"
        return 1
      fi
      ;;

    # ── plannotator(planno) 계획 검토 (선택적 독립 단계) ─────────────────
    plan)
      if [[ -f "$SCRIPT_DIR/conductor-planno.sh" ]]; then
        if bash "$SCRIPT_DIR/conductor-planno.sh" "$FEATURE_NAME" "$BASE_BRANCH" "$AGENTS_ARG"; then
          save_state "$stage" "done"
        else
          echo "  ⚠️  planno(plannotator) 검토 취소됨"
          save_state "$stage" "failed"
          return 1
        fi
      else
        echo "  ⚠️  conductor-planno.sh 없음 — plan 스테이지 건너뜀"
        save_state "$stage" "done"
      fi
      ;;

    # ── Conductor 실행 ─────────────────────────────────────────────────────
    conductor)
      local attach_flag=""
      [[ "$NO_ATTACH" == "true" ]] && attach_flag="--no-attach"
      if bash "$SCRIPT_DIR/conductor.sh" \
          "$FEATURE_NAME" \
          "$BASE_BRANCH" \
          "$AGENTS_ARG" \
          $attach_flag; then
        save_state "$stage" "done"
      else
        save_state "$stage" "failed"
        return 1
      fi
      ;;

    # ── PR 생성 ────────────────────────────────────────────────────────────
    pr)
      if bash "$SCRIPT_DIR/conductor-pr.sh" "$FEATURE_NAME" "$BASE_BRANCH"; then
        save_state "$stage" "done"
      else
        save_state "$stage" "failed"
        return 1
      fi
      ;;

    # ── Copilot 할당 ───────────────────────────────────────────────────────
    copilot)
      if [[ -z "${COPILOT_ISSUE_NUMBER:-}" ]]; then
        echo "  ⚠️  COPILOT_ISSUE_NUMBER 환경 변수가 없습니다."
        echo "     export COPILOT_ISSUE_NUMBER=<issue-number>"
        save_state "$stage" "failed" '{"reason":"COPILOT_ISSUE_NUMBER not set"}'
        return 1
      fi
      if bash "$SCRIPT_DIR/copilot-assign-issue.sh" "$COPILOT_ISSUE_NUMBER"; then
        save_state "$stage" "done"
      else
        save_state "$stage" "failed"
        return 1
      fi
      ;;

    *)
      echo "  ❌ 알 수 없는 스테이지: $stage"
      return 1
      ;;
  esac

  echo "  ✅ 완료: $stage"
}

# ─── 스테이지 순서대로 실행 ───────────────────────────────────────────────────
for STAGE in "${STAGE_LIST[@]}"; do
  if ! run_stage "$STAGE"; then
    echo ""
    echo "❌ 파이프라인 실패: $STAGE"
    echo "   재개: bash $0 '$FEATURE_NAME' --stages $STAGES --resume"
    PIPELINE_FAILED=true
    break
  fi
done

# ─── Post-pipeline 훅 ─────────────────────────────────────────────────────────
if [[ "$PIPELINE_FAILED" == "false" ]]; then
  run_hook post-pipeline "$FEATURE_NAME" "success"
  clear_state
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ✅ 파이프라인 완료: $FEATURE_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  run_hook post-pipeline "$FEATURE_NAME" "failed"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ❌ 파이프라인 실패"
  echo "  상태 파일: $STATE_FILE"
  echo "  재개 명령: bash $0 --resume"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi
