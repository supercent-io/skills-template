#!/usr/bin/env bash
# conductor-cleanup.sh — Conductor worktree 정리
# 사용법: bash scripts/conductor-cleanup.sh <feature-name>
set -euo pipefail

FEATURE_NAME="${1:-}"
if [[ -z "$FEATURE_NAME" ]]; then
  echo "사용법: $0 <feature-name>"
  exit 1
fi

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TREES_DIR="$ROOT_DIR/trees"
SESSION="conductor-$FEATURE_NAME"

echo "🧹 Conductor 정리: $FEATURE_NAME"

# tmux 세션 종료
if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux kill-session -t "$SESSION"
  echo "  ✅ tmux 세션 종료: $SESSION"
fi

# worktree 제거
for TREE_PATH in "$TREES_DIR"/feat-"$FEATURE_NAME"-*; do
  if [[ ! -d "$TREE_PATH" ]]; then continue; fi
  BRANCH="${TREE_PATH##*/}"
  echo "  🗑  worktree 제거: $TREE_PATH"
  git worktree remove "$TREE_PATH" --force 2>/dev/null || rm -rf "$TREE_PATH"
done

# 로컬 브랜치 제거 (merged 브랜치만)
git branch | grep "feat/$FEATURE_NAME-" | while read -r BRANCH; do
  BRANCH="${BRANCH//[[:space:]]/}"
  if git branch -d "$BRANCH" 2>/dev/null; then
    echo "  🗑  브랜치 제거: $BRANCH"
  else
    echo "  ⚠️  브랜치 제거 실패 (미병합): $BRANCH (수동 삭제: git branch -D $BRANCH)"
  fi
done

echo ""
echo "✅ 정리 완료"
git worktree list
