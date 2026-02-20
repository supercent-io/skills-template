#!/usr/bin/env bash
# vibe-kanban-start.sh — Vibe Kanban 빠른 시작 스크립트
# 사용법: bash scripts/vibe-kanban-start.sh [--port PORT] [--remote]
#
# 사전 조건:
#   - Node.js / npm 설치
#   - 원하는 에이전트 CLI 인증 완료 (claude, codex, gemini 등)
set -euo pipefail

# ─── 인수 파싱 ──────────────────────────────────────────────────────────────
PORT=""
REMOTE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --port) PORT="$2"; shift 2 ;;
    --remote) REMOTE=true; shift ;;
    -h|--help)
      echo "사용법: $0 [--port PORT] [--remote]"
      echo "  --port PORT   서버 포트 지정 (기본: 자동)"
      echo "  --remote      원격 접속 모드 (HOST=0.0.0.0)"
      exit 0
      ;;
    *) echo "알 수 없는 옵션: $1"; exit 1 ;;
  esac
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Vibe Kanban 시작"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── 전제 조건 확인 ───────────────────────────────────────────────────────────
if ! command -v node &>/dev/null; then
  echo "❌ Node.js가 설치되어 있지 않습니다."
  echo "   설치: https://nodejs.org/"
  exit 1
fi

if ! command -v npx &>/dev/null; then
  echo "❌ npx가 설치되어 있지 않습니다. npm을 업데이트하세요."
  exit 1
fi

# 에이전트 CLI 확인 (경고만, 오류 아님)
echo ""
echo "📋 에이전트 CLI 상태 확인..."
for CLI in claude codex gemini; do
  if command -v "$CLI" &>/dev/null; then
    echo "  ✅ $CLI — 설치됨"
  else
    echo "  ⚠️  $CLI — 미설치 (해당 에이전트 사용 불가)"
  fi
done
echo ""

# ─── 환경 변수 설정 ───────────────────────────────────────────────────────────
ENV_VARS=()

if [[ -n "$PORT" ]]; then
  export PORT="$PORT"
  ENV_VARS+=("PORT=$PORT")
  echo "  🔌 포트: $PORT"
fi

if [[ "$REMOTE" == "true" ]]; then
  export HOST="0.0.0.0"
  ENV_VARS+=("HOST=0.0.0.0")
  echo "  🌐 원격 모드 활성화 (HOST=0.0.0.0)"
  echo "     외부 접근 허용 설정: VK_ALLOWED_ORIGINS 환경 변수를 설정하세요."
  echo "     예: export VK_ALLOWED_ORIGINS=https://your-domain.com"
fi

# .env 파일이 있으면 로드
if [[ -f ".env" ]]; then
  echo "  📄 .env 파일 로드"
  set -a; source .env; set +a
fi

echo ""
echo "🚀 Vibe Kanban 실행 중..."
echo "   브라우저가 자동으로 열립니다."
echo "   종료: Ctrl+C"
echo ""

# ─── 실행 ────────────────────────────────────────────────────────────────────
if [[ ${#ENV_VARS[@]} -gt 0 ]]; then
  env "${ENV_VARS[@]}" npx vibe-kanban
else
  npx vibe-kanban
fi
