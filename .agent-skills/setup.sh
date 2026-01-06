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

# Resolve script directory for path-independent execution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_SKILLS_DIR="$SCRIPT_DIR"

# Cleanup function for temporary directories
TEMP_DIR=""
cleanup_temp_dir() {
    if [ -n "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup_temp_dir EXIT

# Skill categories as array
SKILL_CATEGORIES=(backend frontend code-quality infrastructure documentation project-management search-analysis utilities)

# Function to copy skills to a destination
copy_skills() {
    local dest="$1"
    local verbose="$2"
    local copied=0
    local category

    for category in "${SKILL_CATEGORIES[@]}"; do
        if [ -d "$category" ]; then
            cp -r "$category" "$dest/"
            local skill_count
            skill_count=$(find "$category" -name "SKILL.md" -o -name "SKILL.toon" | wc -l | tr -d ' ')
            copied=$((copied + skill_count))
            if [ "$verbose" = "true" ]; then
                print_success "  ✓ $category ($skill_count skills)"
            fi
        else
            if [ "$verbose" = "true" ]; then
                print_warning "  ✗ $category (not found)"
            fi
        fi
    done

    echo "$copied"
}

print_info "Agent Skills directory: $AGENT_SKILLS_DIR"
echo ""

# Menu
echo "Select your AI platform:"
echo "1) Claude (Cursor, Claude Code, Claude.ai)"
echo "2) ChatGPT (Custom GPT setup instructions)"
echo "3) Gemini (Python integration)"
echo "4) All platforms (comprehensive setup)"
echo "5) Validate Skills (Check standards)"
echo "6) MCP Integration (Gemini-CLI, Codex-CLI)"
echo "7) Token Optimization (Generate compact skills)"
echo "8) Exit"
echo ""
read -p "Enter your choice (1-8): " choice

case "$choice" in
    1)
        echo ""
        print_info "Setting up for Claude Code..."
        echo ""

        # Validate skills before copying
        print_info "Step 1/4: Validating source skills..."
        if command -v python3 &> /dev/null; then
            # Run validation on source skills
            if [ -f "validate_claude_skills.py" ]; then
                # Temporarily validate source skills by checking a sample
                SAMPLE_SKILL="backend/api-design/SKILL.md"
                if [ -f "$SAMPLE_SKILL" ]; then
                    print_success "Source skills found and ready"
                else
                    print_warning "Some skill files may be missing"
                fi
            else
                print_warning "Validation script not found, skipping validation"
            fi
        else
            print_warning "Python 3 not found, skipping validation"
        fi

        echo ""

        # Check if running in a git repository
        if git rev-parse --git-dir > /dev/null 2>&1; then
            print_info "Step 2/4: Setting up project skills..."
            print_info "Git repository detected - skills will be shared with your team"

            # Create .claude/skills directory
            mkdir -p ../.claude/skills

            # Copy skills to .claude/skills
            print_info "Copying skills to .claude/skills/..."
            COPIED_COUNT=$(copy_skills "../.claude/skills" "true")

            echo ""
            print_success "Project skills set up: $COPIED_COUNT skills in .claude/skills/"
            print_info "Location: $(cd .. && pwd)/.claude/skills/"
        else
            print_warning "Step 2/4: Not in a git repository"
            print_info "Skipping project skills setup"
            print_info "You can use skills directly from .agent-skills/ or set up personal skills"
        fi

        # Option to set up personal skills
        echo ""
        read -p "Do you want to set up personal skills in ~/.claude/skills/? (y/n): " setup_personal

        if [[ $setup_personal =~ ^[Yy]$ ]]; then
            print_info "Step 3/4: Setting up personal skills..."
            mkdir -p ~/.claude/skills

            print_info "Copying skills to ~/.claude/skills/..."
            PERSONAL_COPIED=$(copy_skills "$HOME/.claude/skills" "true")

            echo ""
            print_success "Personal skills set up: $PERSONAL_COPIED skills in ~/.claude/skills/"
            print_info "Location: ~/.claude/skills/"
        else
            print_info "Step 3/4: Skipping personal skills setup"
        fi

        # Validate installed skills
        echo ""
        print_info "Step 4/4: Validating installed skills..."

        if command -v python3 &> /dev/null && [ -f "validate_claude_skills.py" ]; then
            # Check if .claude/skills exists
            if [ -d "../.claude/skills" ]; then
                echo ""
                print_info "Running validation on project skills..."
                echo ""

                # Run validation and capture result
                if (cd .. && python3 .agent-skills/validate_claude_skills.py 2>&1 | tail -20); then
                    echo ""
                else
                    print_warning "Validation completed with warnings or errors"
                    print_info "Run 'python3 validate_claude_skills.py' for details"
                    echo ""
                fi
            else
                print_info "No project skills to validate"
            fi
        else
            print_warning "Skipping validation (Python 3 or validation script not available)"
        fi

        echo ""
        print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        print_success "Claude Code Skills Setup Complete! 🎉"
        print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        print_info "📚 Next Steps:"
        echo ""
        echo "  1. Start Claude Code CLI:"
        echo "     ${BLUE}claude${NC}"
        echo ""
        echo "  2. Check available skills:"
        echo "     ${BLUE}What Skills are available?${NC}"
        echo ""
        echo "  3. Try a skill:"
        echo "     ${BLUE}Design a REST API for user management${NC}"
        echo "     ${BLUE}Review my pull request${NC}"
        echo "     ${BLUE}Make this component responsive${NC}"
        echo ""
        echo "  4. Read the complete guide:"
        echo "     ${BLUE}cat CLAUDE_SKILLS_GUIDE_KR.md${NC}"
        echo ""
        print_info "💡 Tip: Skills activate automatically based on your request"
        echo ""
        ;;
        
    2)
        echo ""
        print_info "Setting up for ChatGPT..."

        # Create zip file
        ZIP_FILE="agent-skills-$(date +%Y%m%d).zip"
        print_info "Creating zip file: $ZIP_FILE"

        # Create temporary directory
        TEMP_DIR="$(mktemp -d)"
        cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities "$TEMP_DIR/"

        # Create zip
        (cd "$TEMP_DIR" && zip -r "$AGENT_SKILLS_DIR/$ZIP_FILE" . > /dev/null 2>&1)

        print_success "Zip file created: $ZIP_FILE"
        echo ""
        print_info "ChatGPT Custom GPT 설정 방법:"
        echo ""
        echo "=== 방법 1: ChatGPT 전용 템플릿 사용 (권장) ==="
        echo "1. 템플릿 복사:"
        echo "   cp -r templates/chatgpt-skill-template chatgpt/my-skill"
        echo ""
        echo "2. skills.md 작성:"
        echo "   - chatgpt/my-skill/skills.md 파일 편집"
        echo "   - 스킬의 목적, 사용 방법, 예시 등을 상세히 작성"
        echo ""
        echo "3. Custom GPT 생성:"
        echo "   - ChatGPT Builder에서 Custom GPT 생성"
        echo "   - Instructions 탭에 skills.md의 '7. Instructions 탭에 넣을 압축 버전' 복사"
        echo "   - 실제 값으로 교체하여 붙여넣기"
        echo ""
        echo "4. Knowledge 설정 (선택사항):"
        echo "   - 필요한 문서를 Knowledge에 업로드"
        echo ""
        echo "5. Actions 설정 (선택사항):"
        echo "   - OpenAPI 스키마 작성 및 연결"
        echo ""
        echo "템플릿 위치: templates/chatgpt-skill-template/"
        echo ""
        echo "=== 방법 2: Knowledge Base 업로드 (레거시) ==="
        echo "1. Go to ChatGPT and create a Custom GPT"
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
        print_info "참고: ChatGPT 전용 템플릿 방식이 더 체계적이고 관리하기 쉽습니다."
        echo "      templates/chatgpt-skill-template/README.md를 참고하세요."
        ;;
        
    3)
        echo ""
        print_info "Setting up for Gemini..."

        echo "Select Gemini setup mode:"
        echo "1) Standard Context (Creates GEMINI.md in root - Easiest)"
        echo "2) CLI Extension (Creates extension scaffold - Advanced/Official)"
        read -p "Enter choice (1-2): " gemini_mode

        if [ "$gemini_mode" = "2" ]; then
            print_info "Setting up Gemini CLI Extension..."
            
            EXT_DIR="gemini-extension"
            if [ -d "$EXT_DIR" ]; then
                read -p "Directory $EXT_DIR already exists. Overwrite? (y/n): " overwrite
                if [[ ! $overwrite =~ ^[Yy]$ ]]; then
                    print_warning "Aborted extension setup."
                else
                    cp -r templates/gemini-extension-template/* "$EXT_DIR/"
                    print_success "Extension scaffold updated in ./$EXT_DIR"
                fi
            else
                mkdir -p "$EXT_DIR"
                cp -r templates/gemini-extension-template/* "$EXT_DIR/"
                print_success "Extension scaffold created in ./$EXT_DIR"
            fi
            
            echo ""
            print_info "Gemini CLI Extension Setup Guide:"
            echo "1. Navigate to the extension directory: cd $EXT_DIR"
            echo "2. Edit 'GEMINI.md' to define your agent's playbook."
            echo "3. Edit 'tools.py' to add Python functions."
            echo "4. Use with Gemini CLI: gemini chat --extension ."
            
        else
            # Default to Standard Context
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
        fi

        # Common instructions
        echo ""
        print_info "Reference Guide created: GEMINI_SKILL_GUIDE.md"
        echo "Check GEMINI_SKILL_GUIDE.md for detailed official patterns."

        # Python integration (optional)
        echo ""
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
        ;;
        
    4)
        echo ""
        print_info "Setting up for all platforms..."
        echo ""

        # Claude setup
        print_info "━━━ Setting up Claude Code ━━━"

        # Project skills
        if git rev-parse --git-dir > /dev/null 2>&1; then
            mkdir -p ../.claude/skills
            COPIED_COUNT=$(copy_skills "../.claude/skills" "false")
            print_success "✓ Claude project skills: $COPIED_COUNT skills"
        fi

        # Personal skills
        mkdir -p ~/.claude/skills
        PERSONAL_COUNT=$(copy_skills "$HOME/.claude/skills" "false")
        print_success "✓ Claude personal skills: $PERSONAL_COUNT skills"
        echo ""

        # ChatGPT setup
        print_info "Setting up ChatGPT..."
        ZIP_FILE="agent-skills-$(date +%Y%m%d).zip"
        TEMP_DIR="$(mktemp -d)"
        cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities "$TEMP_DIR/"
        (cd "$TEMP_DIR" && zip -r "$AGENT_SKILLS_DIR/$ZIP_FILE" . > /dev/null 2>&1)
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
        print_info "Validating Claude Code skills..."
        if command -v python3 &> /dev/null; then
            # Check if Claude skills exist
            if [ -d "../.claude/skills" ]; then
                python3 validate_claude_skills.py
            else
                print_warning ".claude/skills directory not found."
                print_info "Please run option 1 (Claude setup) first."
            fi
        else
            print_warning "Python 3 not found, cannot validate."
            print_info "Please install Python 3 to use the validation feature."
        fi
        ;;

    6)
        echo ""
        print_info "Setting up MCP Integration (gemini-cli / codex-cli)..."
        echo ""

        # Step 1: Check prerequisites
        print_info "Step 1/5: Checking prerequisites..."

        GEMINI_CLI_INSTALLED=false
        CODEX_CLI_INSTALLED=false

        if command -v gemini &> /dev/null || command -v npx &> /dev/null; then
            print_success "Gemini CLI: Available"
            GEMINI_CLI_INSTALLED=true
        else
            print_warning "Gemini CLI: Not found (optional)"
        fi

        if command -v codex &> /dev/null; then
            print_success "Codex CLI: Available"
            CODEX_CLI_INSTALLED=true
        else
            print_warning "Codex CLI: Not found (optional)"
        fi

        if command -v python3 &> /dev/null; then
            print_success "Python 3: Available"
        else
            print_warning "Python 3: Not found (required for skill-query-handler)"
        fi

        echo ""

        # Step 2: Create MCP_CONTEXT.md
        print_info "Step 2/5: Creating MCP context file..."
        cat > "$AGENT_SKILLS_DIR/MCP_CONTEXT.md" << 'EOF'
# Agent Skills System for MCP (Model Context Protocol)

이 프로젝트는 Agent Skills 시스템을 사용합니다.
MCP 서버(gemini-cli, codex-cli 등)를 통해 작업할 때 이 문서를 참조하세요.

## 스킬 시스템 개요

각 스킬은 독립된 폴더에 다음 구조로 구성됩니다:
- **SKILL.md**: 스킬의 목적, 트리거 조건, 절차, 출력 포맷, 제약사항
- **지원 파일**: 템플릿, 예시, 참조 문서, 스크립트

## 스킬 로드 방법

### 방법 1: 직접 파일 읽기
```bash
# 특정 스킬 로드
cat .agent-skills/backend/api-design/SKILL.md

# 프롬프트와 함께 사용
gemini chat "$(cat .agent-skills/backend/api-design/SKILL.md)

사용자 관리 REST API를 설계해줘"
```

### 방법 2: Helper 스크립트 사용
```bash
# mcp-skill-loader.sh 사용
source .agent-skills/mcp-skill-loader.sh
load_skill backend/api-design

# 또는 직접 프롬프트에 포함
gemini chat "$(load_skill backend/api-design) 이제 설계해줘"
```

## 사용 가능한 스킬 카테고리

- **infrastructure/**: 인프라 설정 및 배포
- **backend/**: 백엔드 개발 및 API 설계
- **frontend/**: 프론트엔드 개발 및 UI/UX
- **documentation/**: 기술 문서 작성
- **code-quality/**: 코드 리뷰 및 품질 검사
- **search-analysis/**: 코드베이스 검색 및 분석
- **project-management/**: 프로젝트 관리 워크플로우
- **utilities/**: 유틸리티 및 헬퍼 도구

## 주요 스킬 목록

### Backend
- `backend/api-design`: REST/GraphQL API 설계

### Code Quality
- `code-quality/code-review`: 코드 리뷰 및 품질 검사

### Documentation
- `documentation/technical-writing`: 기술 문서 작성

### Search & Analysis
- `search-analysis/codebase-search`: 코드베이스 검색 및 분석

### Utilities
- `utilities/git-workflow`: Git 워크플로우 관리

## MCP 사용 패턴

### Gemini CLI 사용
```bash
# 1. 스킬 컨텍스트와 함께 질문
gemini chat "$(cat .agent-skills/MCP_CONTEXT.md)
$(cat .agent-skills/backend/api-design/SKILL.md)

이제 사용자 관리 API를 설계해줘"

# 2. 파일 첨부 방식
gemini chat --attach .agent-skills/backend/api-design/SKILL.md \
  "이 가이드라인을 따라 API를 설계해줘"
```

### Codex CLI 사용
```bash
# 스킬 컨텍스트 로드
codex-cli shell "$(cat .agent-skills/code-quality/code-review/SKILL.md)

이 코드를 리뷰해줘: $(cat src/app.ts)"
```

### Claude Code + MCP
```
"gemini-cli를 사용해서 .agent-skills/backend/api-design/SKILL.md의
가이드라인을 따라 사용자 관리 API를 설계해줘"
```

## 메타 규칙

- 스킬 지시사항을 일반 지식보다 우선시
- 여러 스킬이 적용 가능하면 가장 관련성 높은 것 선택
- 스킬 절차에서 요청되지 않은 정보는 추가하지 않음
- 보안 및 제약 규칙을 엄격히 준수

## 환경 설정

### Shell RC 파일에 추가 (~/.bashrc 또는 ~/.zshrc)
```bash
# Agent Skills 경로 설정
export AGENT_SKILLS_PATH="/path/to/.agent-skills"

# Helper 함수 로드
source "$AGENT_SKILLS_PATH/mcp-skill-loader.sh"
```

## 참고 문서

- MCP 설정 가이드: `.agent-skills/prompt/CLAUDE_MCP_GEMINI_CODEX_SETUP.md`
- Claude Skills 가이드: `.agent-skills/prompt/CLAUDE_SETUP_GUIDE.md`
- Gemini 설정: `.agent-skills/prompt/GEMINI_SETUP_PROMPT.md`
EOF
        print_success "MCP_CONTEXT.md created"

        # Step 3: Create mcp-skill-loader.sh
        echo ""
        print_info "Step 3/5: Creating MCP skill loader script..."
        cat > "$AGENT_SKILLS_DIR/mcp-skill-loader.sh" << 'EOF'
#!/bin/bash
# MCP Skill Loader Helper Script
# Usage: source mcp-skill-loader.sh

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export AGENT_SKILLS_PATH="$SCRIPT_DIR"

# Function to load a skill
load_skill() {
    local skill_path="$1"
    local full_path="$AGENT_SKILLS_PATH/$skill_path/SKILL.md"

    if [ -f "$full_path" ]; then
        cat "$full_path"
    else
        echo "Error: Skill not found at $full_path" >&2
        return 1
    fi
}

# Function to list available skills
list_skills() {
    echo "Available Skills:"
    echo ""
    find "$AGENT_SKILLS_PATH" -name "SKILL.md" -type f | while read -r skill; do
        local rel_path="${skill#$AGENT_SKILLS_PATH/}"
        local skill_dir="$(dirname "$rel_path")"
        echo "  - $skill_dir"
    done
}

# Function to load skill with context
load_skill_with_context() {
    local skill_path="$1"
    cat "$AGENT_SKILLS_PATH/MCP_CONTEXT.md"
    echo ""
    echo "---"
    echo ""
    load_skill "$skill_path"
}

# Function to search skills by keyword
search_skills() {
    local keyword="$1"
    echo "Searching for skills matching '$keyword':"
    echo ""
    grep -r -l "$keyword" "$AGENT_SKILLS_PATH"/*/*/SKILL.md 2>/dev/null | while read -r skill; do
        local rel_path="${skill#$AGENT_SKILLS_PATH/}"
        local skill_dir="$(dirname "$rel_path")"
        echo "  - $skill_dir"
    done
}

