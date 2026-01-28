# Agent Skills Repository

AI 에이전트를 위한 모듈식 스킬 모음입니다. Claude, Gemini, ChatGPT 등 모든 AI 플랫폼에서 사용 가능합니다.

---

## 설치

### NPX를 사용한 설치 (권장)

```bash
# 전체 스킬 설치
npx skills add https://github.com/supercent-io/skills-template

# 특정 스킬만 설치
npx skills add https://github.com/supercent-io/skills-template --skill api-design

# 카테고리별 설치
npx skills add https://github.com/supercent-io/skills-template --category backend
```

### AI 에이전트 프롬프트

```
https://github.com/supercent-io/skills-template 저장소에서 .agent-skills 폴더를
현재 프로젝트로 복사해줘.
```

---

## 폴더 구조

```
.agent-skills/
├── README.md                      # 이 파일
├── skill_loader.py                # 스킬 로더
├── skill-query-handler.py         # 자연어 쿼리 처리
├── skills.json                    # 스킬 매니페스트 (자동 생성)
├── skills.toon                    # TOON 요약 (자동 생성)
│
├── agent-develop/                 # 에이전트 개발 (10)
├── backend/                       # 백엔드 (6)
├── frontend/                      # 프론트엔드 (7)
├── code-quality/                  # 코드 품질 (5)
├── infrastructure/                # 인프라 (6)
├── documentation/                 # 문서화 (4)
├── project-management/            # 프로젝트 관리 (4)
├── search-analysis/               # 검색/분석 (4)
├── creative-media/                # 크리에이티브 (2)
├── marketing/                     # 마케팅 (1)
├── utilities/                     # 유틸리티 (10)
│
├── templates/                     # 스킬 템플릿
│   ├── toon-skill-template/       # TOON 포맷 (기본)
│   ├── basic-skill-template/
│   └── advanced-skill-template/
│
└── scripts/
    └── generate_compact_skills.py # 스킬 생성 도구
```

---

## 스킬 목록

### Agent Develop (10)
| Skill | Description |
|-------|-------------|
| `agent-configuration` | AI 에이전트 설정 정책 |
| `agent-evaluation` | AI 에이전트 평가 |
| `agent-workflow` | 멀티 에이전트 워크플로우 |
| `agentic-development-principles` | 에이전틱 개발 원칙 |
| `agentic-principles` | AI 에이전트 협업 원칙 |
| `agentic-workflow` | AI 에이전트 워크플로우 |
| `prompt-repetition` | 프롬프트 반복 감지 |
| `subagent-creation` | 서브에이전트 생성 |

### Backend (6)
| Skill | Description |
|-------|-------------|
| `api-design` | REST/GraphQL API 설계 |
| `api-documentation` | API 문서화 |
| `database-schema-design` | DB 스키마 설계 |
| `authentication-setup` | 인증/인가 구현 |
| `backend-testing` | 백엔드 테스트 전략 |

### Frontend (7)
| Skill | Description |
|-------|-------------|
| `ui-component-patterns` | UI 컴포넌트 패턴 |
| `state-management` | 상태 관리 |
| `responsive-design` | 반응형 디자인 |
| `web-accessibility` | 웹 접근성 |
| `web-design-guidelines` | 웹 디자인 가이드 |
| `design-system` | 디자인 시스템 |
| `react-best-practices` | React 모범 사례 |

### Code Quality (5)
| Skill | Description |
|-------|-------------|
| `code-review` | 코드 리뷰 |
| `code-refactoring` | 리팩토링 전략 |
| `testing-strategies` | 테스트 전략 |
| `performance-optimization` | 성능 최적화 |
| `debugging` | 디버깅 기법 |

### Infrastructure (6)
| Skill | Description |
|-------|-------------|
| `system-environment-setup` | 시스템 환경 설정 |
| `deployment-automation` | 배포 자동화 |
| `monitoring-observability` | 모니터링 설정 |
| `security-best-practices` | 보안 구성 |
| `firebase-ai-logic` | Firebase AI Logic |
| `looker-studio-bigquery` | Looker Studio + BigQuery |

