#!/usr/bin/env bash
# JEO PLAN gate for plannotator.
# Guarantees blocking review, retries dead sessions, and requires explicit stop decision.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_FILE="${1:-plan.md}"
FEEDBACK_FILE="${2:-}"
MAX_RESTARTS="${3:-3}"
PORT_ERROR_REGEX='Failed to start server\. Is port .* in use|EADDRINUSE|EPERM|operation not permitted|Failed to listen'

if ! command -v plannotator >/dev/null 2>&1; then
  if ! bash "$SCRIPT_DIR/ensure-plannotator.sh" --quiet; then
    echo "[JEO][PLAN] plannotator is required in PLAN phase." >&2
    exit 127
  fi
fi

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "[JEO][PLAN] plan file not found: $PLAN_FILE" >&2
  exit 2
fi

if ! [[ "$MAX_RESTARTS" =~ ^[0-9]+$ ]] || [[ "$MAX_RESTARTS" -lt 1 ]]; then
  echo "[JEO][PLAN] invalid MAX_RESTARTS: $MAX_RESTARTS" >&2
  exit 2
fi

PLAN_HASH="$(python3 - "$PLAN_FILE" <<'PYEOF'
import hashlib, pathlib, sys
path = pathlib.Path(sys.argv[1])
try:
    data = path.read_text(encoding="utf-8")
except Exception:
    data = ""
print(hashlib.sha256(data.encode("utf-8")).hexdigest() if data else "")
PYEOF
)"

SESSION_KEY="$(python3 -c "import hashlib,os; print(hashlib.md5(os.getcwd().encode()).hexdigest()[:8])" 2>/dev/null || echo "default")"
FEEDBACK_DIR="/tmp/jeo-${SESSION_KEY}"
RUNTIME_HOME="${FEEDBACK_DIR}/.plannotator"
mkdir -p "$FEEDBACK_DIR" "$RUNTIME_HOME"

if [[ -z "$FEEDBACK_FILE" ]]; then
  FEEDBACK_FILE="${FEEDBACK_DIR}/plannotator_feedback.txt"
else
  mkdir -p "$(dirname "$FEEDBACK_FILE")"
fi

write_manual_feedback_json() {
  local approved="$1"
  local note="${2:-}"
  python3 - "$FEEDBACK_FILE" "$approved" "$note" <<'PYEOF'
import json, sys
path, approved_raw, note = sys.argv[1], sys.argv[2], sys.argv[3]
approved = approved_raw.lower() == "true"
payload = {
    "approved": approved,
    "source": "jeo-manual-fallback",
    "note": note,
}
with open(path, "w", encoding="utf-8") as f:
    json.dump(payload, f, ensure_ascii=False, indent=2)
PYEOF
}

write_state_gate_status() {
  local status="$1"
  JEO_GATE_STATUS="$status" python3 -c "
import json, os, subprocess, datetime
try:
    root = subprocess.check_output(['git','rev-parse','--show-toplevel'], stderr=subprocess.DEVNULL).decode().strip()
except Exception:
    root = os.getcwd()
f = os.path.join(root, '.omc/state/jeo-state.json')
if os.path.exists(f):
    try:
        import fcntl
        with open(f, 'r+') as fh:
            fcntl.flock(fh, fcntl.LOCK_EX)
            try:
                d = json.load(fh)
                d['plan_gate_status'] = os.environ['JEO_GATE_STATUS']
                d['updated_at'] = datetime.datetime.utcnow().isoformat() + 'Z'
                fh.seek(0); json.dump(d, fh, indent=2); fh.truncate()
            finally:
                fcntl.flock(fh, fcntl.LOCK_UN)
    except Exception:
        pass
" 2>/dev/null || true
}