# Export functions
export -f load_skill
export -f list_skills
export -f load_skill_with_context
export -f search_skills

# Print usage if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "MCP Skill Loader"
    echo "================"
    echo ""
    echo "Usage: source mcp-skill-loader.sh"
    echo ""
    echo "Available functions:"
    echo "  load_skill <category>/<skill-name>        - Load a specific skill"
    echo "  load_skill_with_context <category>/<skill> - Load skill with MCP context"
    echo "  list_skills                                - List all available skills"
    echo "  search_skills <keyword>                    - Search skills by keyword"
    echo ""
    echo "Examples:"
    echo "  load_skill backend/api-design"
    echo "  load_skill_with_context code-quality/code-review"
    echo "  list_skills"
    echo "  search_skills 'REST API'"
fi
EOF
        chmod +x "$AGENT_SKILLS_DIR/mcp-skill-loader.sh"
        print_success "mcp-skill-loader.sh created"

        # Step 4: Make skill-query-handler.py executable
        echo ""
        print_info "Step 4/5: Setting up skill query handler..."
        if [ -f "$AGENT_SKILLS_DIR/skill-query-handler.py" ]; then
            chmod +x "$AGENT_SKILLS_DIR/skill-query-handler.py"
            print_success "skill-query-handler.py ready"

            # Test the handler
            if command -v python3 &> /dev/null; then
                SKILL_COUNT=$(python3 "$AGENT_SKILLS_DIR/skill-query-handler.py" list 2>/dev/null | grep -c "^  Description:" || echo "0")
                print_success "Skill query handler: $SKILL_COUNT skills indexed"
            fi
        else
            print_warning "skill-query-handler.py not found"
        fi

        # Step 5: Create shell configuration snippet (with auto-detect path)
        echo ""
        print_info "Step 5/6: Creating shell configuration snippet..."
        cat > "$AGENT_SKILLS_DIR/mcp-shell-config.sh" << 'EOFCONFIG'
