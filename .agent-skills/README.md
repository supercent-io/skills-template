# Agent Skills Repository

범용 AI 에이전트를 위한 Agent Skills 모음입니다. Claude, ChatGPT, Gemini 등 모든 AI 플랫폼에서 사용 가능한 오픈 표준을 따릅니다.

## 개요

Agent Skills는 AI 에이전트의 기능을 확장하는 모듈식 기능입니다. 각 Skill은 특정 작업을 수행하는 방법에 대한 지침, 스크립트, 참고 자료를 포함합니다.

**특징**:
- 📦 **모듈화**: 각 Skill은 독립적으로 작동
- 🔄 **재사용 가능**: 다양한 프로젝트에서 사용
- 🌐 **플랫폼 독립적**: Claude, ChatGPT, Gemini 모두 지원
- 📝 **자체 문서화**: SKILL.md만 읽어도 이해 가능
- 🔍 **점진적 공개**: 필요할 때만 컨텍스트 로드

## 폴더 구조

```
.agent-skills/
├── README.md                          # 이 파일
├── CONTRIBUTING.md                    # 기여 가이드
├── setup.sh                           # 설정 스크립트
├── skill_loader.py                    # Python 유틸리티
├── templates/                         # Skills 작성 템플릿
├── infrastructure/                    # 인프라 Skills
│   ├── system-setup/
│   ├── deployment/
│   ├── monitoring/
│   └── security/
├── backend/                           # 백엔드 Skills
│   ├── api-design/                   ✅ 구현됨
│   ├── database/
│   ├── authentication/
│   └── testing/
├── frontend/                          # 프론트엔드 Skills
│   ├── ui-components/
│   ├── state-management/
│   ├── responsive-design/
│   └── accessibility/
├── documentation/                     # 문서 Skills
│   ├── technical-writing/            ✅ 구현됨
│   ├── api-documentation/
│   ├── user-guides/
│   └── changelog/
├── code-quality/                      # 코드 품질 Skills
│   ├── code-review/                  ✅ 구현됨
│   ├── refactoring/
│   ├── testing-strategies/
│   └── performance-optimization/
├── search-analysis/                   # 검색/분석 Skills
│   ├── codebase-search/              ✅ 구현됨
│   ├── log-analysis/
│   ├── data-analysis/
│   └── pattern-detection/
├── project-management/                # 프로젝트 관리 Skills
│   ├── task-planning/
│   ├── estimation/
│   ├── retrospective/
│   └── standup-helper/
└── utilities/                         # 유틸리티 Skills
    ├── git-workflow/
    ├── environment-setup/
    ├── file-organization/
    └── automation/
```

## 사용 방법

### Claude (Cursor, Claude.ai, Claude Code)

**자동 발견**:
Claude는 `.agent-skills/` 또는 `~/.claude/skills/` 폴더의 Skills를 자동으로 발견하고 로드합니다.

```bash
# 프로젝트 Skills (팀과 공유)
cp -r .agent-skills/.claude/skills/

# 개인 Skills
cp -r .agent-skills/* ~/.claude/skills/
```

**사용 예시**:
```
사용자: "REST API를 설계해줘"
→ Claude가 자동으로 'api-design' Skill 활성화
→ API 설계 베스트 프랙티스를 따라 설계
```

### ChatGPT (Custom GPTs)

**방법 1: Knowledge Base 업로드**
1. `.agent-skills/` 폴더를 zip으로 압축
2. Custom GPT의 Knowledge에 업로드
3. Instructions에 다음 추가:

```
You have access to Agent Skills in your knowledge base.
Each skill is in a folder with SKILL.md file.

When a task matches a skill's description:
1. Search for the relevant SKILL.md in knowledge base
2. Read and follow the instructions
3. Use referenced files as needed

Available skills: api-design, code-review, technical-writing, 
codebase-search, and more in the knowledge base.
```

**방법 2: 직접 프롬프트 포함**
```
I'm using Agent Skills. Here's the skill:

[SKILL.md 내용 붙여넣기]

Now help me with: [작업 요청]
```

### Gemini (Gemini Advanced, API)

**Python 스크립트 사용**:
```python
from skill_loader import SkillLoader

# Skills 로드
loader = SkillLoader('.agent-skills')

# 특정 Skill 가져오기
api_skill = loader.get_skill('api-design')

# 프롬프트 생성
prompt = f"""
{api_skill['body']}

Now help me design an API for user management.
"""

# Gemini API 호출
import google.generativeai as genai
model = genai.GenerativeModel('gemini-pro')
response = model.generate_content(prompt)
```

## 빠른 시작

