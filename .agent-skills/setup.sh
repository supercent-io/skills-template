#!/bin/bash

# Agent Skills Setup Script
# This script helps set up Agent Skills for different AI platforms

set -e

echo "🚀 Agent Skills Setup"
echo "===================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Detect current directory
AGENT_SKILLS_DIR=$(pwd)

print_info "Agent Skills directory: $AGENT_SKILLS_DIR"
echo ""

# Menu
echo "Select your AI platform:"
echo "1) Claude (Cursor, Claude Code, Claude.ai)"
echo "2) ChatGPT (Custom GPT setup instructions)"
echo "3) Gemini (Python integration)"
echo "4) All platforms (comprehensive setup)"
echo "5) Validate Skills (Check standards)"
echo "6) Exit"
echo ""
read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        echo ""
        print_info "Setting up for Claude..."
        
        # Check if running in a git repository
        if git rev-parse --git-dir > /dev/null 2>&1; then
            print_info "Git repository detected"
            
            # Create .claude/skills directory
            mkdir -p .claude/skills
            
            # Copy skills to .claude/skills
            print_info "Copying skills to .claude/skills/..."
            cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities .claude/skills/ 2>/dev/null || true
            
            print_success "Project skills set up in .claude/skills/"
            print_info "These skills will be shared with your team via git"
        else
            print_warning "Not in a git repository"
            print_info "Skills in .agent-skills/ will be used directly"
        fi
        
        # Option to set up personal skills
        echo ""
        read -p "Do you want to set up personal skills in ~/.claude/skills/? (y/n): " setup_personal
        
        if [[ $setup_personal =~ ^[Yy]$ ]]; then
            mkdir -p ~/.claude/skills
            print_info "Copying skills to ~/.claude/skills/..."
            cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities ~/.claude/skills/ 2>/dev/null || true
            print_success "Personal skills set up in ~/.claude/skills/"
        fi
        
        echo ""
        print_success "Claude setup complete!"
        echo ""
        print_info "Usage:"
        echo "  Just ask Claude to perform tasks, and it will automatically use relevant skills."
        echo "  Example: 'Design a REST API for user management'"
        ;;
        
    2)
        echo ""
        print_info "Setting up for ChatGPT..."

        # Create zip file
        ZIP_FILE="agent-skills-$(date +%Y%m%d).zip"
        print_info "Creating zip file: $ZIP_FILE"

        # Create temporary directory
        TEMP_DIR=$(mktemp -d)
        cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities "$TEMP_DIR/"

        # Create zip
        cd "$TEMP_DIR"
        zip -r "$AGENT_SKILLS_DIR/$ZIP_FILE" . > /dev/null 2>&1
        cd "$AGENT_SKILLS_DIR"
        rm -rf "$TEMP_DIR"

        print_success "Zip file created: $ZIP_FILE"
        echo ""
        print_info "Next steps:"
        echo "1. Go to ChatGPT and create a Custom GPT or configure ChatGPT Apps"
        echo "2. Upload $ZIP_FILE to the Knowledge section"
        echo "3. Add this to Instructions:"
        echo ""
        cat << 'EOF'
# Agent Skills System

You have access to Agent Skills in your knowledge base.
Each skill is organized in a folder with a SKILL.md file that serves as your operational manual.

## Skill Structure
- **SKILL.md**: Contains the skill's purpose, trigger conditions, step-by-step procedures, output formats, and constraints
- **Supporting files**: Templates, examples, reference documents, and scripts

## How to Use Skills
When a user request matches a skill's description:
1. **Identify** the relevant skill by searching for SKILL.md files in the knowledge base
2. **Read** the complete SKILL.md to understand:
   - Purpose (What this skill does)
   - When to trigger (Specific conditions)
   - How to execute (Step-by-step procedure)
   - Output format (Expected deliverable structure)
   - Constraints (What to avoid, security rules)
3. **Follow** the instructions exactly as written in the SKILL.md
4. **Reference** any supporting files mentioned in the skill documentation
5. **Deliver** output in the format specified by the skill

## Available Skills
Search the knowledge base for SKILL.md files. Common skills include:
- API design and architecture
- Code review and quality checks
- Technical documentation writing
- Codebase search and analysis
- Project management workflows
- Infrastructure setup and deployment

## Meta Rules
- Always prioritize skill instructions over general knowledge
- If multiple skills apply, ask the user which to prioritize
- Never add information not requested in the skill's procedure
- Follow security and constraint rules strictly
EOF

        echo ""
        print_info "Tip: Each SKILL.md follows a standard format:"
        echo "  - name, description, tags (metadata)"
        echo "  - Purpose, When to use, Procedure, Output format, Constraints"
        ;;
        
    3)
        echo ""
        print_info "Setting up for Gemini..."

        # Create GEMINI.md in project root
        print_info "Creating GEMINI.md in project root..."

        cat > "$AGENT_SKILLS_DIR/../GEMINI.md" << 'EOF'
# Agent Skills for Gemini

