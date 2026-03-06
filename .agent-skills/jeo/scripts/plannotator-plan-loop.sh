#!/usr/bin/env bash
# JEO PLAN gate for plannotator.
# Guarantees blocking review, retries dead sessions, and requires explicit stop decision.

set -euo pipefail

PLAN_FILE="${1:-plan.md}"
FEEDBACK_FILE="${2:-}"
MAX_RESTARTS="${3:-3}"

if ! command -v plannotator >/dev/null 2>&1; then
  echo "[JEO][PLAN] plannotator is required in PLAN phase." >&2
  exit 127
fi

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "[JEO][PLAN] plan file not found: $PLAN_FILE" >&2
  exit 2
fi

if ! [[ "$MAX_RESTARTS" =~ ^[0-9]+$ ]] || [[ "$MAX_RESTARTS" -lt 1 ]]; then
  echo "[JEO][PLAN] invalid MAX_RESTARTS: $MAX_RESTARTS" >&2
  exit 2
fi

SESSION_KEY="$(python3 -c "import hashlib,os; print(hashlib.md5(os.getcwd().encode()).hexdigest()[:8])" 2>/dev/null || echo "default")"
FEEDBACK_DIR="/tmp/jeo-${SESSION_KEY}"
RUNTIME_HOME="${FEEDBACK_DIR}/.plannotator"
mkdir -p "$FEEDBACK_DIR" "$RUNTIME_HOME"

if [[ -z "$FEEDBACK_FILE" ]]; then
  FEEDBACK_FILE="${FEEDBACK_DIR}/plannotator_feedback.txt"
else
  mkdir -p "$(dirname "$FEEDBACK_FILE")"
fi

attempt=1
while (( attempt <= MAX_RESTARTS )); do
  : > "$FEEDBACK_FILE"
  touch /tmp/jeo-plannotator-direct.lock

  python3 -c "
import json, sys
plan = open(sys.argv[1]).read()
sys.stdout.write(json.dumps({'tool_input': {'plan': plan, 'permission_mode': 'acceptEdits'}}))
" "$PLAN_FILE" | env HOME="$RUNTIME_HOME" PLANNOTATOR_HOME="$RUNTIME_HOME" plannotator > "$FEEDBACK_FILE" 2>&1 || true

  set +e
  python3 - "$FEEDBACK_FILE" <<'PYEOF'
import json, sys
path = sys.argv[1]
try:
    payload = json.load(open(path))
except Exception:
    sys.exit(20)
approved = payload.get("approved")
if approved is True:
    sys.exit(0)
if approved is False:
    sys.exit(10)
sys.exit(20)
PYEOF
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    echo "[JEO][PLAN] approved=true"
    exit 0
  fi

  if [[ "$rc" -eq 10 ]]; then
    echo "[JEO][PLAN] approved=false (feedback)"
    exit 10
  fi

  echo "[JEO][PLAN] session ended unexpectedly (attempt ${attempt}/${MAX_RESTARTS}). restarting..." >&2
  ((attempt++))
done

echo "[JEO][PLAN] plannotator session ended ${MAX_RESTARTS} times." >&2
if [[ -t 0 && -t 1 ]]; then
  read -r -p "PLAN 작업을 종료할까요? [y/N]: " ans
  case "$ans" in
    y|Y|yes|YES)
      echo "[JEO][PLAN] user requested PLAN stop." >&2
      exit 30
      ;;
  esac
fi

echo "[JEO][PLAN] confirmation required. stop and ask user whether to continue PLAN." >&2
exit 31
