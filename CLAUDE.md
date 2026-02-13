# Agent Skills - Full Multi-Agent Workflow

> 이 문서는 현재 MCP 환경에 맞춰 자동 생성되었습니다.
> Generated: 2026-01-28 | Workflow: full-multiagent | Preset: balanced

---

## CRITICAL: 매 프롬프트마다 OpenContext 자동 실행

**모든 프롬프트 시작 시 아래 단계를 반드시 수행하세요:**

### 1. 프롬프트 시작 시 (자동 컨텍스트 로드)
```bash
# MCP Tool 사용 (자동)
oc_manifest folder="[project-folder]" --limit 10

# 또는 관련 문서 검색
oc_search "현재 작업과 관련된 키워드"
```

### 2. 작업 완료 시 (결론 저장)
```bash
# 중요한 결정사항/결론이 있을 때
oc_create_doc folder="[project-folder]" title="[날짜]-[주제].md" description="결론 내용"
```

### 3. 프로젝트 폴더 설정 (최초 1회)
```bash
# 프로젝트 전용 폴더 생성
oc_folder_create folder="my-project" description="프로젝트 설명"
```

### OpenContext 자동화 규칙
| 시점 | 액션 | MCP Tool |
|------|------|----------|
| **프롬프트 시작** | 프로젝트 컨텍스트 로드 | `oc_manifest` 또는 `oc_search` |
| **불확실할 때** | 기존 결론/문서 검색 | `oc_search` |
| **작업 완료** | 결정사항/교훈 저장 | `oc_create_doc` |
| **참조 필요** | 안정적 링크 생성 | `oc_get_link` |

---

## Agent Roles & Status

| Agent | Role | Status | Best For |
|-------|------|--------|----------|
| **Claude Code** | Orchestrator | ✅ Integrated | 계획 수립, 코드 생성, 스킬 해석 |
| **Gemini-CLI** | Analyst | ✅ Integrated | 대용량 분석 (1M+ 토큰), 리서치, 코드 리뷰 |
| **Codex-CLI** | Executor | ✅ Integrated | 명령 실행, 빌드, 배포, Docker/K8s |
| **OpenContext** | Memory | ✅ Integrated | 영구 컨텍스트 저장, 프로젝트 문서 관리 |
| **ohmg** | Orchestrator | ✅ Integrated | Multi-agent orchestration, Serena Memory |

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
| `orchestration/` | ohmg (Multi-agent orchestration) |

### Skill Query (Token-Optimized)
\`\`\`bash
gemini-skill "API 설계해줘"           # toon mode (95% 절감)
gemini-skill "query" compact          # compact mode (88% 절감)
gemini-skill "query" full             # 상세 모드
\`\`\`

## OpenContext (Persistent Memory)

프로젝트 문서와 컨텍스트를 영구 저장하고 검색할 수 있습니다.

### MCP Tools 전체 목록
```bash
oc_list_folders    # 폴더 목록 조회
oc_list_docs       # 문서 목록 조회
oc_manifest        # 매니페스트 생성 (AI가 읽을 파일 목록)
oc_search          # 문서 검색
oc_create_doc      # 문서 생성
oc_set_doc_desc    # 문서 설명 업데이트
oc_folder_create   # 폴더 생성
oc_get_link        # 안정적 링크 생성
oc_resolve         # stable link 해석
oc_index_status    # 인덱스 상태 확인
```

### 매 프롬프트 워크플로우
```bash
# 1. 작업 시작 - 컨텍스트 로드
oc_manifest folder="project-name" --limit 10
# 또는
oc_search query="현재 작업 키워드"

# 2. 작업 중 - 필요시 검색
oc_search query="API 설계 패턴"

# 3. 작업 완료 - 결론 저장
oc_create_doc folder="project-name" title="결론-제목.md" description="중요 결론 내용"
```

### 프로젝트 초기 설정
```bash
# 새 프로젝트 폴더 생성
oc_folder_create folder="my-project" description="프로젝트 설명"

# 하위 폴더 구조 생성 (권장)
oc_folder_create folder="my-project/decisions" description="결정사항 기록"
oc_folder_create folder="my-project/pitfalls" description="발견된 함정/주의사항"
oc_folder_create folder="my-project/api" description="API 스펙 및 계약"
```

### 컨텍스트 저장 위치
```
~/.opencontext/contexts/
├── .ideas/inbox/     # 아이디어 저장소
└── [project-name]/   # 프로젝트별 문서
    ├── decisions/    # 결정사항
    ├── pitfalls/     # 함정/주의사항
    └── api/          # API 스펙
```

### 검색 활성화 (시맨틱 검색용)
```bash
# CLI로 설정
oc config set EMBEDDING_API_KEY "your-openai-key"
oc index build
```

---
**Version**: 3.2.0 | **Generated**: 2026-01-28
