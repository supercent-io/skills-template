# Agent Skills

> AI 에이전트를 위한 모듈식 스킬 시스템
> **69개 스킬** | **토큰 95% 절감** | **TOON 포맷 기본 적용**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-69-green.svg)](.agent-skills/)
[![Token](https://img.shields.io/badge/Token%20Savings-95%25-success.svg)](.agent-skills/scripts/generate_compact_skills.py)

![Agent Skills](AgentSkills.png)

---

## 설치 방법

### NPX를 사용한 스킬 설치 (권장)

```bash
# 전체 스킬 한번에 설치 (68개)
npx skills add https://github.com/supercent-io/skills-template --skill \
  agent-configuration \
  agent-evaluation \
  agent-workflow \
  agentic-development-principles \
  agentic-principles \
  agentic-workflow \
  prompt-repetition \
  subagent-creation \
  superwork \
  api-design \
  api-documentation \
  authentication-setup \
  backend-testing \
  database-schema-design \
  code-refactoring \
  code-review \
  debugging \
  performance-optimization \
  testing-strategies \
  image-generation-mcp \
  remotion-video-production \
  changelog-maintenance \
  pptx-presentation-builder \
  technical-writing \
  user-guide-writing \
  frontend-design-system \
  vercel-react-best-practices \
  responsive-design \
  state-management \
  ui-component-patterns \
  web-accessibility \
  web-design-guidelines \
  deployment-automation \
  firebase-ai-logic \
  looker-studio-bigquery \
  monitoring-observability \
  security-best-practices \
  system-environment-setup \
  marketing-skills-collection \
  sprint-retrospective \
  standup-meeting \
  task-estimation \
  task-planning \
  codebase-search \
  data-analysis \
  log-analysis \
  pattern-detection \
  advanced-skill-template \
  basic-skill-template \
  environment-setup \
  file-organization \
  git-submodule \
  git-workflow \
  kling-ai \
  mcp-codex-integration \
  npm-git-install \
  opencode-authentication \
  opencontext \
  skill-standardization \
  vercel-deploy \
  workflow-automation
```

### 개별 스킬 설치

```bash
# 특정 스킬만 설치
npx skills add https://github.com/supercent-io/skills-template --skill api-design
npx skills add https://github.com/supercent-io/skills-template --skill code-review

# 카테고리별 설치
npx skills add https://github.com/supercent-io/skills-template --category backend
npx skills add https://github.com/supercent-io/skills-template --category frontend
```

---

## 스킬 개요 (69개)

| Category | Count | Skills |
|:---------|:-----:|:-------|
| **Backend** | 6 | `api-design` `database-schema-design` `authentication-setup` `backend-testing` `kling-ai` `cs-tool-dashboard` |
| **Frontend** | 6 | `ui-component-patterns` `state-management` `responsive-design` `web-accessibility` `web-design-guidelines` `react-best-practices` |
| **Code-Quality** | 6 | `code-review` `code-refactoring` `testing-strategies` `performance-optimization` `debugging` `agent-evaluation` |
| **Infrastructure** | 8 | `system-environment-setup` `deployment-automation` `monitoring-observability` `security-best-practices` `firebase-ai-logic` `looker-studio-bigquery` `agent-configuration` `vercel-deploy` |
| **Documentation** | 4 | `technical-writing` `api-documentation` `user-guide-writing` `changelog-maintenance` |
| **Project-Mgmt** | 8 | `task-planning` `task-estimation` `sprint-retrospective` `standup-meeting` `ultrathink-multiagent-workflow` `subagent-creation` `agentic-principles` `superwork` |
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

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Version**: 4.2.0 | **Updated**: 2026-01-28 | **Skills**: 69 | **Format**: TOON (Default)

**Changelog v4.2.0**:
- **superwork 스킬 추가**: Opus extended thinking 활용 분석/종합/의사결정 에이전트
- **spw 별칭 지원**: `superwork`, `spw`, `super-work`, `opus-work` 키워드로 호출 가능

**Changelog v4.0.0**:
- **설치 방식 변경**: `npx skills add` 포맷으로 통일
- **TOON 포맷 기본 적용**: 토큰 95% 절감
- **compact 파일 제거**: TOON으로 통합
- **README 간소화**: 핵심 내용만 유지
