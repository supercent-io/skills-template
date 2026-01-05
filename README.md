# Agent Skills

> Claude, ChatGPT, Gemini, MCP 기반 CLI에서 사용 가능한 범용 AI 에이전트 스킬 시스템

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.x-blue.svg?logo=python)](https://www.python.org/)
[![Skills](https://img.shields.io/badge/Skills-30-green.svg)](.agent-skills/)
[![Platforms](https://img.shields.io/badge/Platforms-Claude%20%7C%20ChatGPT%20%7C%20Gemini%20%7C%20MCP-informational.svg)](https://agentskills.io/)

## Features

- **Multi-Platform Support** - Claude, ChatGPT, Gemini, MCP(gemini-cli, codex-cli) 지원
- **30+ Ready-to-Use Skills** - 8개 카테고리의 실전 스킬
- **Open Standard** - Agent Skills 오픈 표준 준수
- **Easy Setup** - `setup.sh` 원클릭 설정
- **Extensible** - 템플릿 기반 스킬 추가

## Quick Start

```bash
# 1. 저장소 클론
git clone https://github.com/your-org/skills-template.git
cd skills-template

# 2. 설정 스크립트 실행
cd .agent-skills && ./setup.sh

# 3. 플랫폼 선택 (1: Claude, 2: ChatGPT, 3: Gemini, 6: MCP Integration)
```

## Skills Overview

| Category | Skills | Description |
|----------|--------|-------------|
| **Backend** | 5 | API 설계, 데이터베이스, 인증, 테스팅 |
| **Frontend** | 4 | UI 컴포넌트, 상태 관리, 반응형, 접근성 |
| **Code-Quality** | 4 | 코드 리뷰, 리팩토링, 테스트 전략, 성능 최적화 |
| **Infrastructure** | 4 | 시스템 설정, 배포, 모니터링, 보안 |
| **Documentation** | 4 | 기술 문서, API 문서, 사용자 가이드, Changelog |
| **Project-Management** | 4 | 태스크 계획, 견적, 회고, 스탠드업 |
| **Search-Analysis** | 1 | 코드베이스 검색 및 분석 |
| **Utilities** | 4 | Git 워크플로우, 환경 설정, 자동화 |

**Total: 30 Skills**

## Platform Support

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

```
.
├── .agent-skills/
│   ├── setup.sh                 # 자동 설정 스크립트
│   ├── skill_loader.py          # Python 스킬 유틸리티
│   ├── mcp-skill-loader.sh      # MCP 스킬 로더
│   ├── validate_claude_skills.py # 스킬 검증 도구
│   │
│   ├── templates/               # 스킬 템플릿
│   ├── backend/                 # 백엔드 스킬 (5)
│   ├── frontend/                # 프론트엔드 스킬 (4)
│   ├── code-quality/            # 코드 품질 스킬 (4)
│   ├── infrastructure/          # 인프라 스킬 (4)
│   ├── documentation/           # 문서화 스킬 (4)
│   ├── project-management/      # 프로젝트 관리 스킬 (4)
│   ├── search-analysis/         # 검색/분석 스킬 (1)
│   └── utilities/               # 유틸리티 스킬 (4)
│
├── prompt/                      # 설정 프롬프트
└── README.md
```

## Adding New Skills

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

```bash
# 스킬 목록
python skill_loader.py list

# 스킬 검색
python skill_loader.py search "api"

# 스킬 상세 보기
python skill_loader.py show api-design

# 프롬프트 생성
python skill_loader.py prompt --skills api-design --format xml
```

## Contributing

`CONTRIBUTING.md` 참조. 주요 내용:
- 스킬 작성 가이드
- YAML frontmatter 규칙
- 제출 프로세스
- 코드 리뷰 기준

## References

- [Agent Skills 공식 사이트](https://agentskills.io/)
- [Agent Skills 사양](https://agentskills.io/specification)
- [Claude Code Skills](https://code.claude.com/docs/ko/skills)
- [QUICKSTART.md](.agent-skills/QUICKSTART.md)
- [CONTRIBUTING.md](.agent-skills/CONTRIBUTING.md)

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Version**: 1.1.0 | **Updated**: 2026-01-05 | **Status**: Active