이 프로젝트는 Agent Skills 시스템을 사용합니다.
Gemini는 `.agent-skills/` 폴더의 스킬들을 작업 매뉴얼로 참조해야 합니다.

## 스킬 시스템 개요

각 스킬은 독립된 폴더에 다음 구조로 구성됩니다:
- **SKILL.md**: 스킬의 목적, 트리거 조건, 절차, 출력 포맷, 제약사항
- **지원 파일**: 템플릿, 예시, 참조 문서, 스크립트

## 스킬 사용 규칙

사용자 요청이 특정 스킬과 일치할 때:

1. **식별**: `.agent-skills/` 폴더에서 관련 SKILL.md를 검색
2. **읽기**: SKILL.md의 전체 내용을 파악
   - 목적 (Purpose): 이 스킬이 하는 일
   - 사용 시점 (When): 언제 트리거되는지
   - 절차 (Procedure): 단계별 실행 방법
   - 출력 포맷 (Output): 결과물의 구조
   - 제약 (Constraints): 금지사항, 보안 규칙
3. **실행**: SKILL.md의 지시사항을 정확히 따름
4. **참조**: 스킬 문서에서 언급된 지원 파일 활용
5. **제공**: 스킬이 지정한 포맷으로 결과 출력

## 사용 가능한 스킬 카테고리

- infrastructure/: 인프라 설정 및 배포
- backend/: 백엔드 개발 및 API 설계
- frontend/: 프론트엔드 개발 및 UI/UX
- documentation/: 기술 문서 작성
- code-quality/: 코드 리뷰 및 품질 검사
- search-analysis/: 코드베이스 검색 및 분석
- project-management/: 프로젝트 관리 워크플로우
- utilities/: 유틸리티 및 헬퍼 도구

## 메타 규칙

- 스킬 지시사항을 일반 지식보다 우선시
- 여러 스킬이 적용 가능하면 사용자에게 우선순위 질문
- 스킬 절차에서 요청되지 않은 정보는 추가하지 않음
- 보안 및 제약 규칙을 엄격히 준수
- 한국어 출력 시 존댓말 사용, 코드는 영문 변수명/주석은 한글

## 코드 작성 기준

- 명확한 함수/모듈 단위 분리
- Type hints 사용 (Python)
- 환경변수로 민감 정보 관리
- 추측성 정보 추가 금지
EOF

        print_success "GEMINI.md created in project root"
        echo ""

        # Gemini CLI setup instructions
        print_info "Gemini CLI Setup:"
        echo ""
        echo "Option 1: Gemini CLI (Recommended for agentic coding)"
        echo "  Install: npm install -g @google/gemini-cli"
        echo "  Setup:   gemini auth login"
        echo "  Usage:   gemini chat --context GEMINI.md"
        echo ""
        echo "  The CLI will automatically read GEMINI.md as project context."
        echo "  Learn more: https://geminicli.com/docs/cli/gemini-md/"
        echo ""

        echo "Option 2: Gemini Code Assist (IDE integration)"
        echo "  Install the Gemini Code Assist extension in your IDE"
        echo "  Enable 'Agent Mode' for pair-programmer experience"
        echo "  The agent will read GEMINI.md automatically"
        echo "  Learn more: https://developers.google.com/gemini-code-assist"
        echo ""

        # Python integration (optional)
        echo "Option 3: Python API integration"
        read -p "Do you want to install Python dependencies? (y/n): " install_python

        if [[ $install_python =~ ^[Yy]$ ]]; then
            # Check if Python is installed
            if ! command -v python3 &> /dev/null; then
                print_warning "Python 3 is not installed"
                echo "Please install Python 3 to use Python integration"
            else
                # Check if google-generativeai is installed
                if ! python3 -c "import google.generativeai" 2>/dev/null; then
                    print_info "Installing google-generativeai..."
                    pip3 install google-generativeai
                fi

                print_success "Python dependencies installed"
                echo ""
                print_info "Python usage example:"
                cat << 'EOF'
from pathlib import Path
import google.generativeai as genai

# Read GEMINI.md as context
gemini_context = Path('GEMINI.md').read_text()

# Read specific skill
skill_path = Path('.agent-skills/backend/api-design/SKILL.md')
skill_content = skill_path.read_text()

# Combine context
prompt = f"""{gemini_context}

{skill_content}

Now help me design a REST API for user management.
"""

