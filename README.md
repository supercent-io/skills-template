# Agent Skills

> AI 에이전트를 위한 모듈식 스킬 시스템
> **55개 스킬** | **토큰 95% 절감** | **TOON 포맷 기본 적용**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-55-green.svg)](.agent-skills/)
[![Token](https://img.shields.io/badge/Token%20Savings-95%25-success.svg)](.agent-skills/scripts/generate_compact_skills.py)

![Agent Skills](AgentSkills.png)

---

## 설치 방법

### NPX를 사용한 스킬 설치 (권장)

```bash
# 전체 스킬 설치
npx skills add https://github.com/supercent-io/skills-template

# 특정 스킬만 설치
npx skills add https://github.com/supercent-io/skills-template --skill api-design
npx skills add https://github.com/supercent-io/skills-template --skill code-review
npx skills add https://github.com/supercent-io/skills-template --skill database-schema-design

# 카테고리별 설치
npx skills add https://github.com/supercent-io/skills-template --category backend
npx skills add https://github.com/supercent-io/skills-template --category frontend
```

### 수동 설치

```bash
# 1. 저장소 클론
git clone https://github.com/supercent-io/skills-template.git

# 2. 프로젝트에 스킬 복사
cp -r skills-template/.agent-skills your-project/

# 3. 정리
rm -rf skills-template
```

### AI 에이전트 프롬프트로 설치

Claude Code, Gemini, ChatGPT 등에게 아래 프롬프트를 복사-붙여넣기하세요:

```
https://github.com/supercent-io/skills-template 저장소에서 .agent-skills 폴더를
현재 프로젝트로 복사해줘.
```

---

## 스킬 사용법

### CLI로 스킬 조회

```bash
# 자연어로 스킬 검색
python3 .agent-skills/skill-query-handler.py query "API 설계해줘"

# 스킬 목록 확인
python3 .agent-skills/skill_loader.py list

# 토큰 통계 확인
python3 .agent-skills/skill-query-handler.py stats
```

### AI 에이전트 프롬프트 예제

| 목적 | 프롬프트 |
|------|----------|
| **스킬 검색** | `"API 설계" 관련 스킬을 찾아서 로드해줘` |
| **코드 리뷰** | `code-review 스킬을 사용해서 src/ 폴더를 리뷰해줘` |
| **DB 스키마 설계** | `database-schema-design 스킬로 사용자 관리 시스템 스키마를 설계해줘` |
| **PPT 작성** | `presentation-builder 스킬로 투자자 발표 자료 10슬라이드로 만들어줘` |
| **Docker 배포** | `deployment-automation 스킬을 사용해서 Docker Compose 설정을 만들어줘` |

---

## 스킬 개요 (55개)

| Category | Count | Skills |
|:---------|:-----:|:-------|
| **Backend** | 6 | `api-design` `database-schema-design` `authentication-setup` `backend-testing` `kling-ai` `cs-tool-dashboard` |
| **Frontend** | 6 | `ui-component-patterns` `state-management` `responsive-design` `web-accessibility` `web-design-guidelines` `react-best-practices` |
| **Code-Quality** | 6 | `code-review` `code-refactoring` `testing-strategies` `performance-optimization` `debugging` `agent-evaluation` |
| **Infrastructure** | 8 | `system-environment-setup` `deployment-automation` `monitoring-observability` `security-best-practices` `firebase-ai-logic` `looker-studio-bigquery` `agent-configuration` `vercel-deploy` |
| **Documentation** | 4 | `technical-writing` `api-documentation` `user-guide-writing` `changelog-maintenance` |
| **Project-Mgmt** | 7 | `task-planning` `task-estimation` `sprint-retrospective` `standup-meeting` `ultrathink-multiagent-workflow` `subagent-creation` `agentic-principles` |
| **Search-Analysis** | 4 | `codebase-search` `log-analysis` `data-analysis` `pattern-detection` |
| **Utilities** | 14 | `git-workflow` `git-submodule` `environment-setup` `file-organization` `workflow-automation` `skill-standardization` `opencode-authentication` `npm-git-install` `project-init-memory` `agentic-workflow` `opencontext` `prompt-repetition` `agentic-development-principles` |

---

## TOON 포맷 (기본 적용)

스킬은 **TOON 포맷**을 기본으로 사용하여 토큰 사용량을 95% 절감합니다.

### TOON 포맷 구조

```
N:skill-name                           # 스킬 이름
D:Description in 2-3 sentences...      # 설명
G:keyword1 keyword2 keyword3           # 검색 키워드

U[5]:                                  # 사용 사례 (Use cases)
  Use case 1
  Use case 2
  ...

S[6]{n,action,details}:                # 실행 단계 (Steps)
  1,Analyze,Understand the request
  2,Plan,Create approach
  ...

R[5]:                                  # 규칙/모범 사례 (Rules)
  Best practice 1
  Best practice 2
  ...

E[2]{desc,in,out}:                     # 예제 (Examples)
  "Basic usage","Input","Output"
```

### 토큰 최적화 비교

| Mode | File | Avg Tokens | Reduction |
|:-----|:-----|:-----------|:----------|
| **full** | SKILL.md | ~2,198 | - |
| **toon** | SKILL.toon | ~112 | **94.9%** |

---

## 새 스킬 만들기

### 1. 템플릿 복사

```bash
cp -r .agent-skills/templates/toon-skill-template .agent-skills/[category]/[skill-name]
```

### 2. SKILL.toon 수정

```
N:my-new-skill
D:이 스킬이 하는 일과 언제 사용해야 하는지 2-3문장으로 설명합니다.
G:keyword1 keyword2 category-tag

U[5]:
  사용 사례 1
  사용 사례 2
  사용 사례 3
  사용 사례 4
  사용 사례 5

S[4]{n,action,details}:
  1,분석,사용자 요청 이해
  2,계획,접근 방식 수립
  3,실행,단계별 구현
  4,검증,결과 확인

R[3]:
  모범 사례 1
  모범 사례 2
  피해야 할 안티패턴

E[1]{desc,in,out}:
  "기본 사용법","입력 예시","출력 예시"
```

### 3. 스킬 매니페스트 업데이트

```bash
python3 .agent-skills/scripts/generate_compact_skills.py
```

---

## 아키텍처

```
.agent-skills/
├── skills.json              # 스킬 매니페스트 (자동 생성)
├── skills.toon              # 토큰 최적화 요약 (자동 생성)
├── skill_loader.py          # 스킬 로딩 코어
├── skill-query-handler.py   # 자연어 쿼리 처리
│
├── backend/                 # 백엔드 스킬
├── frontend/                # 프론트엔드 스킬
├── code-quality/            # 코드 품질 스킬
├── infrastructure/          # 인프라 스킬
├── documentation/           # 문서화 스킬
├── project-management/      # 프로젝트 관리 스킬
├── search-analysis/         # 검색/분석 스킬
├── utilities/               # 유틸리티 스킬
│
├── templates/               # 스킬 템플릿
│   ├── toon-skill-template/ # TOON 포맷 (기본)
│   ├── basic-skill-template/
│   └── advanced-skill-template/
│
└── scripts/                 # 유틸리티 스크립트
    └── generate_compact_skills.py
```

---

## Troubleshooting

### 스킬을 찾을 수 없는 경우

```bash
# 스킬 매칭 테스트
python3 .agent-skills/skill-query-handler.py match "API 설계"

# 스킬 목록 확인
python3 .agent-skills/skill_loader.py list
```

### Python 모듈 오류

```bash
cd .agent-skills && pip3 install -r requirements.txt
```

### 글로벌 설치 후 스킬을 찾지 못하는 경우

```bash
# 직접 경로 지정
python3 ~/.agent-skills/skill-query-handler.py query "API 설계"
```

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Version**: 4.0.0 | **Updated**: 2026-01-28 | **Skills**: 55 | **Format**: TOON (Default)

**Changelog v4.0.0**:
- **설치 방식 변경**: `npx skills add` 포맷으로 통일
- **TOON 포맷 기본 적용**: 토큰 95% 절감
- **compact 파일 제거**: TOON으로 통합
- **README 간소화**: 핵심 내용만 유지