#!/bin/bash
# Agent Skills MCP Integration
# Add this to your ~/.bashrc or ~/.zshrc
# Usage: source /path/to/.agent-skills/mcp-shell-config.sh

# Auto-detect script directory (works with both bash and zsh)
if [ -n "$BASH_SOURCE" ]; then
    _MCP_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then
    _MCP_SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
    _MCP_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# Set Agent Skills path
export AGENT_SKILLS_PATH="$_MCP_SCRIPT_DIR"

# Load helper functions
if [ -f "$AGENT_SKILLS_PATH/mcp-skill-loader.sh" ]; then
    source "$AGENT_SKILLS_PATH/mcp-skill-loader.sh"
fi

# Aliases for quick access
alias skills-list='list_skills'
alias skills-search='search_skills'
alias skills-load='load_skill'

# Skill Query Handler (Python)
alias skill-query='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query'
alias skill-match='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" match'
alias skill-list='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" list'
alias skill-stats='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" stats'

# Token optimization mode aliases (full, compact, toon)
alias skill-query-full='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query --mode full'
alias skill-query-compact='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query --mode compact'
alias skill-query-toon='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query --mode toon'

# MCP-specific functions with token optimization
# Usage: gemini-skill "query" [mode]
# Modes: full (default), compact (75% reduction), toon (95% reduction)
gemini-skill() {
    local query="$1"
    local mode="${2:-compact}"  # Default to compact mode
    local prompt=$(python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query "$query" --tool gemini --mode "$mode" 2>/dev/null)
    if [ -n "$prompt" ]; then
        echo "$prompt"
    else
        echo "No matching skill found for: $query"
    fi
}