# Use with Gemini
genai.configure(api_key='YOUR_API_KEY')
model = genai.GenerativeModel('gemini-2.0-flash-exp')
response = model.generate_content(prompt)
print(response.text)
EOF
            fi
        fi

        echo ""
        print_success "Gemini setup complete!"
        echo ""
        print_info "Quick Start:"
        echo "  - Use 'gemini chat' in your project directory"
        echo "  - Gemini will automatically use GEMINI.md as context"
        echo "  - Ask it to use specific skills: 'Use the api-design skill to create a REST API'"
        ;;
        
    4)
        echo ""
        print_info "Setting up for all platforms..."
        echo ""

        # Claude setup
        print_info "Setting up Claude..."
        if git rev-parse --git-dir > /dev/null 2>&1; then
            mkdir -p .claude/skills
            cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities .claude/skills/ 2>/dev/null || true
            print_success "Claude project skills set up"
        fi

        mkdir -p ~/.claude/skills
        cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities ~/.claude/skills/ 2>/dev/null || true
        print_success "Claude personal skills set up"
        echo ""

        # ChatGPT setup
        print_info "Setting up ChatGPT..."
        ZIP_FILE="agent-skills-$(date +%Y%m%d).zip"
        TEMP_DIR=$(mktemp -d)
        cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities "$TEMP_DIR/"
        cd "$TEMP_DIR"
        zip -r "$AGENT_SKILLS_DIR/$ZIP_FILE" . > /dev/null 2>&1
        cd "$AGENT_SKILLS_DIR"
        rm -rf "$TEMP_DIR"
        print_success "ChatGPT zip file created: $ZIP_FILE"
        print_info "Upload this to Custom GPT Knowledge section"
        echo ""

        # Gemini setup
        print_info "Setting up Gemini..."
        cat > "$AGENT_SKILLS_DIR/../GEMINI.md" << 'EOF'
# Agent Skills for Gemini

이 프로젝트는 Agent Skills 시스템을 사용합니다.
Gemini는 `.agent-skills/` 폴더의 스킬들을 작업 매뉴얼로 참조해야 합니다.

## 스킬 시스템 개요

각 스킬은 독립된 폴더에 다음 구조로 구성됩니다:
- **SKILL.md**: 스킬의 목적, 트리거 조건, 절차, 출력 포맷, 제약사항
- **지원 파일**: 템플릿, 예시, 참조 문서, 스크립트

## 스킬 사용 규칙

사용자 요청이 특정 스킬과 일치할 때:

1. **식별**: `.agent-skills/` 폴더에서 관련 SKILL.md를 검색
2. **읽기**: SKILL.md의 전체 내용을 파악
   - 목적 (Purpose): 이 스킬이 하는 일
   - 사용 시점 (When): 언제 트리거되는지
   - 절차 (Procedure): 단계별 실행 방법
   - 출력 포맷 (Output): 결과물의 구조
   - 제약 (Constraints): 금지사항, 보안 규칙
3. **실행**: SKILL.md의 지시사항을 정확히 따름
4. **참조**: 스킬 문서에서 언급된 지원 파일 활용
5. **제공**: 스킬이 지정한 포맷으로 결과 출력

## 사용 가능한 스킬 카테고리

- infrastructure/: 인프라 설정 및 배포
- backend/: 백엔드 개발 및 API 설계
- frontend/: 프론트엔드 개발 및 UI/UX
- documentation/: 기술 문서 작성
- code-quality/: 코드 리뷰 및 품질 검사
- search-analysis/: 코드베이스 검색 및 분석
- project-management/: 프로젝트 관리 워크플로우
- utilities/: 유틸리티 및 헬퍼 도구

## 메타 규칙

- 스킬 지시사항을 일반 지식보다 우선시
- 여러 스킬이 적용 가능하면 사용자에게 우선순위 질문
- 스킬 절차에서 요청되지 않은 정보는 추가하지 않음
- 보안 및 제약 규칙을 엄격히 준수
- 한국어 출력 시 존댓말 사용, 코드는 영문 변수명/주석은 한글

## 코드 작성 기준

- 명확한 함수/모듈 단위 분리
- Type hints 사용 (Python)
- 환경변수로 민감 정보 관리
- 추측성 정보 추가 금지
EOF

        print_success "GEMINI.md created in project root"

        if command -v python3 &> /dev/null; then
            if ! python3 -c "import google.generativeai" 2>/dev/null; then
                print_info "Installing Python dependencies..."
                pip3 install google-generativeai > /dev/null 2>&1
            fi
            print_success "Gemini Python dependencies installed"
        else
            print_warning "Python 3 not found, skipping Python integration"
        fi

        echo ""
        print_success "All platforms set up!"
        echo ""
        print_info "What's been configured:"
        echo "  ✓ Claude: .claude/skills/ and ~/.claude/skills/"
        echo "  ✓ ChatGPT: $ZIP_FILE (upload to Custom GPT)"
        echo "  ✓ Gemini: GEMINI.md (use with Gemini CLI or Code Assist)"
        ;;
        
    5)
        echo ""
        print_info "Validating skills..."
        if command -v python3 &> /dev/null; then
            python3 skill_loader.py validate
        else
            print_warning "Python 3 not found, cannot validate."
        fi
        ;;

    6)
        echo "Exiting..."
        exit 0
        ;;
        
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_success "Setup complete! 🎉"
echo ""
print_info "Next steps:"
echo "- Check README.md for usage instructions"
echo "- Try using a skill with your AI assistant"
echo "- Create new skills using templates/"
echo ""