persist_plan_state() {
  local gate_status="$1"
  local approved="$2"
  local review_method="${3:-plannotator}"
  local feedback_path="${4:-}"
  JEO_GATE_STATUS="$gate_status" \
  JEO_APPROVED="$approved" \
  JEO_REVIEW_METHOD="$review_method" \
  JEO_PLAN_HASH="$PLAN_HASH" \
  JEO_FEEDBACK_FILE="$feedback_path" \
  python3 - <<'PYEOF'
import datetime
import json
import os
import subprocess

try:
    root = subprocess.check_output(
        ["git", "rev-parse", "--show-toplevel"],
        stderr=subprocess.DEVNULL,
        text=True,
    ).strip()
except Exception:
    root = os.getcwd()

state_path = os.path.join(root, ".omc", "state", "jeo-state.json")
if not os.path.exists(state_path):
    raise SystemExit(0)

try:
    import fcntl
except Exception:
    fcntl = None

feedback_payload = None
feedback_file = os.environ.get("JEO_FEEDBACK_FILE", "")
if feedback_file and os.path.exists(feedback_file):
    try:
        feedback_payload = json.load(open(feedback_file))
    except Exception:
        feedback_payload = None

with open(state_path, "r+", encoding="utf-8") as fh:
    if fcntl:
        fcntl.flock(fh, fcntl.LOCK_EX)
    try:
        state = json.load(fh)
        gate_status = os.environ.get("JEO_GATE_STATUS", "pending")
        approved = os.environ.get("JEO_APPROVED", "false").lower() == "true"
        review_method = os.environ.get("JEO_REVIEW_METHOD", "plannotator")
        plan_hash = os.environ.get("JEO_PLAN_HASH", "")
        state["plan_gate_status"] = gate_status
        state["plan_approved"] = approved
        state["plan_review_method"] = review_method
        state["plan_current_hash"] = plan_hash
        state["last_reviewed_plan_hash"] = plan_hash
        state["last_reviewed_plan_at"] = datetime.datetime.utcnow().isoformat() + "Z"
        if approved:
            state["phase"] = "execute"
        elif gate_status == "feedback_required" and feedback_payload is not None:
            state["plannotator_feedback"] = feedback_payload
        state["updated_at"] = datetime.datetime.utcnow().isoformat() + "Z"
        fh.seek(0)
        json.dump(state, fh, ensure_ascii=False, indent=2)
        fh.truncate()
    finally:
        if fcntl:
            fcntl.flock(fh, fcntl.LOCK_UN)
PYEOF
}

prepare_state_for_plan_hash() {
  JEO_PLAN_HASH="$PLAN_HASH" python3 - <<'PYEOF'
import datetime
import json
import os
import subprocess
import sys

try:
    root = subprocess.check_output(
        ["git", "rev-parse", "--show-toplevel"],
        stderr=subprocess.DEVNULL,
        text=True,
    ).strip()
except Exception:
    root = os.getcwd()

state_path = os.path.join(root, ".omc", "state", "jeo-state.json")
if not os.path.exists(state_path):
    raise SystemExit(0)

state = json.load(open(state_path, encoding="utf-8"))
current_hash = os.environ.get("JEO_PLAN_HASH", "")
last_hash = state.get("last_reviewed_plan_hash")
gate_status = state.get("plan_gate_status", "pending")

if current_hash and last_hash == current_hash and gate_status in {"approved", "manual_approved"}:
    print("SKIP_APPROVED")
    raise SystemExit(0)
if current_hash and last_hash == current_hash and gate_status == "feedback_required":
    print("SKIP_FEEDBACK")
    raise SystemExit(0)
if current_hash and last_hash == current_hash and gate_status == "infrastructure_blocked":
    print("SKIP_BLOCKED")
    raise SystemExit(0)

state["plan_current_hash"] = current_hash
if current_hash and last_hash and current_hash != last_hash and gate_status != "pending":
    state["plan_gate_status"] = "pending"
    state["plan_approved"] = False
    state["updated_at"] = datetime.datetime.utcnow().isoformat() + "Z"
    with open(state_path, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)
    print("RESET_FOR_NEW_HASH")
PYEOF
}