### 1. 설정
```bash
# 스크립트 실행 권한 부여
chmod +x setup.sh

# 기본 설정 실행
./setup.sh
```

### 2. 첫 번째 Skill 사용

**Claude 사용자**:
```
"REST API를 설계해줘"
```

**ChatGPT 사용자**:
```python
# skill_loader.py 사용
python skill_loader.py --skill api-design --output prompt.txt
# prompt.txt 내용을 ChatGPT에 붙여넣기
```

**Gemini 사용자**:
```python
# Python 스크립트로 통합
python -c "
from skill_loader import SkillLoader
loader = SkillLoader('.agent-skills')
print(loader.format_for_prompt(['api-design']))
"
```

### 3. 새 Skill 추가

```bash
# 새 Skill 폴더 생성
mkdir -p .agent-skills/backend/new-skill

# SKILL.md 생성
cat > .agent-skills/backend/new-skill/SKILL.md << 'EOF'
---
name: new-skill
description: What this skill does and when to use it
---

# New Skill

## Instructions
1. Step 1
2. Step 2

## Examples
...
EOF

# Git에 커밋
git add .agent-skills/backend/new-skill/
git commit -m "Add new-skill"
```

## 사용 가능한 Skills

### Infrastructure (인프라)
- 🏗️ **system-setup**: 시스템 환경 설정
- 🚀 **deployment**: 배포 자동화
- 📊 **monitoring**: 모니터링 설정
- 🔒 **security**: 보안 구성

### Backend (백엔드)
- ✅ **api-design**: REST/GraphQL API 설계 (구현됨)
- 🗄️ **database**: 데이터베이스 스키마 설계
- 🔐 **authentication**: 인증/인가 구현
- 🧪 **testing**: 백엔드 테스트 전략

### Frontend (프론트엔드)
- 🎨 **ui-components**: UI 컴포넌트 개발
- 🔄 **state-management**: 상태 관리
- 📱 **responsive-design**: 반응형 디자인
- ♿ **accessibility**: 접근성 구현

### Documentation (문서)
- ✅ **technical-writing**: 기술 문서 작성 (구현됨)
- 📚 **api-documentation**: API 문서화
- 📖 **user-guides**: 사용자 가이드
- 📝 **changelog**: 변경 이력 관리

### Code Quality (코드 품질)
- ✅ **code-review**: 코드 리뷰 (구현됨)
- 🔧 **refactoring**: 리팩토링 전략
- 🧪 **testing-strategies**: 테스트 전략
- ⚡ **performance-optimization**: 성능 최적화

### Search & Analysis (검색/분석)
- ✅ **codebase-search**: 코드베이스 검색 (구현됨)
- 📋 **log-analysis**: 로그 분석
- 📊 **data-analysis**: 데이터 분석
- 🔍 **pattern-detection**: 패턴 감지

### Project Management (프로젝트 관리)
- 📋 **task-planning**: 작업 계획
- ⏱️ **estimation**: 개발 시간 추정
- 🔄 **retrospective**: 회고 진행
- 📢 **standup-helper**: 스탠드업 준비

### Utilities (유틸리티)
- 🌿 **git-workflow**: Git 워크플로우
- ⚙️ **environment-setup**: 환경 설정
- 📁 **file-organization**: 파일 정리
- 🤖 **automation**: 자동화 스크립트

## 기여하기

새로운 Skill을 추가하거나 기존 Skill을 개선하려면 [CONTRIBUTING.md](CONTRIBUTING.md)를 참조하세요.

### 기여 단계
1. 새 Skill 폴더 생성
2. `SKILL.md` 파일 작성 (템플릿 참조)
3. 지원 파일 추가 (선택사항)
4. 테스트
5. Pull Request 생성

## 참고 자료

### 공식 문서
- [Agent Skills 공식 사이트](https://agentskills.io/)
- [Agent Skills 사양](https://agentskills.io/specification)
- [Agent Skills GitHub](https://github.com/agentskills/agentskills)
- [Claude Code Skills](https://code.claude.com/docs/ko/skills)

### 가이드 문서
- [Skills 작성 템플릿](/Skills/claude_skill_template_guide.md)
- [범용 Skills 아키텍처](/Skills/universal_agent_skills_architecture.md)

## 라이선스

이 프로젝트는 Agent Skills 오픈 표준을 따르며, 자유롭게 사용, 수정, 배포할 수 있습니다.

## 문의

- Issue: GitHub Issues
- Email: [your-email]
- Slack: [your-slack-channel]

---

**버전**: 1.0.0  
**최종 업데이트**: 2024-01-15  
**관리자**: [Your Name]

