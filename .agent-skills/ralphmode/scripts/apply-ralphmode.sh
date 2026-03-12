#!/usr/bin/env bash
# Ralphmode — Apply permission preset for ralph/jeo automation
# Usage: bash apply-ralphmode.sh [--mode repo|sandbox] [--target project|global] [--dry-run] [--status]
#
# --mode repo      Repo-scoped preset: acceptEdits + denylist (default)
# --mode sandbox   Full bypass: bypassPermissions (disposable environments only)
# --target project Apply to .claude/settings.json in current repo (default)
# --target global  Apply to ~/.claude/settings.json (use with caution)
# --dry-run        Show what would be changed without writing
# --status         Show current ralphmode configuration and exit

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
err()  { echo -e "${RED}✗${NC} $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

MODE="repo"
TARGET="project"
DRY_RUN=false
STATUS_ONLY=false

for arg in "$@"; do
  case $arg in
    --mode=*) MODE="${arg#*=}" ;;
    --mode) shift; MODE="$1" ;;
    --target=*) TARGET="${arg#*=}" ;;
    --target) shift; TARGET="$1" ;;
    --dry-run) DRY_RUN=true ;;
    --status) STATUS_ONLY=true ;;
  esac
done

# ── Validate ──────────────────────────────────────────────────────────────────
if [[ "$MODE" != "repo" && "$MODE" != "sandbox" ]]; then
  err "Invalid mode: $MODE (use 'repo' or 'sandbox')"
  exit 1
fi
if [[ "$TARGET" != "project" && "$TARGET" != "global" ]]; then
  err "Invalid target: $TARGET (use 'project' or 'global')"
  exit 1
fi

# ── Determine config path ─────────────────────────────────────────────────────
if [[ "$TARGET" == "global" ]]; then
  SETTINGS_PATH="$HOME/.claude/settings.json"
else
  if git rev-parse --git-dir >/dev/null 2>&1; then
    GIT_ROOT=$(git rev-parse --show-toplevel)
    SETTINGS_PATH="$GIT_ROOT/.claude/settings.json"
  else
    SETTINGS_PATH="$(pwd)/.claude/settings.json"
  fi
fi

HOOK_PATH="$HOME/.claude/hooks/ralph-safety-check.sh"

echo ""
echo "Ralphmode — Permission Profile Setup"
echo "====================================="
echo "  mode:   $MODE"
echo "  target: $TARGET → $SETTINGS_PATH"
echo ""

# ── Status mode ───────────────────────────────────────────────────────────────
if $STATUS_ONLY; then
  info "Current configuration:"
  if [[ -f "$SETTINGS_PATH" ]]; then
    python3 -c "
import json, sys
try:
    d = json.load(open('$SETTINGS_PATH'))
    p = d.get('permissions', d.get('permissionMode', None))
    if p:
        print(f'  permissions: {json.dumps(p, indent=4)}')
    else:
        print('  No permissions key found')
    rm = d.get('ralphmode_active', False)
    print(f'  ralphmode_active: {rm}')
except Exception as e:
    print(f'  Error reading: {e}')
"
  else
    warn "Config file not found: $SETTINGS_PATH"
  fi

  if [[ -f "$HOOK_PATH" ]]; then
    ok "Safety hook: $HOOK_PATH"
  else
    warn "Safety hook missing: $HOOK_PATH"
  fi

  # Check global settings for PreToolUse hook
  GLOBAL_SETTINGS="$HOME/.claude/settings.json"
  if [[ -f "$GLOBAL_SETTINGS" ]]; then
    python3 -c "
import json, sys
try:
    d = json.load(open('$GLOBAL_SETTINGS'))
    hooks = d.get('hooks', {})
    pre = hooks.get('PreToolUse', [])
    has_hook = any('ralph-safety-check' in str(e) for e in pre)
    print('✓ PreToolUse hook registered' if has_hook else '⚠  PreToolUse hook NOT registered in ~/.claude/settings.json')
except Exception as e:
    print(f'Error: {e}')
" 2>/dev/null || true
  fi
  exit 0
fi

# ── Build the preset JSON ──────────────────────────────────────────────────────
if [[ "$MODE" == "sandbox" ]]; then
  PERMISSIONS_JSON='{
    "defaultMode": "bypassPermissions"
  }'
  PROFILE_DESC="sandbox (bypassPermissions — disposable environments only)"
else
  PERMISSIONS_JSON='{
    "defaultMode": "acceptEdits",
    "allow": [
      "Bash(npm *)",
      "Bash(pnpm *)",
      "Bash(bun *)",
      "Bash(yarn *)",
      "Bash(python3 *)",
      "Bash(pytest *)",
      "Bash(git status)",
      "Bash(git diff)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git log *)",
      "Bash(git branch *)",
      "Bash(git checkout *)",
      "Bash(git push)",
      "Bash(git pull)",
      "Read(*)",
      "Edit(*)",
      "Write(*)"
    ],
    "deny": [
      "Read(.env*)",
      "Read(./secrets/**)",
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)"
    ]
  }'
  PROFILE_DESC="repo-scoped (acceptEdits + deny-list)"