STATE_PLAN_GUARD="$(prepare_state_for_plan_hash 2>/dev/null || true)"
case "$STATE_PLAN_GUARD" in
  SKIP_APPROVED)
    echo "[JEO][PLAN] plan gate already approved for current plan hash — skipping re-entry." >&2
    exit 0
    ;;
  SKIP_FEEDBACK)
    echo "[JEO][PLAN] feedback already recorded for current plan hash — revise the plan before re-opening plannotator." >&2
    exit 10
    ;;
  SKIP_BLOCKED)
    echo "[JEO][PLAN] infrastructure-blocked state already recorded for current plan hash — waiting for manual approval path." >&2
    exit 32
    ;;
  RESET_FOR_NEW_HASH)
    echo "[JEO][PLAN] detected revised plan content — resetting gate status to pending." >&2
    ;;
esac

manual_fallback_gate() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    return 32
  fi

  echo "[JEO][PLAN] plannotator UI를 열 수 없는 환경입니다. 수동 PLAN gate로 전환합니다." >&2
  echo "[JEO][PLAN] 선택: [a]pprove / [f]eedback / [s]top" >&2
  read -r -p "선택하세요 [a/f/s]: " choice

  case "${choice,,}" in
    a|approve)
      write_manual_feedback_json "true" "manual-approve (fallback gate)"
      persist_plan_state "manual_approved" "true" "manual" "$FEEDBACK_FILE"
      echo "[JEO][PLAN] manual approved=true" >&2
      return 0
      ;;
    f|feedback)
      read -r -p "피드백 내용을 입력하세요: " fb
      write_manual_feedback_json "false" "${fb:-manual-feedback (fallback gate)}"
      persist_plan_state "feedback_required" "false" "manual" "$FEEDBACK_FILE"
      echo "[JEO][PLAN] manual approved=false (feedback)" >&2
      return 10
      ;;
    s|stop|n|no)
      echo "[JEO][PLAN] user requested PLAN stop." >&2
      return 30
      ;;
    *)
      echo "[JEO][PLAN] invalid choice. stopping PLAN." >&2
      return 31
      ;;
  esac
}

probe_local_listen() {
  if command -v node >/dev/null 2>&1; then
    node -e "const http=require('http');const s=http.createServer(()=>{});s.on('error',()=>process.exit(1));s.listen({host:'127.0.0.1',port:0},()=>s.close(()=>process.exit(0)));" >/dev/null 2>&1
    return $?
  fi
  return 0
}

# Some sandboxes disallow localhost bind(). In that environment plannotator hook mode cannot run.
if [[ "${JEO_SKIP_LISTEN_PROBE:-0}" != "1" ]]; then
  if ! probe_local_listen; then
    echo "[JEO][PLAN] localhost bind probe failed (listen not permitted)." >&2
    set +e
    manual_fallback_gate
    probe_rc=$?
    set -e
    if [[ "$probe_rc" -eq 32 ]]; then
      write_state_gate_status "infrastructure_blocked"
    fi
    exit "$probe_rc"
  fi
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
    persist_plan_state "approved" "true" "plannotator" "$FEEDBACK_FILE"
    exit 0
  fi

  if [[ "$rc" -eq 10 ]]; then
    echo "[JEO][PLAN] approved=false (feedback)"
    persist_plan_state "feedback_required" "false" "plannotator" "$FEEDBACK_FILE"
    exit 10
  fi

  if grep -Eiq "$PORT_ERROR_REGEX" "$FEEDBACK_FILE"; then
    echo "[JEO][PLAN] plannotator server bind failure detected (EADDRINUSE/EPERM)." >&2
    set +e
    manual_fallback_gate
    fallback_rc=$?
    set -e
    if [[ "$fallback_rc" -eq 32 ]]; then
      write_state_gate_status "infrastructure_blocked"
    fi
    exit "$fallback_rc"
  fi

  echo "[JEO][PLAN] session ended unexpectedly (attempt ${attempt}/${MAX_RESTARTS}). restarting..." >&2
  ((attempt++))
done

echo "[JEO][PLAN] plannotator session ended ${MAX_RESTARTS} times." >&2
set +e
manual_fallback_gate
fallback_rc=$?
set -e
if [[ "$fallback_rc" -eq 32 ]]; then
  echo "[JEO][PLAN] confirmation required. stop and ask user whether to continue PLAN." >&2
  write_state_gate_status "infrastructure_blocked"
fi
exit "$fallback_rc"
