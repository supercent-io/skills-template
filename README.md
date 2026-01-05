# Agent Skills

> Claude, ChatGPT, Gemini, MCP 기반 CLI에서 사용 가능한 범용 AI 에이전트 스킬 시스템

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.x-blue.svg?logo=python)](https://www.python.org/)
[![Skills](https://img.shields.io/badge/Skills-34-green.svg)](.agent-skills/)
[![Platforms](https://img.shields.io/badge/Platforms-Claude%20%7C%20ChatGPT%20%7C%20Gemini%20%7C%20MCP-informational.svg)](https://agentskills.io/)
[![TOON](https://img.shields.io/badge/TOON-16.8%25%20Token%20Saved-orange.svg)](.agent-skills/skills.toon)

## Architecture

```mermaid
graph TB
    subgraph "Agent Skills System"
        AS[".agent-skills/"]
        SK["SKILL.md Files"]
        TN["skills.toon (TOON Format)"]
        SL["skill_loader.py"]
        SS["setup.sh"]
        ANS["add_new_skill.sh"]
    end

    subgraph "AI Platforms"
        CL["Claude Code"]
        GP["ChatGPT"]
        GM["Gemini"]
    end

    subgraph "MCP Integration"
        GC["gemini-cli"]
        CC["codex-cli"]
    end

    AS --> SK
    AS --> TN
    SK --> SL
    SK --> SS
    ANS --> SK

    SS --> CL
    SS --> GP
    SS --> GM
    SL --> GC
    SL --> CC

    style AS fill:#e1f5fe
    style TN fill:#fff3e0
    style CL fill:#a5d6a7
    style GP fill:#fff59d
    style GM fill:#ce93d8
    style GC fill:#ffab91
    style CC fill:#ffab91
```

## Features

| Feature | Description | Status |
|---------|-------------|--------|
| **Multi-Platform** | Claude, ChatGPT, Gemini, MCP 지원 | ✅ |
| **34 Skills** | 8개 카테고리의 실전 스킬 | ✅ |
| **TOON Format** | 16.8% 토큰 절감 포맷 | ✅ |
| **Open Standard** | Agent Skills 오픈 표준 준수 | ✅ |
| **Easy Setup** | `setup.sh` 원클릭 설정 | ✅ |
| **Auto Add Skill** | `add_new_skill.sh` 자동 스킬 생성 | ✅ |
| **MCP Integration** | gemini-cli, codex-cli 연동 | ✅ |

## Quick Start

```mermaid
flowchart LR
    A["1. Clone"] --> B["2. Run setup.sh"]
    B --> C{"Select Platform"}
    C -->|1| D["Claude"]
    C -->|2| E["ChatGPT"]
    C -->|3| F["Gemini"]
    C -->|6| G["MCP"]

    style A fill:#e3f2fd
    style B fill:#fff3e0
    style C fill:#fce4ec
    style D fill:#a5d6a7
    style E fill:#fff59d
    style F fill:#ce93d8
    style G fill:#ffab91
```

```bash
# 1. 저장소 클론
git clone https://github.com/your-org/skills-template.git
cd skills-template

# 2. 설정 스크립트 실행
cd .agent-skills && ./setup.sh

# 3. 플랫폼 선택 (1: Claude, 2: ChatGPT, 3: Gemini, 6: MCP Integration)
```

## Skills Overview

### Categories

```mermaid
pie showData
    title Skills by Category (34 Total)
    "Backend" : 5
    "Frontend" : 4
    "Code-Quality" : 4
    "Infrastructure" : 5
    "Documentation" : 4
    "Project-Mgmt" : 4
    "Search-Analysis" : 4
    "Utilities" : 5
```

### Detailed Skills

| Category | Count | Skills |
|:---------|:-----:|:-------|
| **Backend** | 5 | `api-design` `database-schema-design` `authentication-setup` `backend-testing` `toon-demo` |
| **Frontend** | 4 | `ui-component-patterns` `state-management` `responsive-design` `web-accessibility` |
| **Code-Quality** | 4 | `code-review` `code-refactoring` `testing-strategies` `performance-optimization` |
| **Infrastructure** | 5 | `system-environment-setup` `deployment-automation` `monitoring-observability` `security-best-practices` `firebase-ai-logic` |
| **Documentation** | 4 | `technical-writing` `api-documentation` `user-guide-writing` `changelog-maintenance` |
| **Project-Mgmt** | 4 | `task-planning` `task-estimation` `sprint-retrospective` `standup-meeting` |
| **Search-Analysis** | 4 | `codebase-search` `log-analysis` `data-analysis` `pattern-detection` |
| **Utilities** | 5 | `git-workflow` `environment-setup` `file-organization` `workflow-automation` `mcp-codex-integration` |

> **Total: 34 Skills**

## Token Optimization (TOON Format)

TOON (Token-Oriented Object Notation)은 LLM 토큰 사용량을 최적화하는 직렬화 포맷입니다.

```mermaid
graph LR
    A["JSON (Original)"] -->|toon_converter.py| B["TOON Format"]
    B -->|16.8% 절감| C["Reduced Tokens"]

    style A fill:#ffcdd2
    style B fill:#c8e6c9
    style C fill:#a5d6a7
```

### TOON 변환 예시

**Before (JSON)**:
```json
{"name": "api-design", "category": "backend", "description": "Design RESTful APIs"}
```

**After (TOON)**:
```
N:api-design C:backend D:Design RESTful APIs
```

### TOON CLI 사용

```bash
# 전체 스킬 TOON 변환
python3 scripts/toon_converter.py convert-all

# 통계 확인
python3 scripts/toon_converter.py stats skills.json

# 결과: 16.8% 토큰 절감
```

## Adding New Skills

### 자동 스킬 추가 (권장)

```bash
# 기본 템플릿
./scripts/add_new_skill.sh <category> <skill-name>

# 고급 템플릿 (REFERENCE.md, EXAMPLES.md 포함)
./scripts/add_new_skill.sh <category> <skill-name> --template advanced

# 예시
./scripts/add_new_skill.sh backend graphql-api --description "Design GraphQL APIs"
```

### 수동 스킬 추가

```mermaid
flowchart TD
    A["1. Copy Template"] --> B["2. Edit SKILL.md"]
    B --> C["3. Test with skill_loader.py"]
    C --> D{"Valid?"}
    D -->|Yes| E["4. Run manifest builder"]
    D -->|No| B
    E --> F["5. Git Commit"]

    style A fill:#e3f2fd
    style B fill:#fff3e0
    style C fill:#f3e5f5
    style D fill:#ffebee
    style E fill:#e8f5e9
    style F fill:#a5d6a7
```

```bash
# 1. 템플릿 복사
cp -r templates/basic-skill-template backend/my-skill

# 2. SKILL.md 편집
# name, description 정의 및 상세 지침 작성

# 3. 테스트
python skill_loader.py show my-skill

# 4. 매니페스트 갱신
python scripts/skill_manifest_builder.py

# 5. Git 커밋
git add backend/my-skill && git commit -m "Add my-skill"
```

## Platform Support

### Multi-Agent Workflow

```mermaid
sequenceDiagram
    participant U as User
    participant CC as Claude Code
    participant GC as Gemini-CLI
    participant CX as Codex-CLI

    U->>CC: "인프라 설계해줘"
    CC->>CC: Load infrastructure skill
    CC->>GC: 분석 요청 (ask-gemini)
    GC-->>CC: 분석 결과
    CC->>CX: 명령 실행 (shell)
    CX-->>CC: 실행 결과
    CC-->>U: 완료 리포트
```

### Platform Comparison

| Platform | Setup | AI Response | Skill Loading | Shell Exec |
|:---------|:------|:-----------:|:--------------|:----------:|
| **Claude Code** | `setup.sh` → 1 | ✅ | Automatic | ✅ |
| **ChatGPT** | `setup.sh` → 2 | ✅ | Knowledge Upload | ❌ |
| **Gemini** | `setup.sh` → 3 | ✅ | Python API | ❌ |
| **Gemini-CLI** | `setup.sh` → 6 | ✅ | @file syntax | ❌ |
| **Codex-CLI** | `setup.sh` → 6 | ❌ | N/A | ✅ |

### Claude Code

```bash
# setup.sh 실행 후 자동 설정
# 스킬이 ~/.claude/skills/ 또는 .claude/skills/에 복사됨
claude  # Claude가 자동으로 스킬 감지
```

### ChatGPT

```bash
# setup.sh에서 옵션 2 선택
# 생성된 zip 파일을 Custom GPT Knowledge에 업로드
```

### Gemini

```python
from skill_loader import SkillLoader
import google.generativeai as genai

loader = SkillLoader('.agent-skills')
skill = loader.get_skill('api-design')

genai.configure(api_key='YOUR_API_KEY')
model = genai.GenerativeModel('gemini-2.0-flash')
response = model.generate_content(f"{skill['body']}\n\nDesign a REST API")
```

### MCP Integration (gemini-cli / codex-cli)

```bash
# setup.sh에서 옵션 6 선택하여 MCP 설정

# 스킬 로더 활성화
source mcp-skill-loader.sh

# 스킬 목록 확인
list_skills

# Gemini-CLI 사용 (AI 응답)
gemini chat "$(load_skill backend/api-design) 사용자 관리 API 설계해줘"

# Codex-CLI 사용 (Shell 실행)
codex-cli shell "docker-compose up -d"
```

## Project Structure

```
skills-template/
├── .agent-skills/                 # 핵심 스킬 시스템
│   ├── setup.sh                   # 플랫폼별 설정 스크립트
│   ├── skill_loader.py            # Python 스킬 로더
│   ├── mcp-skill-loader.sh        # MCP 스킬 로더
│   ├── skills.json                # 스킬 매니페스트
│   ├── skills.toon                # TOON 포맷 매니페스트
│   ├── scripts/
│   │   ├── add_new_skill.sh       # 스킬 자동 생성
│   │   ├── toon_converter.py      # TOON 변환기
│   │   ├── skill_manifest_builder.py
│   │   └── codex_skill_executor.sh
│   ├── backend/                   # 백엔드 스킬 (5)
│   ├── frontend/                  # 프론트엔드 스킬 (4)
│   ├── code-quality/              # 코드 품질 스킬 (4)
│   ├── infrastructure/            # 인프라 스킬 (5)
│   ├── documentation/             # 문서화 스킬 (4)
│   ├── project-management/        # 프로젝트 관리 스킬 (4)
│   ├── search-analysis/           # 검색/분석 스킬 (4)
│   ├── utilities/                 # 유틸리티 스킬 (5)
│   └── templates/                 # 스킬 템플릿
├── .claude/skills/                # Claude Code 스킬 (setup.sh로 생성)
├── work/                          # 작업 문서
│   └── result.md                  # 멀티 에이전트 테스트 결과
├── docs/                          # 문서
├── prompt/                        # 프롬프트 템플릿
│   └── add_new_skill_prompt.md    # 스킬 추가 프롬프트
└── README.md
```

## CLI Tools

| Command | Description | Example |
|:--------|:------------|:--------|
| `list` | 모든 스킬 목록 | `python skill_loader.py list` |
| `search` | 스킬 검색 | `python skill_loader.py search "api"` |
| `show` | 스킬 상세 보기 | `python skill_loader.py show api-design` |
| `prompt` | 프롬프트 생성 | `python skill_loader.py prompt --skills api-design` |

### TOON Converter

| Command | Description | Example |
|:--------|:------------|:--------|
| `convert-all` | 전체 스킬 TOON 변환 | `python toon_converter.py convert-all` |
| `encode` | JSON → TOON | `python toon_converter.py encode skills.json` |
| `decode` | TOON → JSON | `python toon_converter.py decode skills.toon` |
| `stats` | 토큰 절감 통계 | `python toon_converter.py stats skills.json` |

### Add New Skill

| Option | Description | Example |
|:-------|:------------|:--------|
| `--template` | 템플릿 선택 | `--template advanced` |
| `--description` | 스킬 설명 | `--description "API caching"` |
| `--tools` | 허용 도구 | `--tools "Read,Write"` |

## Contributing

| Topic | Description |
|:------|:------------|
| **Guide** | `CONTRIBUTING.md` 참조 |
| **Template** | `templates/basic-skill-template/` |
| **Frontmatter** | `name`, `description` 필수 |
| **Review** | PR 제출 후 코드 리뷰 |

## References

| Resource | Link |
|:---------|:-----|
| Agent Skills 공식 | [agentskills.io](https://agentskills.io/) |
| 사양 문서 | [Specification](https://agentskills.io/specification) |
| Claude Code Skills | [Documentation](https://docs.anthropic.com/en/docs/claude-code) |
| Quick Start | [QUICKSTART.md](.agent-skills/QUICKSTART.md) |
| Contributing | [CONTRIBUTING.md](.agent-skills/CONTRIBUTING.md) |
| Multi-Agent Test | [result.md](work/result.md) |

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Version**: 2.0.0 | **Updated**: 2025-01-05 | **Skills**: 34 | **Status**: Active