fi

# ── Show what will change ──────────────────────────────────────────────────────
if $DRY_RUN; then
  warn "[DRY-RUN] Would write to: $SETTINGS_PATH"
  echo "  Profile: $PROFILE_DESC"
  echo "  Permissions: $PERMISSIONS_JSON"
  echo ""
  warn "[DRY-RUN] Would ensure safety hook: $HOOK_PATH"
  exit 0
fi

# ── Apply settings ─────────────────────────────────────────────────────────────
info "Applying $PROFILE_DESC profile..."

mkdir -p "$(dirname "$SETTINGS_PATH")"

python3 - <<PYEOF
import json, os, sys

settings_path = '$SETTINGS_PATH'
permissions_json = '''$PERMISSIONS_JSON'''

try:
    existing = json.loads(open(settings_path).read()) if os.path.exists(settings_path) else {}
except Exception:
    existing = {}

# Backup ralphmode metadata
existing['_ralphmode_previous_permissions'] = existing.get('permissions', None)
existing['permissions'] = json.loads(permissions_json)

with open(settings_path, 'w') as f:
    json.dump(existing, f, ensure_ascii=False, indent=2)

print(f'✓ Applied to {settings_path}')
PYEOF

ok "Profile written: $SETTINGS_PATH"

# ── Ensure safety hook ────────────────────────────────────────────────────────
info "Checking safety hook..."
mkdir -p "$(dirname "$HOOK_PATH")"

if [[ ! -f "$HOOK_PATH" ]]; then
  cat > "$HOOK_PATH" << 'HOOKEOF'
#!/usr/bin/env bash
# Blocks Tier 1 dangerous commands during ralph/jeo runs.
# Reads tool input from CLAUDE_TOOL_INPUT env var (JSON).
CMD=$(echo "$CLAUDE_TOOL_INPUT" | python3 -c \
  "import sys,json; print(json.load(sys.stdin).get('command',''))" 2>/dev/null)
TIER1='(rm[[:space:]]+-rf|git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+push.*--force|DROP[[:space:]]+TABLE|[[:space:]]sudo[[:space:]]|chmod[[:space:]]+777|\.env|secrets/)'
if echo "$CMD" | grep -qE "$TIER1"; then
  echo "BLOCKED: Tier 1 dangerous command detected." >&2
  echo "Command: $CMD" >&2
  echo "Approve manually or remove the dangerous flag before retrying." >&2
  exit 2
fi
HOOKEOF
  chmod +x "$HOOK_PATH"
  ok "Created safety hook: $HOOK_PATH"
else
  ok "Safety hook already exists: $HOOK_PATH"
fi

# ── Check PreToolUse hook registration ───────────────────────────────────────
GLOBAL_SETTINGS="$HOME/.claude/settings.json"
python3 - <<PYEOF
import json, os

settings_path = '$GLOBAL_SETTINGS'
hook_path = '$HOOK_PATH'

try:
    s = json.loads(open(settings_path).read()) if os.path.exists(settings_path) else {}
except Exception:
    s = {}

hooks = s.get('hooks', {})
pre = hooks.get('PreToolUse', [])
has_hook = any('ralph-safety-check' in str(e) for e in pre)

if has_hook:
    print('✓ PreToolUse hook already registered in ~/.claude/settings.json')
else:
    print('⚠  PreToolUse hook not registered in ~/.claude/settings.json')
    print(f'   To register, add to ~/.claude/settings.json:')
    print('''   "hooks": {
     "PreToolUse": [{
       "matcher": "Bash",
       "hooks": [{
         "type": "command",
         "command": "bash \\"${HOME}/.claude/hooks/ralph-safety-check.sh\\"",
         "timeout": 30
       }]
     }]
   }''')
PYEOF

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "Ralphmode activated:"
echo "  Profile:  $PROFILE_DESC"
echo "  Config:   $SETTINGS_PATH"
echo "  Hook:     $HOOK_PATH"
echo ""
echo "To revert:"
if [[ "$MODE" == "sandbox" ]]; then
  echo "  python3 -c \"import json; s=json.load(open('$SETTINGS_PATH')); s.pop('permissions', None); s.pop('_ralphmode_previous_permissions', None); json.dump(s, open('$SETTINGS_PATH','w'), indent=2)\""
else
  echo "  rm -f $SETTINGS_PATH  (removes project-local permissions)"
fi
echo ""
ok "Ralphmode setup complete. Restart Claude Code to apply permission changes."
echo ""