codex-skill() {
    local query="$1"
    local mode="${2:-compact}"  # Default to compact mode
    local prompt=$(python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query "$query" --tool codex --mode "$mode" 2>/dev/null)
    if [ -n "$prompt" ]; then
        echo "$prompt"
    else
        echo "No matching skill found for: $query"
    fi
}

export -f gemini-skill
export -f codex-skill

# Cleanup temporary variable
unset _MCP_SCRIPT_DIR
EOFCONFIG
        chmod +x "$AGENT_SKILLS_DIR/mcp-shell-config.sh"
        print_success "mcp-shell-config.sh created (with auto-detect path)"

        # Step 6: Auto-configure shell RC file
        echo ""
        print_info "Step 6/6: Shell RC configuration..."
        echo ""
        echo "Do you want to automatically add MCP configuration to your shell?"
        echo "This will enable gemini-skill and codex-skill commands in new terminals."
        echo ""
        echo "1) Yes, configure automatically (Recommended)"
        echo "2) No, I'll configure manually"
        echo ""
        read -p "Enter choice (1-2): " shell_choice

        SHELL_CONFIGURED=false
        if [ "$shell_choice" = "1" ]; then
            # Detect shell type
            SHELL_RC=""
            if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
                SHELL_RC="$HOME/.zshrc"
                SHELL_NAME="zsh"
            elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/usr/bin/bash" ]; then
                SHELL_RC="$HOME/.bashrc"
                SHELL_NAME="bash"
            fi

            if [ -n "$SHELL_RC" ]; then
                # Check if already configured
                MARKER="# Agent Skills MCP Integration"
                if grep -q "$MARKER" "$SHELL_RC" 2>/dev/null; then
                    print_warning "MCP configuration already exists in $SHELL_RC"
                    echo ""
                    read -p "Do you want to update it? (y/n): " update_rc
                    if [[ $update_rc =~ ^[Yy]$ ]]; then
                        # Remove old configuration
                        sed -i.bak "/$MARKER/,/# End Agent Skills MCP/d" "$SHELL_RC" 2>/dev/null || \
                        sed -i '' "/$MARKER/,/# End Agent Skills MCP/d" "$SHELL_RC" 2>/dev/null
                        print_info "Removed old configuration"
                    else
                        SHELL_CONFIGURED=true
                    fi
                fi

                if [ "$SHELL_CONFIGURED" = "false" ]; then
                    # Add configuration with markers
                    echo "" >> "$SHELL_RC"
                    echo "$MARKER" >> "$SHELL_RC"
                    echo "# Auto-generated by setup.sh - $(date +%Y-%m-%d)" >> "$SHELL_RC"
                    echo "if [ -f \"$AGENT_SKILLS_DIR/mcp-shell-config.sh\" ]; then" >> "$SHELL_RC"
                    echo "    source \"$AGENT_SKILLS_DIR/mcp-shell-config.sh\"" >> "$SHELL_RC"
                    echo "fi" >> "$SHELL_RC"
                    echo "# End Agent Skills MCP" >> "$SHELL_RC"

                    print_success "Added MCP configuration to $SHELL_RC"
                    SHELL_CONFIGURED=true

                    # Verify by sourcing
                    echo ""
                    print_info "Verifying configuration..."
                    if bash -c "source \"$AGENT_SKILLS_DIR/mcp-shell-config.sh\" && type gemini-skill" &>/dev/null; then
                        print_success "gemini-skill function: OK"
                    else
                        print_warning "gemini-skill function: Not available (reload shell)"
                    fi
                fi
            else
                print_warning "Could not detect shell type. Please configure manually."
            fi
        fi

        echo ""
        print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        print_success "MCP Integration Setup Complete! 🎉"
        print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        if [ "$SHELL_CONFIGURED" = "true" ]; then
            print_info "📚 Quick Start:"
            echo ""
            echo "  1. Reload your shell or run:"
            echo "     ${BLUE}source $SHELL_RC${NC}"
            echo ""
            echo "  2. Test the configuration:"
            echo "     ${BLUE}gemini-skill \"Design a REST API\"${NC}"
        else
            print_info "📚 Manual Setup:"
            echo ""
            echo "  1. Add to your shell RC file:"
            echo "     ${BLUE}echo 'source $AGENT_SKILLS_DIR/mcp-shell-config.sh' >> ~/.zshrc${NC}"
            echo ""
            echo "  2. Reload your shell:"
            echo "     ${BLUE}source ~/.zshrc${NC}"
        fi
        echo ""
        print_info "📋 Available Commands:"
        echo ""
        echo "  ${GREEN}skill-list${NC}                    - List all available skills"
        echo "  ${GREEN}skill-match \"query\"${NC}           - Find matching skills"
        echo "  ${GREEN}skill-query \"query\"${NC}           - Generate prompt for query"
        echo "  ${GREEN}skill-stats${NC}                   - Show token usage statistics"
        echo ""
        print_info "🎯 Token Optimization Modes:"
        echo ""
        echo "  ${BLUE}full${NC}     - SKILL.md (~2000 tokens) - Maximum detail"
        echo "  ${BLUE}compact${NC}  - SKILL.compact.md (~500 tokens) - Balanced"
        echo "  ${BLUE}toon${NC}     - SKILL.toon (~100 tokens) - Minimal, fastest"
        echo ""
        print_info "🔧 Usage with MCP Tools:"
        echo ""
        echo "  ${BLUE}# Auto-match skill (default: compact mode)${NC}"
        echo "  gemini-skill \"Design a REST API for users\""
        echo ""
        echo "  ${BLUE}# Use with specific token mode${NC}"
        echo "  gemini-skill \"Design a REST API\" full    # Full detail"
        echo "  gemini-skill \"Design a REST API\" toon    # Minimal tokens"
        echo ""
        echo "  ${BLUE}# In Claude Code with MCP servers${NC}"
        echo "  \"gemini-cli를 사용해서 .agent-skills/backend/api-design/SKILL.md의"
        echo "   가이드라인을 따라 사용자 관리 API를 설계해줘\""
        echo ""
        print_info "📖 Documentation:"
        echo "  - Skill Query Handler: ${BLUE}.agent-skills/skill-query-handler.py --help${NC}"
        echo "  - MCP Context: ${BLUE}.agent-skills/MCP_CONTEXT.md${NC}"
        echo ""
        ;;

    7)
        echo ""
        print_info "Token Optimization - Generate Compact Skills"
        echo ""

        # Check if Python is available
        if ! command -v python3 &> /dev/null; then
            print_warning "Python 3 is required for token optimization"
            exit 1
        fi

        # Check if generate_compact_skills.py exists
        if [ ! -f "$AGENT_SKILLS_DIR/scripts/generate_compact_skills.py" ]; then
            print_warning "generate_compact_skills.py not found in scripts/"
            exit 1
        fi

        echo "Token optimization generates compact versions of SKILL.md files:"
        echo "  - SKILL.compact.md: ~75% token reduction"
        echo "  - SKILL.toon: ~95% token reduction"
        echo ""
        echo "Options:"
        echo "1) Generate all compact skills"
        echo "2) Generate for specific skill"
        echo "3) Show statistics only"
        echo "4) Clean generated files"
        echo "5) Back to main menu"
        echo ""
        read -p "Enter choice (1-5): " token_choice

        case "$token_choice" in
            1)
                print_info "Generating compact skills for all categories..."
                python3 "$AGENT_SKILLS_DIR/scripts/generate_compact_skills.py"
                ;;
            2)
                echo ""
                read -p "Enter skill path (e.g., backend/api-design): " skill_path
                python3 "$AGENT_SKILLS_DIR/scripts/generate_compact_skills.py" --skill "$skill_path"
                ;;
            3)
                print_info "Token usage statistics:"
                python3 "$AGENT_SKILLS_DIR/skill-query-handler.py" stats
                ;;
            4)
                print_info "Cleaning generated files..."
                python3 "$AGENT_SKILLS_DIR/scripts/generate_compact_skills.py" --clean
                ;;
            5)
                exec "$0"
                ;;
            *)
                print_warning "Invalid choice"
                ;;
        esac
        ;;

    8)
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

