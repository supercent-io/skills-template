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
echo "5) Exit"
echo ""
read -p "Enter your choice (1-5): " choice

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
        echo "1. Go to ChatGPT and create a Custom GPT"
        echo "2. Upload $ZIP_FILE to the Knowledge section"
        echo "3. Add this to Instructions:"
        echo ""
        cat << 'EOF'
You have access to Agent Skills in your knowledge base.
Each skill is in a folder with SKILL.md file.

When a task matches a skill's description:
1. Search for the relevant SKILL.md in knowledge base
2. Read and follow the instructions
3. Use referenced files as needed

Available skills include: api-design, code-review, technical-writing,
codebase-search, and more in the knowledge base.
EOF
        ;;
        
    3)
        echo ""
        print_info "Setting up for Gemini..."
        
        # Check if Python is installed
        if ! command -v python3 &> /dev/null; then
            print_warning "Python 3 is not installed"
            echo "Please install Python 3 to use Gemini integration"
            exit 1
        fi
        
        # Check if google-generativeai is installed
        if ! python3 -c "import google.generativeai" 2>/dev/null; then
            print_info "Installing google-generativeai..."
            pip3 install google-generativeai
        fi
        
        print_success "Python dependencies installed"
        echo ""
        print_info "Usage example:"
        cat << 'EOF'
from skill_loader import SkillLoader
import google.generativeai as genai

# Load skills
loader = SkillLoader('.agent-skills')
skill = loader.get_skill('api-design')

# Create prompt
prompt = f"{skill['body']}\n\nNow help me design an API for user management."

# Use with Gemini
genai.configure(api_key='YOUR_API_KEY')
model = genai.GenerativeModel('gemini-pro')
response = model.generate_content(prompt)
print(response.text)
EOF
        
        print_success "Gemini setup complete!"
        ;;
        
    4)
        echo ""
        print_info "Setting up for all platforms..."
        
        # Claude setup
        if git rev-parse --git-dir > /dev/null 2>&1; then
            mkdir -p .claude/skills
            cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities .claude/skills/ 2>/dev/null || true
            print_success "Claude project skills set up"
        fi
        
        mkdir -p ~/.claude/skills
        cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities ~/.claude/skills/ 2>/dev/null || true
        print_success "Claude personal skills set up"
        
        # ChatGPT setup
        ZIP_FILE="agent-skills-$(date +%Y%m%d).zip"
        TEMP_DIR=$(mktemp -d)
        cp -r infrastructure backend frontend documentation code-quality search-analysis project-management utilities "$TEMP_DIR/"
        cd "$TEMP_DIR"
        zip -r "$AGENT_SKILLS_DIR/$ZIP_FILE" . > /dev/null 2>&1
        cd "$AGENT_SKILLS_DIR"
        rm -rf "$TEMP_DIR"
        print_success "ChatGPT zip file created: $ZIP_FILE"
        
        # Gemini setup
        if command -v python3 &> /dev/null; then
            if ! python3 -c "import google.generativeai" 2>/dev/null; then
                pip3 install google-generativeai > /dev/null 2>&1
            fi
            print_success "Gemini dependencies installed"
        else
            print_warning "Python 3 not found, skipping Gemini setup"
        fi
        
        echo ""
        print_success "All platforms set up!"
        ;;
        
    5)
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

