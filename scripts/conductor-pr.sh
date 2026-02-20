#!/usr/bin/env bash
# conductor-pr.sh — Conductor 완료 후 PR 자동 생성
# 사용법: bash scripts/conductor-pr.sh <feature-name> [base-branch]
# 전제: gh CLI 설치 및 인증 완료
#
# 플래그:
#   --skip-hooks  : 모든 훅 우회
set -euo pipefail

# ─── 훅 라이브러리 로드 ───────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/lib/hooks.sh" ]]; then
  # shellcheck source=lib/hooks.sh
  source "$SCRIPT_DIR/lib/hooks.sh"
else
  run_hook() { return 0; }
fi

# ─── 인수 파싱 ────────────────────────────────────────────────────────────────
FEATURE_NAME=""
BASE_BRANCH="main"

for arg in "$@"; do
  case "$arg" in
    --skip-hooks)  export CONDUCTOR_SKIP_HOOKS=1 ;;
    --*)           echo "알 수 없는 플래그: $arg" >&2; exit 1 ;;
    *)
      if [[ -z "$FEATURE_NAME" ]]; then
        FEATURE_NAME="$arg"
      else
        BASE_BRANCH="$arg"
      fi
      ;;
  esac
done

if [[ -z "$FEATURE_NAME" ]]; then
  echo "사용법: $0 <feature-name> [base-branch] [--skip-hooks]"
  exit 1
fi

# ─── 피처 이름 검증 및 정규화 ────────────────────────────────────────────────
FEATURE_NAME_SAFE="$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-//;s/-$//')"
if [[ "$FEATURE_NAME_SAFE" != "$FEATURE_NAME" ]]; then
  echo "⚠️  피처 이름 정규화: '$FEATURE_NAME' → '$FEATURE_NAME_SAFE'"
  FEATURE_NAME="$FEATURE_NAME_SAFE"
fi
if [[ -z "$FEATURE_NAME" ]]; then
  echo "❌ 유효하지 않은 피처 이름입니다. 알파벳/숫자/하이픈만 사용하세요."
  exit 1
fi

if ! command -v gh &>/dev/null; then
  echo "❌ gh CLI가 설치되어 있지 않습니다."
  echo "   설치: https://cli.github.com/"
  exit 1
fi

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TREES_DIR="$ROOT_DIR/trees"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Conductor PR 생성"
echo "  Feature : $FEATURE_NAME"
echo "  Target  : $BASE_BRANCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Pre-pr 훅 ────────────────────────────────────────────────────────────────
run_hook pre-pr "$FEATURE_NAME" "$BASE_BRANCH"

PR_URLS=()
PR_ERRORS=()

# ─── 각 에이전트 worktree에서 PR 생성 ───────────────────────────────────────
for TREE_PATH in "$TREES_DIR"/feat-"$FEATURE_NAME"-*; do
  if [[ ! -d "$TREE_PATH" ]]; then continue; fi

  AGENT_SUFFIX="${TREE_PATH##*feat-$FEATURE_NAME-}"
  BRANCH_NAME="feat/$FEATURE_NAME-$AGENT_SUFFIX"

  echo ""
  echo "📦 [$AGENT_SUFFIX] 처리 중..."
  echo "   Tree  : $TREE_PATH"
  echo "   Branch: $BRANCH_NAME"

  # 서브셸로 cd — set -euo pipefail 하에서 안전하게 디렉토리 변경
  PR_RESULT=$(
    cd "$TREE_PATH"

    # 변경사항이 있는지 확인
    if git status --porcelain | grep -q .; then
      echo "   📝 미커밋 변경사항 발견 - 자동 커밋 중..." >&2
      git add .
      git commit -m "feat: $FEATURE_NAME ($AGENT_SUFFIX version)

Auto-committed by conductor-pr.sh
Agent: $AGENT_SUFFIX
Base: $BASE_BRANCH"
    fi

    # 원격에 푸시
    echo "   ⬆️  원격 브랜치에 푸시 중..." >&2
    git push origin "$BRANCH_NAME" --set-upstream 2>/dev/null || \
      git push --set-upstream origin "$BRANCH_NAME"

    # PR 생성
    PR_TITLE="feat: $FEATURE_NAME ($AGENT_SUFFIX version)"
    PR_BODY="## 구현 정보

- **에이전트**: $AGENT_SUFFIX
- **피처**: $FEATURE_NAME
- **기반 브랜치**: $BASE_BRANCH
- **생성 방식**: Conductor 패턴 (병렬 에이전트)

## 검토 포인트

이 PR은 Conductor 패턴으로 자동 생성된 $AGENT_SUFFIX 버전입니다.
다른 에이전트 버전과 비교하여 최적의 구현을 선택하거나 cherry-pick으로 조합하세요.

## 관련 PR

- feat/$FEATURE_NAME-* 브랜치의 다른 에이전트 버전과 비교하세요."

    if gh pr view "$BRANCH_NAME" &>/dev/null; then
      echo "   ℹ️  PR이 이미 존재합니다." >&2
      gh pr view "$BRANCH_NAME" --json url -q .url
    else
      echo "   🔗 PR 생성 중..." >&2
      gh pr create \
        -B "$BASE_BRANCH" \
        -H "$BRANCH_NAME" \
        -t "$PR_TITLE" \
        -b "$PR_BODY" \
        --json url -q .url 2>/dev/null || echo "PR_FAILED"
    fi
  ) || {
    echo "   ❌ [$AGENT_SUFFIX] 처리 중 오류 발생 — 건너뜀"
    PR_ERRORS+=("[$AGENT_SUFFIX] 오류")
    continue
  }

  if [[ "$PR_RESULT" == "PR_FAILED" ]]; then
    echo "   ❌ PR 생성 실패: $BRANCH_NAME"
    PR_ERRORS+=("[$AGENT_SUFFIX] PR 생성 실패")
  elif [[ ! "$PR_RESULT" =~ ^https:// ]]; then
    echo "   ❌ PR URL이 유효하지 않습니다: '$PR_RESULT'"
    PR_ERRORS+=("[$AGENT_SUFFIX] 잘못된 PR URL")
  else
    PR_URLS+=("[$AGENT_SUFFIX] $PR_RESULT")
    echo "   ✅ PR: $PR_RESULT"
    # Per-agent post-pr 훅
    run_hook post-pr "$FEATURE_NAME" "$AGENT_SUFFIX" "$PR_RESULT"
  fi
done

# ─── Post-pr 훅 (전체 완료 후) ───────────────────────────────────────────────
run_hook post-pr-all "$FEATURE_NAME" "${#PR_URLS[@]}"

# ─── 요약 ────────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  생성된 PR 목록"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for URL in "${PR_URLS[@]}"; do
  echo "  ✅ $URL"
done

if [[ ${#PR_ERRORS[@]} -gt 0 ]]; then
  echo ""
  echo "  실패 항목:"
  for ERR in "${PR_ERRORS[@]}"; do
    echo "  ❌ $ERR"
  done
fi

echo ""
echo "  cherry-pick 병합 예시:"
echo "    git checkout -b feat/$FEATURE_NAME-best $BASE_BRANCH"
echo "    # 각 PR에서 원하는 커밋을 cherry-pick"
echo "    gh pr create -B $BASE_BRANCH -H feat/$FEATURE_NAME-best"

# PR이 하나도 없으면 실패
if [[ ${#PR_URLS[@]} -eq 0 ]]; then
  echo ""
  echo "❌ 생성된 PR이 없습니다."
  exit 1
fi
