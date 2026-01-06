# Agent Skills - Multi-Agent Workflow

> 이 프로젝트는 Claude Code를 중심으로 Gemini-CLI와 Codex-CLI를 통합하는 Multi-Agent 시스템입니다.

## Agent Roles

| Agent | Role | MCP Tool | Best For |
|-------|------|----------|----------|
| **Claude Code** | Orchestrator | Built-in | 계획 수립, 코드 생성, 스킬 해석 |
| **Gemini-CLI** | Analyst | `ask-gemini` | 대용량 분석, 리서치, 코드 리뷰 |
| **Codex-CLI** | Executor | `shell` | 명령 실행, 빌드, 배포 |

## Multi-Agent Workflow

사용자 요청을 처리할 때 다음 패턴을 따르세요:

### 1. Skill-Based Task Routing

```
사용자 요청 → 스킬 매칭 → 적절한 에이전트 선택 → 실행
```

### 2. When to Use Each Agent

**Claude Code (기본)**:
- 코드 작성 및 수정
- 파일 읽기/쓰기
- 스킬 기반 작업 계획
- 직접 실행 가능한 모든 작업

**Gemini-CLI 사용 (`ask-gemini`)**:
- 대용량 코드베이스 분석 (1M+ 토큰)
- 복잡한 아키텍처 리서치
- 여러 파일 동시 분석
- 세컨드 오피니언 필요 시

**Codex-CLI 사용 (`shell`)**:
- 장시간 실행 명령 (빌드, 테스트)
- 위험할 수 있는 시스템 명령
- Docker, Kubernetes 작업
- Claude의 Bash 도구로 처리하기 어려운 경우

### 3. Skill Integration Pattern

스킬 파일 위치: `.agent-skills/` 또는 `.claude/skills/`

```bash
# 스킬 쿼리로 적합한 스킬 찾기
gemini-skill "API 설계해줘"  # → backend/api-design

# 토큰 최적화 모드 (기본: toon - 95% 절감)
gemini-skill "query"           # toon (최소)
gemini-skill "query" compact   # compact (88% 절감)
gemini-skill "query" full      # full (상세)
```

## Orchestration Examples

### Example 1: API 설계 + 구현

```
1. [Claude] 사용자 요청 분석, api-design 스킬 로드
2. [Claude] API 스펙 설계 및 코드 생성
3. [Codex] 테스트 실행: shell "npm test"
4. [Claude] 결과 분석 및 리포트
```

### Example 2: 대규모 코드 리뷰

```
1. [Claude] 리뷰 대상 파일 식별
2. [Gemini] 대용량 분석: ask-gemini "@src/ 전체 코드 품질 분석"
3. [Claude] 분석 결과 종합 및 개선점 도출
4. [Claude] 코드 수정 적용
```

### Example 3: 인프라 배포

```
1. [Claude] infrastructure 스킬 기반 계획 수립
2. [Claude] Terraform/Docker 설정 파일 생성
3. [Codex] 배포 실행: shell "terraform apply"
4. [Claude] 배포 결과 확인 및 문서화
```

## Available Skills

### Categories
- `backend/`: API 설계, DB 스키마, 인증, 테스트
- `frontend/`: UI 컴포넌트, 상태 관리, 접근성
- `code-quality/`: 코드 리뷰, 리팩토링, 디버깅
- `infrastructure/`: 배포, 모니터링, 보안
- `documentation/`: 기술 문서, API 문서
- `utilities/`: Git, 환경 설정, 워크플로우

### Skill Lookup
```bash
# 모든 스킬 목록
python3 .agent-skills/skill-query-handler.py list

# 스킬 매칭
python3 .agent-skills/skill-query-handler.py match "코드 리뷰"

# 스킬 기반 프롬프트 생성
python3 .agent-skills/skill-query-handler.py query "REST API 설계" --mode toon
```

## MCP Server Status

실행 중인 MCP 서버 확인:
```bash
claude mcp list
```

예상 출력:
```
gemini-cli: npx -y gemini-mcp-tool - Connected
codex-cli: npx -y @openai/codex-shell-tool-mcp - Connected
```

## Best Practices

1. **Skill-First**: 작업 전 관련 스킬 확인
2. **Token Optimization**: toon 모드 기본 사용 (95% 절감)
3. **Parallel Agents**: 독립적 작업은 병렬 처리
4. **Result Aggregation**: 여러 에이전트 결과 종합
5. **Error Handling**: 에이전트 실패 시 대체 전략

## Token Optimization

| Mode | File | Tokens | Reduction |
|------|------|--------|-----------|
| full | SKILL.md | ~2000 | - |
| compact | SKILL.compact.md | ~250 | 88% |
| toon | SKILL.toon | ~110 | 95% |

---

**Version**: 2.3.0 | **Updated**: 2026-01-06 | **Workflow**: Multi-Agent