### Documentation (4)
| Skill | Description |
|-------|-------------|
| `technical-writing` | 기술 문서 작성 |
| `user-guide-writing` | 사용자 가이드 |
| `changelog-maintenance` | 변경 이력 관리 |
| `presentation-builder` | 프레젠테이션 빌더 |

### Project Management (4)
| Skill | Description |
|-------|-------------|
| `task-planning` | 작업 계획 |
| `task-estimation` | 개발 시간 추정 |
| `sprint-retrospective` | 회고 진행 |
| `standup-meeting` | 스탠드업 준비 |

### Search & Analysis (4)
| Skill | Description |
|-------|-------------|
| `codebase-search` | 코드베이스 검색 |
| `log-analysis` | 로그 분석 |
| `data-analysis` | 데이터 분석 |
| `pattern-detection` | 패턴 감지 |

### Creative Media (2)
| Skill | Description |
|-------|-------------|
| `image-generation` | 이미지 생성 |
| `video-production` | 비디오 제작 |

### Marketing (1)
| Skill | Description |
|-------|-------------|
| `marketing-automation` | 마케팅 자동화 |

### Utilities (10)
| Skill | Description |
|-------|-------------|
| `git-workflow` | Git 워크플로우 |
| `git-submodule` | Git 서브모듈 관리 |
| `environment-setup` | 환경 설정 |
| `file-organization` | 파일 정리 |
| `workflow-automation` | 자동화 스크립트 |
| `skill-standardization` | 스킬 표준화 |
| `opencode-authentication` | OpenCode OAuth 인증 |
| `npm-git-install` | GitHub에서 npm 설치 |
| `opencontext` | OpenContext 메모리 관리 |
| `kling-ai` | Kling AI 비디오 생성 |
| `mcp-codex` | MCP Codex 통합 |
| `vercel-deploy` | Vercel 배포 |

---

## TOON 포맷 (기본)

모든 스킬은 **TOON 포맷**을 기본으로 사용합니다 (토큰 95% 절감).

| Mode | File | Avg Tokens | Reduction |
|:-----|:-----|:-----------|:----------|
| **full** | SKILL.md | ~2,118 | - |
| **toon** | SKILL.toon | ~111 | **94.7%** |

```bash
# 스킬 쿼리 (toon 모드 기본)
python3 skill-query-handler.py query "API 설계해줘"

# full 모드 지정
python3 skill-query-handler.py query "API 설계해줘" --mode full
```

---

## CLI 도구

### skill-query-handler.py

```bash
# 스킬 목록
python3 skill-query-handler.py list

# 쿼리 매칭
python3 skill-query-handler.py match "REST API"

# 프롬프트 생성
python3 skill-query-handler.py query "API 설계해줘"

# 통계 확인
python3 skill-query-handler.py stats
```

### skill_loader.py

```bash
# 스킬 목록
python3 skill_loader.py list

# 스킬 검색
python3 skill_loader.py search "api"

# 스킬 상세
python3 skill_loader.py show api-design
```

---

## 새 스킬 추가

### 1. 템플릿 복사

```bash
cp -r templates/toon-skill-template [category]/[skill-name]
```

### 2. SKILL.toon 수정

```
N:my-new-skill
D:스킬 설명 2-3문장
G:keyword1 keyword2

U[3]:
  사용 사례 1
  사용 사례 2
  사용 사례 3

S[4]{n,action,details}:
  1,분석,사용자 요청 이해
  2,계획,접근 방식 수립
  3,실행,단계별 구현
  4,검증,결과 확인

R[2]:
  모범 사례 1
  모범 사례 2
```

### 3. 매니페스트 업데이트

```bash
python3 scripts/generate_compact_skills.py
```

---

## 추가 스킬 탐색

더 많은 AI 에이전트 스킬을 찾고 계신가요?

**[skills.sh](https://skills.sh/)** 에서 커뮤니티가 만든 다양한 스킬을 탐색하고 설치할 수 있습니다.

```bash
# skills.sh에서 스킬 검색
npx skills search "code review"

# skills.sh에서 스킬 설치
npx skills add <skill-name>
```

---

**Version**: 4.0.0 | **Updated**: 2026-01-28 | **Format**: TOON (Default)
