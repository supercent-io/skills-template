# Agent Skills

> Claude, ChatGPT, Gemini, MCP 기반 CLI에서 사용 가능한 범용 AI 에이전트 스킬 시스템

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.x-blue.svg?logo=python)](https://www.python.org/)
[![Skills](https://img.shields.io/badge/Skills-30-green.svg)](.agent-skills/)
[![Platforms](https://img.shields.io/badge/Platforms-Claude%20%7C%20ChatGPT%20%7C%20Gemini%20%7C%20MCP-informational.svg)](https://agentskills.io/)

## Architecture

```mermaid
graph TB
    subgraph "Agent Skills System"
        AS[".agent-skills/"]
        SK["SKILL.md Files"]
        SL["skill_loader.py"]
        SS["setup.sh"]
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
    SK --> SL
    SK --> SS

    SS --> CL
    SS --> GP
    SS --> GM
    SL --> GC
    SL --> CC

    style AS fill:#e1f5fe
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
| **30+ Skills** | 8개 카테고리의 실전 스킬 | ✅ |
| **Open Standard** | Agent Skills 오픈 표준 준수 | ✅ |
| **Easy Setup** | `setup.sh` 원클릭 설정 | ✅ |
| **Extensible** | 템플릿 기반 스킬 추가 | ✅ |
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
    title Skills by Category
    "Backend" : 5
    "Frontend" : 4
    "Code-Quality" : 4
    "Infrastructure" : 4
    "Documentation" : 4
    "Project-Mgmt" : 4
    "Search-Analysis" : 1
    "Utilities" : 4
```

### Detailed Skills

| Category | Count | Skills |
|:---------|:-----:|:-------|
| **Backend** | 5 | `api-design` `database-schema` `authentication` `backend-testing` `error-handling` |
| **Frontend** | 4 | `ui-components` `state-management` `responsive-design` `accessibility` |
| **Code-Quality** | 4 | `code-review` `refactoring` `testing-strategies` `performance-optimization` |
| **Infrastructure** | 4 | `system-setup` `deployment` `monitoring` `security` |
| **Documentation** | 4 | `technical-writing` `api-docs` `user-guides` `changelog` |
| **Project-Mgmt** | 4 | `task-planning` `estimation` `retrospective` `standup` |
| **Search-Analysis** | 1 | `codebase-search` |
| **Utilities** | 4 | `git-workflow` `environment-setup` `file-organization` `automation` |

> **Total: 30 Skills**

## Platform Support

### Comparison Table

| Platform | Setup Method | Auto-Detection | Skill Loading |
|:---------|:-------------|:--------------:|:--------------|
| **Claude Code** | `setup.sh` → Option 1 | ✅ | Automatic |
| **ChatGPT** | `setup.sh` → Option 2 | ❌ | Knowledge Upload |
| **Gemini** | `setup.sh` → Option 3 | ❌ | Python API |
| **MCP CLI** | `setup.sh` → Option 6 | ✅ | Shell Script |

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
model = genai.GenerativeModel('gemini-pro')
response = model.generate_content(f"{skill['body']}\n\nDesign a REST API")
```

### MCP Integration (gemini-cli / codex-cli)

```mermaid
sequenceDiagram
    participant U as User
    participant S as mcp-skill-loader.sh
    participant SK as SKILL.md
    participant CLI as gemini-cli / codex-cli
    participant AI as AI Model

    U->>S: source mcp-skill-loader.sh
    U->>S: load_skill backend/api-design
    S->>SK: Read SKILL.md
    SK-->>S: Skill Content
    U->>CLI: gemini chat "$(load_skill ...) prompt"
    CLI->>AI: Skill + User Prompt
    AI-->>CLI: Response
    CLI-->>U: Output
```

```bash
# setup.sh에서 옵션 6 선택하여 MCP 설정

# 스킬 로더 활성화
source .agent-skills/mcp-skill-loader.sh

# 스킬 목록 확인
list_skills

# 스킬 사용 예시
gemini chat "$(load_skill backend/api-design) 사용자 관리 API 설계해줘"
codex-cli shell "$(load_skill code-quality/code-review) 이 코드 리뷰해줘"
```

## Project Structure

```mermaid
graph TD
    ROOT[skills-template/] --> AS[.agent-skills/]
    ROOT --> PM[prompt/]
    ROOT --> RM[README.md]

    AS --> CORE["Core Files"]
    AS --> CATS["Skill Categories"]
    AS --> TPL[templates/]

    CORE --> SS[setup.sh]
    CORE --> SL[skill_loader.py]
    CORE --> ML[mcp-skill-loader.sh]
    CORE --> VS[validate_claude_skills.py]

    CATS --> BE["backend/ (5)"]
    CATS --> FE["frontend/ (4)"]
    CATS --> CQ["code-quality/ (4)"]
    CATS --> IF["infrastructure/ (4)"]
    CATS --> DC["documentation/ (4)"]
    CATS --> PM2["project-management/ (4)"]
    CATS --> SA["search-analysis/ (1)"]
    CATS --> UT["utilities/ (4)"]

    style ROOT fill:#e8f5e9
    style AS fill:#e3f2fd
    style CORE fill:#fff3e0
    style CATS fill:#fce4ec
```

## Adding New Skills

```mermaid
flowchart TD
    A["1. Copy Template"] --> B["2. Edit SKILL.md"]
    B --> C["3. Test with skill_loader.py"]
    C --> D{"Valid?"}
    D -->|Yes| E["4. Git Commit"]
    D -->|No| B
    E --> F["Done!"]

    style A fill:#e3f2fd
    style B fill:#fff3e0
    style C fill:#f3e5f5
    style D fill:#ffebee
    style E fill:#e8f5e9
    style F fill:#a5d6a7
```

```bash
# 1. 템플릿 복사
cp -r .agent-skills/templates/basic-skill-template .agent-skills/backend/my-skill

# 2. SKILL.md 작성
# name, description 정의 및 상세 지침 작성

# 3. 테스트
python .agent-skills/skill_loader.py show my-skill

# 4. Git 커밋
git add .agent-skills/backend/my-skill && git commit -m "Add my-skill"
```

## CLI Tools

| Command | Description | Example |
|:--------|:------------|:--------|
| `list` | 모든 스킬 목록 | `python skill_loader.py list` |
| `search` | 스킬 검색 | `python skill_loader.py search "api"` |
| `show` | 스킬 상세 보기 | `python skill_loader.py show api-design` |
| `prompt` | 프롬프트 생성 | `python skill_loader.py prompt --skills api-design --format xml` |

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
| Claude Code Skills | [Documentation](https://code.claude.com/docs/ko/skills) |
| Quick Start | [QUICKSTART.md](.agent-skills/QUICKSTART.md) |
| Contributing | [CONTRIBUTING.md](.agent-skills/CONTRIBUTING.md) |

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Version**: 1.2.0 | **Updated**: 2026-01-05 | **Status**: Active
