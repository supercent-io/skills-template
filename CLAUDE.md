# Agent Skills - Full Multi-Agent Workflow

> 이 문서는 현재 MCP 환경에 맞춰 자동 생성되었습니다.
> Generated: 2026-01-13 | Workflow: full-multiagent | Preset: balanced

## Agent Roles & Status

| Agent | Role | Status | Best For |
|-------|------|--------|----------|
| **Claude Code** | Orchestrator | ✅ Integrated | 계획 수립, 코드 생성, 스킬 해석 |
| **Gemini-CLI** | Analyst | ✅ Integrated | 대용량 분석 (1M+ 토큰), 리서치, 코드 리뷰 |
| **Codex-CLI** | Executor | ✅ Integrated | 명령 실행, 빌드, 배포, Docker/K8s |

## Model Configuration (balanced)

| Role | Provider | Model | Use Case |
|------|----------|-------|----------|
| **Orchestrator** | claude | `claude-opus-4-5-20251101` | 계획 수립, 코드 생성 |
| **Analyst** | gemini | `gemini-3-pro` | 대용량 분석, 리서치 |
| **Executor** | openai | `gpt-5.2-codex` | 명령 실행, 빌드 |

### Claude Task Tool Model Hints
```
# Task tool에서 model 파라미터 사용
orchestrator tasks → model: "opus" (고성능) or "sonnet" (균형)
analyst tasks     → model: "sonnet" (or gemini-cli ask-gemini)
executor tasks    → model: "haiku" (빠름) (or codex-cli shell)
```

## Full Multi-Agent Workflow

### Orchestration Pattern
```
[Claude] 계획 수립 → [Gemini] 분석/리서치 → [Claude] 코드 작성 → [Codex] 실행/테스트 → [Claude] 결과 종합
```

### Example: API 설계 + 구현 + 테스트
1. **[Claude]** 스킬 기반 API 스펙 설계
2. **[Gemini]** `ask-gemini "@src/ 기존 API 패턴 분석"` - 대용량 코드베이스 분석
3. **[Claude]** 분석 결과 기반 코드 구현
4. **[Codex]** `shell "npm test && npm run build"` - 테스트 및 빌드
5. **[Claude]** 최종 리포트 생성

### MCP Tools Usage
```bash
# Gemini: 대용량 분석
ask-gemini "전체 코드베이스 구조 분석해줘"
ask-gemini "@src/ @tests/ 테스트 커버리지 분석"

# Codex: 명령 실행
shell "docker-compose up -d"
shell "kubectl apply -f deployment.yaml"
```

## Available Skills

| Category | Description |
|----------|-------------|
| `backend/` | API 설계, DB 스키마, 인증 |
| `frontend/` | UI 컴포넌트, 상태 관리 |
| `code-quality/` | 코드 리뷰, 디버깅, 테스트 |
| `infrastructure/` | 배포, 모니터링, 보안 |
| `documentation/` | 기술 문서, API 문서 |
| `utilities/` | Git, 환경 설정 |

### Skill Query (Token-Optimized)
```bash
gemini-skill "API 설계해줘"           # toon mode (95% 절감)
gemini-skill "query" compact          # compact mode (88% 절감)
gemini-skill "query" full             # 상세 모드
```

---
**Version**: 3.0.0 | **Generated**: $(date +%Y-%m-%d)
