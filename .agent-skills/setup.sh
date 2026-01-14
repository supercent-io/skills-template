#!/bin/bash

# Agent Skills Setup Script v3.3.1
# Multi-Agent Workflow with Auto-Detection, Progressive Configuration & Model Mapping
# Supports: Claude Code, Gemini-CLI, Codex-CLI
#
# Usage:
#   ./setup.sh              # Interactive mode
#   ./setup.sh --auto       # Non-interactive auto-configure
#   ./setup.sh --quick      # Quick setup (skip prompts, use defaults)
#   ./setup.sh --diagnose   # Run system diagnostics
#   ./setup.sh --help       # Show help

set -e

# ============================================================
# Command Line Arguments
# ============================================================
INSTALL_MODE="interactive"
SKIP_MCP_PROMPTS=false
SKIP_SHELL_RC_PROMPT=false
SKIP_SHELL_RC=false
SILENT_MODE=false
RUN_DIAGNOSE=false

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto)
                INSTALL_MODE="auto"
                SKIP_MCP_PROMPTS=true
                SKIP_SHELL_RC_PROMPT=true
                shift
                ;;
            --quick)
                INSTALL_MODE="quick"
                SKIP_MCP_PROMPTS=true
                SKIP_SHELL_RC_PROMPT=true
                shift
                ;;
            --silent)
                INSTALL_MODE="silent"
                SKIP_MCP_PROMPTS=true
                SKIP_SHELL_RC_PROMPT=true
                SKIP_SHELL_RC=true
                SILENT_MODE=true
                shift
                ;;
            --no-shell-rc)
                SKIP_SHELL_RC=true
                shift
                ;;
            --diagnose)
                RUN_DIAGNOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
}

show_help() {
    cat << 'EOF'
Agent Skills Setup Script v3.3.1

Usage:
  ./setup.sh                Interactive mode (default)
  ./setup.sh --auto         Non-interactive auto-configure
  ./setup.sh --quick        Quick setup (defaults, no prompts)
  ./setup.sh --silent       Silent mode (no output, skip shell RC, for AI agents)
  ./setup.sh --diagnose     Run MCP server diagnostics and health checks
  ./setup.sh --no-shell-rc  Skip ~/.zshrc or ~/.bashrc modification
  ./setup.sh --help         Show this help

Options:
  --auto         Auto-configure all settings non-interactively
  --quick        Same as --auto but for quick setup
  --silent       Silent mode: no output, skips shell RC modification
                 Best for AI agents (Claude, etc.)
  --diagnose     Run comprehensive system diagnostics:
                 - MCP server health checks
                 - Connection tests (gemini-cli, codex-cli)
                 - Configuration validation
  --no-shell-rc  Skip shell RC modification (can combine with --auto)

One-Liner Installation (for developers):
  git clone https://github.com/supercent-io/skills-template.git _tmp && \
  mv _tmp/.agent-skills . && rm -rf _tmp && \
  cd .agent-skills && chmod +x setup.sh && ./setup.sh --quick

For AI Agents (recommended):
  cd .agent-skills && ./setup.sh --silent

Troubleshooting:
  ./setup.sh --diagnose     # Check MCP server health

For more information: https://github.com/supercent-io/skills-template
EOF
}

# ============================================================
# Colors & Constants
# ============================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_SKILLS_DIR="$SCRIPT_DIR"
PROJECT_DIR="$(dirname "$AGENT_SKILLS_DIR")"

# Skill categories
SKILL_CATEGORIES=(backend frontend code-quality infrastructure documentation project-management search-analysis utilities)

# ============================================================
# Global State Variables (Auto-detected)
# ============================================================
HAS_CLAUDE_CLI=false
HAS_GEMINI_MCP=false
HAS_CODEX_MCP=false
HAS_PYTHON3=false
WORKFLOW_TYPE="standalone"  # standalone, claude-only, claude-gemini, claude-codex, full-multiagent
PERFORMANCE_PRESET="balanced"  # high-performance, balanced, cost-effective

# ============================================================
# Model Definitions (2025/2026)
# ============================================================
# Claude Models
CLAUDE_OPUS="claude-opus-4-5-20251101"
CLAUDE_SONNET="claude-sonnet-4-5-20241022"
CLAUDE_HAIKU="claude-haiku-4-5-20241022"

# Gemini Models
GEMINI_3_PRO="gemini-3-pro"
GEMINI_3_FLASH="gemini-3-flash"
GEMINI_25_PRO="gemini-2.5-pro"
GEMINI_25_FLASH="gemini-2.5-flash"

# OpenAI/Codex Models
GPT5_CODEX="gpt-5.2-codex"
GPT5_CODEX_MINI="gpt-5.1-codex-mini"
GPT41="gpt-4.1"
GPT41_MINI="gpt-4.1-mini"

# Role-based Model Variables (set by configure_models)
MODEL_ORCHESTRATOR=""
MODEL_ANALYST=""
MODEL_EXECUTOR=""
PROVIDER_ORCHESTRATOR=""
PROVIDER_ANALYST=""
PROVIDER_EXECUTOR=""

# ============================================================
# Helper Functions (respect SILENT_MODE)
# ============================================================
print_info() { $SILENT_MODE || echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { $SILENT_MODE || echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { $SILENT_MODE || echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { $SILENT_MODE || echo -e "${RED}❌ $1${NC}"; }
print_header() { $SILENT_MODE || echo -e "${CYAN}━━━ $1 ━━━${NC}"; }
print_status() {
    $SILENT_MODE && return
    if [ "$2" = "true" ]; then
        echo -e "  ${GREEN}[✅]${NC} $1"
    else
        echo -e "  ${RED}[❌]${NC} $1"
    fi
}

# ============================================================
# 1. MCP Environment Auto-Detection
# ============================================================
detect_mcp_environment() {
    $SILENT_MODE || echo ""
    print_header "MCP Environment Auto-Detection"
    $SILENT_MODE || echo ""

    # Check Python3
    if command -v python3 &> /dev/null; then
        HAS_PYTHON3=true
        print_status "Python3" "true"
    else
        HAS_PYTHON3=false
        print_status "Python3 (토큰 최적화에 필요)" "false"
    fi

    # Check Claude CLI
    if command -v claude &> /dev/null; then
        HAS_CLAUDE_CLI=true
        print_status "Claude CLI" "true"

        # Get MCP server list (single call for efficiency)
        local mcp_list=""
        mcp_list=$(claude mcp list 2>/dev/null || echo "")

        # Check Gemini-CLI MCP
        if echo "$mcp_list" | grep -q "gemini-cli"; then
            HAS_GEMINI_MCP=true
            print_status "gemini-cli MCP Server" "true"
        else
            HAS_GEMINI_MCP=false
            print_status "gemini-cli MCP Server" "false"
        fi

        # Check Codex-CLI MCP
        if echo "$mcp_list" | grep -q "codex-cli"; then
            HAS_CODEX_MCP=true
            print_status "codex-cli MCP Server" "true"
        else
            HAS_CODEX_MCP=false
            print_status "codex-cli MCP Server" "false"
        fi
    else
        HAS_CLAUDE_CLI=false
        print_status "Claude CLI" "false"
        print_warning "  → Claude CLI 미설치: npm install -g @anthropic-ai/claude-code"
    fi

    # Determine workflow type
    determine_workflow_type
    $SILENT_MODE || echo ""
    $SILENT_MODE || echo -e "  ${BOLD}Workflow Type:${NC} ${CYAN}$WORKFLOW_TYPE${NC}"
    $SILENT_MODE || echo ""
}

# ============================================================
# 2. Workflow Type Determination
# ============================================================
determine_workflow_type() {
    if ! $HAS_CLAUDE_CLI; then
        WORKFLOW_TYPE="standalone"
    elif $HAS_GEMINI_MCP && $HAS_CODEX_MCP; then
        WORKFLOW_TYPE="full-multiagent"
    elif $HAS_GEMINI_MCP; then
        WORKFLOW_TYPE="claude-gemini"
    elif $HAS_CODEX_MCP; then
        WORKFLOW_TYPE="claude-codex"
    else
        WORKFLOW_TYPE="claude-only"
    fi

    # Auto-configure models based on workflow type
    configure_models_for_workflow
}

# ============================================================
# 2.1 Model Configuration for Workflow
# ============================================================
configure_models_for_workflow() {
    case "$WORKFLOW_TYPE" in
        # Claude-Only: Use Claude models for all roles
        "claude-only")
            MODEL_ORCHESTRATOR="$CLAUDE_OPUS"
            MODEL_ANALYST="$CLAUDE_SONNET"       # Sonnet as Analyst (Gemini role)
            MODEL_EXECUTOR="$CLAUDE_HAIKU"       # Haiku as Executor (Codex role)
            PROVIDER_ORCHESTRATOR="claude"
            PROVIDER_ANALYST="claude"
            PROVIDER_EXECUTOR="claude"
            ;;

        # Claude + Gemini: Gemini for analysis
        "claude-gemini")
            MODEL_ORCHESTRATOR="$CLAUDE_OPUS"
            MODEL_ANALYST="$GEMINI_3_PRO"        # Gemini Pro for large analysis
            MODEL_EXECUTOR="$CLAUDE_HAIKU"       # Claude Haiku for execution
            PROVIDER_ORCHESTRATOR="claude"
            PROVIDER_ANALYST="gemini"
            PROVIDER_EXECUTOR="claude"
            ;;

        # Claude + Codex: Codex for execution
        "claude-codex")
            MODEL_ORCHESTRATOR="$CLAUDE_OPUS"
            MODEL_ANALYST="$CLAUDE_SONNET"       # Claude Sonnet for analysis
            MODEL_EXECUTOR="$GPT5_CODEX"         # GPT-5 Codex for execution
            PROVIDER_ORCHESTRATOR="claude"
            PROVIDER_ANALYST="claude"
            PROVIDER_EXECUTOR="openai"
            ;;

        # Full Multi-Agent: Optimal model for each role
        "full-multiagent")
            MODEL_ORCHESTRATOR="$CLAUDE_OPUS"
            MODEL_ANALYST="$GEMINI_3_PRO"        # Gemini Pro for deep analysis
            MODEL_EXECUTOR="$GPT5_CODEX"         # GPT-5 Codex for execution
            PROVIDER_ORCHESTRATOR="claude"
            PROVIDER_ANALYST="gemini"
            PROVIDER_EXECUTOR="openai"
            ;;

        # Gemini-Only (for future support)
        "gemini-only")
            MODEL_ORCHESTRATOR="$GEMINI_3_PRO"
            MODEL_ANALYST="$GEMINI_3_FLASH"
            MODEL_EXECUTOR="$GEMINI_3_FLASH"
            PROVIDER_ORCHESTRATOR="gemini"
            PROVIDER_ANALYST="gemini"
            PROVIDER_EXECUTOR="gemini"
            ;;

        # Standalone/Default
        *)
            MODEL_ORCHESTRATOR="$CLAUDE_SONNET"
            MODEL_ANALYST="$CLAUDE_SONNET"
            MODEL_EXECUTOR="$CLAUDE_HAIKU"
            PROVIDER_ORCHESTRATOR="claude"
            PROVIDER_ANALYST="claude"
            PROVIDER_EXECUTOR="claude"
            ;;
    esac

    # Apply performance preset adjustments
    apply_performance_preset
}

# ============================================================
# 2.2 Performance Preset Application
# ============================================================
apply_performance_preset() {
    case "$PERFORMANCE_PRESET" in
        "high-performance")
            # Use highest capability models
            [ "$PROVIDER_ORCHESTRATOR" = "claude" ] && MODEL_ORCHESTRATOR="$CLAUDE_OPUS"
            [ "$PROVIDER_ANALYST" = "gemini" ] && MODEL_ANALYST="$GEMINI_3_PRO"
            [ "$PROVIDER_ANALYST" = "claude" ] && MODEL_ANALYST="$CLAUDE_OPUS"
            [ "$PROVIDER_EXECUTOR" = "openai" ] && MODEL_EXECUTOR="$GPT5_CODEX"
            [ "$PROVIDER_EXECUTOR" = "claude" ] && MODEL_EXECUTOR="$CLAUDE_SONNET"
            ;;
        "balanced")
            # Default balanced configuration (already set)
            ;;
        "cost-effective")
            # Use lightweight models
            [ "$PROVIDER_ORCHESTRATOR" = "claude" ] && MODEL_ORCHESTRATOR="$CLAUDE_SONNET"
            [ "$PROVIDER_ANALYST" = "gemini" ] && MODEL_ANALYST="$GEMINI_3_FLASH"
            [ "$PROVIDER_ANALYST" = "claude" ] && MODEL_ANALYST="$CLAUDE_HAIKU"
            [ "$PROVIDER_EXECUTOR" = "openai" ] && MODEL_EXECUTOR="$GPT5_CODEX_MINI"
            [ "$PROVIDER_EXECUTOR" = "claude" ] && MODEL_EXECUTOR="$CLAUDE_HAIKU"
            ;;
    esac
}

# ============================================================
# 2.3 Print Model Configuration
# ============================================================
print_model_config() {
    echo ""
    print_header "Model Configuration"
    echo ""
    echo -e "  ${BOLD}Performance Preset:${NC} ${CYAN}$PERFORMANCE_PRESET${NC}"
    echo ""
    echo "  ┌─────────────┬──────────┬─────────────────────────────┐"
    echo "  │ Role        │ Provider │ Model                       │"
    echo "  ├─────────────┼──────────┼─────────────────────────────┤"
    printf "  │ Orchestrator│ %-8s │ %-27s │\n" "$PROVIDER_ORCHESTRATOR" "$MODEL_ORCHESTRATOR"
    printf "  │ Analyst     │ %-8s │ %-27s │\n" "$PROVIDER_ANALYST" "$MODEL_ANALYST"
    printf "  │ Executor    │ %-8s │ %-27s │\n" "$PROVIDER_EXECUTOR" "$MODEL_EXECUTOR"
    echo "  └─────────────┴──────────┴─────────────────────────────┘"
    echo ""
}

# ============================================================
# 2.4 Interactive Model Configuration
# ============================================================
configure_models_interactive() {
    echo ""
    print_header "Model Configuration"
    echo ""
    echo "현재 Workflow: $WORKFLOW_TYPE"
    echo ""
    echo "성능 프리셋 선택:"
    echo ""
    echo "  1) High Performance (고성능)"
    echo "     → Opus/Pro/Codex - 복잡한 작업에 최적"
    echo ""
    echo "  2) Balanced (균형) - 권장"
    echo "     → Sonnet/Flash/Codex-mini - 비용/성능 균형"
    echo ""
    echo "  3) Cost-Effective (비용 효율)"
    echo "     → Haiku/Flash/Mini - 빠르고 저렴"
    echo ""
    echo "  4) Custom (사용자 지정)"
    echo ""
    read -p "선택 (1-4): " preset_choice

    case "$preset_choice" in
        1) PERFORMANCE_PRESET="high-performance" ;;
        2) PERFORMANCE_PRESET="balanced" ;;
        3) PERFORMANCE_PRESET="cost-effective" ;;
        4) configure_models_custom ;;
        *) PERFORMANCE_PRESET="balanced" ;;
    esac

    configure_models_for_workflow
    print_model_config
}

# ============================================================
# 2.5 Custom Model Configuration
# ============================================================
configure_models_custom() {
    echo ""
    print_header "Custom Model Configuration"
    echo ""

    # Orchestrator model selection
    echo "Orchestrator 모델 선택 (계획 수립, 코드 생성):"
    echo "  1) Claude Opus 4.5 (최고 성능)"
    echo "  2) Claude Sonnet 4.5 (균형)"
    echo "  3) Claude Haiku 4.5 (빠름)"
    read -p "선택 (1-3): " orch_choice
    case "$orch_choice" in
        1) MODEL_ORCHESTRATOR="$CLAUDE_OPUS" ;;
        2) MODEL_ORCHESTRATOR="$CLAUDE_SONNET" ;;
        3) MODEL_ORCHESTRATOR="$CLAUDE_HAIKU" ;;
        *) MODEL_ORCHESTRATOR="$CLAUDE_SONNET" ;;
    esac
    PROVIDER_ORCHESTRATOR="claude"
    echo ""

    # Analyst model selection
    echo "Analyst 모델 선택 (대용량 분석, 리서치):"
    if $HAS_GEMINI_MCP; then
        echo "  1) Gemini 3 Pro (1M 컨텍스트, 최고 분석)"
        echo "  2) Gemini 3 Flash (빠르고 저렴)"
        echo "  3) Claude Sonnet 4.5"
        echo "  4) Claude Haiku 4.5"
        read -p "선택 (1-4): " analyst_choice
        case "$analyst_choice" in
            1) MODEL_ANALYST="$GEMINI_3_PRO"; PROVIDER_ANALYST="gemini" ;;
            2) MODEL_ANALYST="$GEMINI_3_FLASH"; PROVIDER_ANALYST="gemini" ;;
            3) MODEL_ANALYST="$CLAUDE_SONNET"; PROVIDER_ANALYST="claude" ;;
            4) MODEL_ANALYST="$CLAUDE_HAIKU"; PROVIDER_ANALYST="claude" ;;
            *) MODEL_ANALYST="$GEMINI_3_FLASH"; PROVIDER_ANALYST="gemini" ;;
        esac
    else
        echo "  1) Claude Sonnet 4.5"
        echo "  2) Claude Haiku 4.5"
        read -p "선택 (1-2): " analyst_choice
        case "$analyst_choice" in
            1) MODEL_ANALYST="$CLAUDE_SONNET" ;;
            2) MODEL_ANALYST="$CLAUDE_HAIKU" ;;
            *) MODEL_ANALYST="$CLAUDE_SONNET" ;;
        esac
        PROVIDER_ANALYST="claude"
    fi
    echo ""

    # Executor model selection
    echo "Executor 모델 선택 (명령 실행, 빌드):"
    if $HAS_CODEX_MCP; then
        echo "  1) GPT-5.2 Codex (최고 코딩)"
        echo "  2) GPT-5.1 Codex Mini (경량)"
        echo "  3) Claude Haiku 4.5"
        read -p "선택 (1-3): " exec_choice
        case "$exec_choice" in
            1) MODEL_EXECUTOR="$GPT5_CODEX"; PROVIDER_EXECUTOR="openai" ;;
            2) MODEL_EXECUTOR="$GPT5_CODEX_MINI"; PROVIDER_EXECUTOR="openai" ;;
            3) MODEL_EXECUTOR="$CLAUDE_HAIKU"; PROVIDER_EXECUTOR="claude" ;;
            *) MODEL_EXECUTOR="$GPT5_CODEX_MINI"; PROVIDER_EXECUTOR="openai" ;;
        esac
    else
        echo "  1) Claude Haiku 4.5 (빠름)"
        echo "  2) Claude Sonnet 4.5"
        read -p "선택 (1-2): " exec_choice
        case "$exec_choice" in
            1) MODEL_EXECUTOR="$CLAUDE_HAIKU" ;;
            2) MODEL_EXECUTOR="$CLAUDE_SONNET" ;;
            *) MODEL_EXECUTOR="$CLAUDE_HAIKU" ;;
        esac
        PROVIDER_EXECUTOR="claude"
    fi

    PERFORMANCE_PRESET="custom"
}

# ============================================================
# 2.6 Generate Model Config File
# ============================================================
generate_model_config_file() {
    cat > "$AGENT_SKILLS_DIR/model-config.env" << EOF
# Multi-Agent Model Configuration
# Generated by setup.sh v3.1 - $(date +%Y-%m-%d)
# Workflow: $WORKFLOW_TYPE | Preset: $PERFORMANCE_PRESET

# Environment
export MCP_WORKFLOW_TYPE="$WORKFLOW_TYPE"
export MCP_PERFORMANCE_PRESET="$PERFORMANCE_PRESET"

# Model Assignments
export MODEL_ORCHESTRATOR="$MODEL_ORCHESTRATOR"
export MODEL_ANALYST="$MODEL_ANALYST"
export MODEL_EXECUTOR="$MODEL_EXECUTOR"

# Provider Assignments
export PROVIDER_ORCHESTRATOR="$PROVIDER_ORCHESTRATOR"
export PROVIDER_ANALYST="$PROVIDER_ANALYST"
export PROVIDER_EXECUTOR="$PROVIDER_EXECUTOR"

# Claude Task Tool Model Hints
# Usage in Claude Code: Task tool with model parameter
#   orchestrator tasks → model: "opus" or "sonnet"
#   analyst tasks → model: "sonnet" (or use gemini-cli)
#   executor tasks → model: "haiku" (or use codex-cli)
export CLAUDE_TASK_ORCHESTRATOR="opus"
export CLAUDE_TASK_ANALYST="sonnet"
export CLAUDE_TASK_EXECUTOR="haiku"
EOF

    print_success "model-config.env 생성됨"
}

# ============================================================
# 2.7 MCP Server Health Check
# ============================================================
verify_mcp_servers() {
    echo ""
    print_header "MCP Server Health Check"
    echo ""

    local all_healthy=true

    # Check Claude CLI
    if command -v claude &> /dev/null; then
        print_status "Claude CLI installed" "true"

        # Test Claude CLI responsiveness (version check is lightweight)
        if claude --version &> /dev/null 2>&1; then
            print_status "Claude CLI responsive" "true"
        else
            print_status "Claude CLI responsive" "false"
            all_healthy=false
        fi

        # Get MCP server list with connection status (single call)
        local mcp_health_output=""
        mcp_health_output=$(claude mcp list 2>/dev/null || echo "")

    else
        print_status "Claude CLI installed" "false"
        print_warning "  → Install: npm install -g @anthropic-ai/claude-code"
        all_healthy=false
        return 1
    fi

    # Check Gemini-CLI MCP (parse from mcp list output)
    if $HAS_GEMINI_MCP; then
        print_status "gemini-cli MCP registered" "true"

        # Check connection status from 'claude mcp list' output
        # Format: "gemini-cli: npx -y gemini-mcp-tool - ✓ Connected"
        if echo "$mcp_health_output" | grep -E "gemini-cli.*Connected" &>/dev/null; then
            print_status "gemini-cli MCP connected" "true"
        elif echo "$mcp_health_output" | grep -E "gemini-cli.*Error" &>/dev/null; then
            print_status "gemini-cli MCP connected" "false"
            print_warning "  → 연결 오류 발생"
            all_healthy=false
        else
            print_status "gemini-cli MCP status" "true"
            print_info "  → 상태 확인: claude mcp list"
        fi
    else
        print_status "gemini-cli MCP registered" "false"
        print_info "  → Add: claude mcp add gemini-cli -s user -- npx -y gemini-mcp-tool"
    fi

    # Check Codex-CLI MCP (parse from mcp list output)
    if $HAS_CODEX_MCP; then
        print_status "codex-cli MCP registered" "true"

        # Check connection status from 'claude mcp list' output
        if echo "$mcp_health_output" | grep -E "codex-cli.*Connected" &>/dev/null; then
            print_status "codex-cli MCP connected" "true"
        elif echo "$mcp_health_output" | grep -E "codex-cli.*Error" &>/dev/null; then
            print_status "codex-cli MCP connected" "false"
            print_warning "  → 연결 오류 발생"
            all_healthy=false
        else
            print_status "codex-cli MCP status" "true"
            print_info "  → 상태 확인: claude mcp list"
        fi
    else
        print_status "codex-cli MCP registered" "false"
        print_info "  → Add: claude mcp add codex-cli -s user -- npx -y @openai/codex-mcp"
    fi

    echo ""
    if $all_healthy; then
        print_success "All MCP servers healthy"
    else
        print_warning "Some MCP servers need attention"
    fi

    return 0
}

# ============================================================
# 2.8 Generate Agent Routing Configuration
# ============================================================
generate_agent_routing_config() {
    local config_file="$AGENT_SKILLS_DIR/agent-routing.yaml"

    cat > "$config_file" << EOF
# Agent Routing Configuration
# Generated by setup.sh v3.3 - $(date +%Y-%m-%d)
# Workflow: $WORKFLOW_TYPE | Preset: $PERFORMANCE_PRESET

version: "1.0"
workflow_type: "$WORKFLOW_TYPE"
performance_preset: "$PERFORMANCE_PRESET"

# Agent Definitions
agents:
  orchestrator:
    provider: "$PROVIDER_ORCHESTRATOR"
    model: "$MODEL_ORCHESTRATOR"
    role: "Planning, code generation, skill interpretation"
    tools:
      - Read
      - Write
      - Edit
      - Glob
      - Grep
      - Task
      - TodoWrite

  analyst:
    provider: "$PROVIDER_ANALYST"
    model: "$MODEL_ANALYST"
    role: "Large-scale analysis, research, code review"
    mcp_tool: "ask-gemini"
    enabled: $HAS_GEMINI_MCP
    capabilities:
      - "1M+ token context"
      - "Deep code analysis"
      - "Architecture review"
      - "Research synthesis"

  executor:
    provider: "$PROVIDER_EXECUTOR"
    model: "$MODEL_EXECUTOR"
    role: "Command execution, builds, deployments"
    mcp_tool: "shell"
    enabled: $HAS_CODEX_MCP
    capabilities:
      - "Sandboxed execution"
      - "Long-running tasks"
      - "Docker/K8s operations"
      - "CI/CD pipelines"

# Task Routing Rules
routing:
  # Analysis tasks → Analyst (Gemini)
  analysis:
    patterns:
      - "분석"
      - "리뷰"
      - "코드 리뷰"
      - "아키텍처"
      - "전체.*분석"
      - "패턴.*분석"
    agent: "analyst"
    fallback: "orchestrator"

  # Execution tasks → Executor (Codex)
  execution:
    patterns:
      - "실행"
      - "빌드"
      - "테스트"
      - "배포"
      - "docker"
      - "npm"
      - "git"
    agent: "executor"
    fallback: "orchestrator"

  # Planning/coding → Orchestrator (Claude)
  orchestration:
    patterns:
      - "계획"
      - "설계"
      - "구현"
      - "작성"
      - "생성"
      - "수정"
    agent: "orchestrator"

# Workflow Templates
templates:
  api-development:
    name: "API Development"
    steps:
      - agent: orchestrator
        action: "Load api-design skill, create spec"
      - agent: analyst
        action: "Analyze existing API patterns"
        condition: "if codebase > 10 files"
      - agent: orchestrator
        action: "Implement API code"
      - agent: executor
        action: "Run tests and build"
      - agent: orchestrator
        action: "Generate documentation"

  code-review:
    name: "Code Review"
    steps:
      - agent: analyst
        action: "Deep code analysis with gemini"
      - agent: orchestrator
        action: "Summarize findings, suggest improvements"

  deployment:
    name: "Deployment Pipeline"
    steps:
      - agent: orchestrator
        action: "Prepare deployment config"
      - agent: executor
        action: "Run build and tests"
      - agent: executor
        action: "Deploy to environment"
      - agent: orchestrator
        action: "Verify deployment status"

# Fallback Behavior
fallback:
  when_gemini_unavailable: "Use Claude Sonnet for analysis"
  when_codex_unavailable: "Use Claude Bash tool for execution"
  retry_attempts: 2
  timeout_seconds: 30
EOF

    print_success "agent-routing.yaml 생성됨"
}

# ============================================================
# 2.9 System Diagnostics
# ============================================================
run_diagnostics() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🔍 Agent Skills System Diagnostics v3.3.1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 1. Environment Check
    print_header "1. Environment Check"
    echo ""
    echo "  OS: $(uname -s) $(uname -r)"
    echo "  Shell: $SHELL"
    echo "  PWD: $(pwd)"
    echo "  Agent Skills: $AGENT_SKILLS_DIR"
    echo ""

    # 2. Dependencies
    print_header "2. Dependencies"
    echo ""
    print_status "bash" "$(command -v bash &>/dev/null && echo true || echo false)"
    print_status "python3" "$HAS_PYTHON3"
    print_status "node/npm" "$(command -v node &>/dev/null && echo true || echo false)"
    print_status "git" "$(command -v git &>/dev/null && echo true || echo false)"
    echo ""

    # 3. MCP Environment
    detect_mcp_environment

    # 4. Health Check
    if $HAS_CLAUDE_CLI; then
        verify_mcp_servers
    fi

    # 5. Configuration Files
    echo ""
    print_header "5. Configuration Files"
    echo ""
    print_status "model-config.env" "$([ -f \"$AGENT_SKILLS_DIR/model-config.env\" ] && echo true || echo false)"
    print_status "agent-routing.yaml" "$([ -f \"$AGENT_SKILLS_DIR/agent-routing.yaml\" ] && echo true || echo false)"
    print_status "mcp-shell-config.sh" "$([ -f \"$AGENT_SKILLS_DIR/mcp-shell-config.sh\" ] && echo true || echo false)"
    print_status "CLAUDE.md" "$([ -f \"$PROJECT_DIR/CLAUDE.md\" ] && echo true || echo false)"
    echo ""

    # 6. Skills Statistics
    print_header "6. Skills Statistics"
    echo ""
    local skill_count=$(find "$AGENT_SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    local toon_count=$(find "$AGENT_SKILLS_DIR" -name "SKILL.toon" 2>/dev/null | wc -l | tr -d ' ')
    local compact_count=$(find "$AGENT_SKILLS_DIR" -name "SKILL.compact.md" 2>/dev/null | wc -l | tr -d ' ')
    echo "  SKILL.md files: $skill_count"
    echo "  SKILL.toon files: $toon_count"
    echo "  SKILL.compact.md files: $compact_count"
    echo ""

    # 7. Workflow Summary
    print_header "7. Workflow Summary"
    echo ""
    echo -e "  Workflow Type: ${CYAN}$WORKFLOW_TYPE${NC}"
    echo -e "  Performance Preset: ${CYAN}$PERFORMANCE_PRESET${NC}"
    echo ""
    echo "  Agent Configuration:"
    echo "    Orchestrator: $PROVIDER_ORCHESTRATOR / $MODEL_ORCHESTRATOR"
    echo "    Analyst: $PROVIDER_ANALYST / $MODEL_ANALYST"
    echo "    Executor: $PROVIDER_EXECUTOR / $MODEL_EXECUTOR"
    echo ""

    # 8. Recommendations
    print_header "8. Recommendations"
    echo ""

    local recommendations=()

    if ! $HAS_CLAUDE_CLI; then
        recommendations+=("Install Claude CLI: npm install -g @anthropic-ai/claude-code")
    fi
    if ! $HAS_GEMINI_MCP && $HAS_CLAUDE_CLI; then
        recommendations+=("Add Gemini MCP for enhanced analysis: claude mcp add gemini-cli -s user -- npx -y gemini-mcp-tool")
    fi
    if ! $HAS_CODEX_MCP && $HAS_CLAUDE_CLI; then
        recommendations+=("Add Codex MCP for execution: claude mcp add codex-cli -s user -- npx -y @openai/codex-mcp")
    fi
    if [ ! -f "$AGENT_SKILLS_DIR/agent-routing.yaml" ]; then
        recommendations+=("Generate routing config: Run setup.sh --auto")
    fi
    if [ "$toon_count" -lt "$skill_count" ]; then
        recommendations+=("Generate token-optimized skills: python3 scripts/generate_compact_skills.py")
    fi

    if [ ${#recommendations[@]} -eq 0 ]; then
        print_success "All systems optimal!"
    else
        for rec in "${recommendations[@]}"; do
            echo -e "  ${YELLOW}→${NC} $rec"
        done
    fi
    echo ""

    print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Diagnostics Complete"
    print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ============================================================
# 2.10 Workflow Template Selection
# ============================================================
select_workflow_template() {
    echo ""
    print_header "Workflow Template Selection"
    echo ""
    echo "프로젝트 유형에 맞는 워크플로우를 선택하세요:"
    echo ""
    echo "  1) API Development (API 개발)"
    echo "     → API 설계 → 패턴 분석 → 구현 → 테스트"
    echo ""
    echo "  2) Code Review (코드 리뷰)"
    echo "     → 대용량 분석 → 개선점 요약"
    echo ""
    echo "  3) Deployment Pipeline (배포 파이프라인)"
    echo "     → 설정 → 빌드 → 배포 → 검증"
    echo ""
    echo "  4) Custom (사용자 정의)"
    echo ""
    read -p "선택 (1-4): " template_choice

    case "$template_choice" in
        1) echo "API Development 템플릿 적용" ;;
        2) echo "Code Review 템플릿 적용" ;;
        3) echo "Deployment Pipeline 템플릿 적용" ;;
        4) echo "Custom 워크플로우 - agent-routing.yaml 직접 편집" ;;
        *) echo "기본 워크플로우 사용" ;;
    esac
    echo ""
}

# ============================================================
# 3. Skills Copy Functions
# ============================================================
copy_skills() {
    local dest="$1"
    local verbose="$2"
    local copied=0

    for category in "${SKILL_CATEGORIES[@]}"; do
        if [ -d "$AGENT_SKILLS_DIR/$category" ]; then
            cp -r "$AGENT_SKILLS_DIR/$category" "$dest/"
            local count=$(find "$AGENT_SKILLS_DIR/$category" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
            copied=$((copied + count))
            [ "$verbose" = "true" ] && print_success "  ✓ $category ($count skills)"
        fi
    done
    echo "$copied"
}

copy_skills_to_claude() {
    local verbose="${1:-false}"

    # Project-level skills (if in git repo)
    if git rev-parse --git-dir > /dev/null 2>&1; then
        mkdir -p "$PROJECT_DIR/.claude/skills"
        local project_count=$(copy_skills "$PROJECT_DIR/.claude/skills" "$verbose")
        print_success "Project skills: $project_count files → .claude/skills/"
    fi

    # Personal skills
    mkdir -p ~/.claude/skills
    local personal_count=$(copy_skills "$HOME/.claude/skills" "$verbose")
    print_success "Personal skills: $personal_count files → ~/.claude/skills/"
}

# ============================================================
# 4. Token Optimization
# ============================================================
generate_compact_skills() {
    if ! $HAS_PYTHON3; then
        print_warning "Python3 필요 - 토큰 최적화 건너뜀"
        return 1
    fi

    if [ -f "$AGENT_SKILLS_DIR/scripts/generate_compact_skills.py" ]; then
        print_info "토큰 최적화 스킬 생성 중..."
        if $SILENT_MODE; then
            python3 "$AGENT_SKILLS_DIR/scripts/generate_compact_skills.py" > /dev/null 2>&1
        else
            python3 "$AGENT_SKILLS_DIR/scripts/generate_compact_skills.py" 2>&1 | tail -5
        fi
        return 0
    else
        print_warning "generate_compact_skills.py 없음"
        return 1
    fi
}

# ============================================================
# 5. MCP Shell Config Generation
# ============================================================
setup_mcp_shell_config() {
    cat > "$AGENT_SKILLS_DIR/mcp-shell-config.sh" << 'EOFCONFIG'
#!/bin/bash
# Agent Skills MCP Integration (Auto-detect path)
# Generated by setup.sh v3.2
# Note: This script is designed to be silent when sourced

# Suppress all output during sourcing
{
if [ -n "$BASH_SOURCE" ]; then
    _MCP_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then
    _MCP_SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
    _MCP_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

export AGENT_SKILLS_PATH="$_MCP_SCRIPT_DIR"

# Load helper functions silently
[ -f "$AGENT_SKILLS_PATH/mcp-skill-loader.sh" ] && source "$AGENT_SKILLS_PATH/mcp-skill-loader.sh"
} 2>/dev/null

# Skill query aliases
alias skill-list='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" list'
alias skill-match='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" match'
alias skill-query='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query'
alias skill-stats='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" stats'

# Token mode aliases
alias skill-query-toon='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query --mode toon'
alias skill-query-compact='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query --mode compact'
alias skill-query-full='python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query --mode full'

# MCP Agent functions (default: toon mode - 95% token savings)
gemini-skill() {
    local query="$1"
    local mode="${2:-toon}"
    python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query "$query" --tool gemini --mode "$mode" 2>/dev/null || echo "No matching skill for: $query"
}

codex-skill() {
    local query="$1"
    local mode="${2:-toon}"
    python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query "$query" --tool codex --mode "$mode" 2>/dev/null || echo "No matching skill for: $query"
}

# Check MCP environment status
mcp-status() {
    echo "🔍 MCP Environment Status"
    echo "========================="
    command -v claude &>/dev/null && echo "✅ Claude CLI: Installed" || echo "❌ Claude CLI: Not found"
    if command -v claude &>/dev/null; then
        claude mcp list 2>/dev/null | grep -E "(gemini-cli|codex-cli)" || echo "  No MCP servers registered"
    fi
}

export -f gemini-skill codex-skill mcp-status 2>/dev/null || true
unset _MCP_SCRIPT_DIR
EOFCONFIG
    chmod +x "$AGENT_SKILLS_DIR/mcp-shell-config.sh"
}

# ============================================================
# 6. Shell RC Configuration (Idempotent)
# ============================================================
configure_shell_rc() {
    local auto_configure="$1"
    local SHELL_RC=""

    # Detect shell
    if [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.bashrc"
    fi

    if [ "$auto_configure" = "auto" ]; then
        local MARKER="# Agent Skills MCP Integration"

        # Remove old config if exists (idempotent)
        if grep -q "$MARKER" "$SHELL_RC" 2>/dev/null; then
            # macOS compatible sed
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "/$MARKER/,/# End Agent Skills MCP/d" "$SHELL_RC" 2>/dev/null || true
            else
                sed -i "/$MARKER/,/# End Agent Skills MCP/d" "$SHELL_RC" 2>/dev/null || true
            fi
        fi

        # Add new configuration (silent sourcing)
        {
            echo ""
            echo "$MARKER"
            echo "# Auto-generated by setup.sh v3.2 - $(date +%Y-%m-%d)"
            echo "# Silent sourcing to prevent terminal startup noise"
            echo "[ -f \"$AGENT_SKILLS_DIR/mcp-shell-config.sh\" ] && source \"$AGENT_SKILLS_DIR/mcp-shell-config.sh\" 2>/dev/null"
            echo "# End Agent Skills MCP"
        } >> "$SHELL_RC"

        print_success "Shell RC 설정 완료: $SHELL_RC"
        return 0
    fi
    return 1
}

# ============================================================
# 7. Dynamic CLAUDE.md Generation (Environment-aware)
# ============================================================
generate_claude_md_dynamic() {
    local workflow_label=""
    local gemini_status="❌ Not Integrated"
    local codex_status="❌ Not Integrated"

    # Determine labels
    case "$WORKFLOW_TYPE" in
        "full-multiagent")
            workflow_label="Full Multi-Agent"
            gemini_status="✅ Integrated"
            codex_status="✅ Integrated"
            ;;
        "claude-gemini")
            workflow_label="Analysis & Research Focus"
            gemini_status="✅ Integrated"
            ;;
        "claude-codex")
            workflow_label="Execution & Deployment Focus"
            codex_status="✅ Integrated"
            ;;
        "claude-only")
            workflow_label="Claude-Centric"
            ;;
        *)
            workflow_label="Standalone (No Claude CLI)"
            ;;
    esac

    cat > "$PROJECT_DIR/CLAUDE.md" << EOF
# Agent Skills - $workflow_label Workflow

> 이 문서는 현재 MCP 환경에 맞춰 자동 생성되었습니다.
> Generated: $(date +%Y-%m-%d) | Workflow: $WORKFLOW_TYPE | Preset: $PERFORMANCE_PRESET

## Agent Roles & Status

| Agent | Role | Status | Best For |
|-------|------|--------|----------|
| **Claude Code** | Orchestrator | ✅ Integrated | 계획 수립, 코드 생성, 스킬 해석 |
| **Gemini-CLI** | Analyst | $gemini_status | 대용량 분석 (1M+ 토큰), 리서치, 코드 리뷰 |
| **Codex-CLI** | Executor | $codex_status | 명령 실행, 빌드, 배포, Docker/K8s |

## Model Configuration ($PERFORMANCE_PRESET)

| Role | Provider | Model | Use Case |
|------|----------|-------|----------|
| **Orchestrator** | $PROVIDER_ORCHESTRATOR | \`$MODEL_ORCHESTRATOR\` | 계획 수립, 코드 생성 |
| **Analyst** | $PROVIDER_ANALYST | \`$MODEL_ANALYST\` | 대용량 분석, 리서치 |
| **Executor** | $PROVIDER_EXECUTOR | \`$MODEL_EXECUTOR\` | 명령 실행, 빌드 |

### Claude Task Tool Model Hints
\`\`\`
# Task tool에서 model 파라미터 사용
orchestrator tasks → model: "opus" (고성능) or "sonnet" (균형)
analyst tasks     → model: "sonnet" (or gemini-cli ask-gemini)
executor tasks    → model: "haiku" (빠름) (or codex-cli shell)
\`\`\`

EOF

    # Add workflow-specific sections
    case "$WORKFLOW_TYPE" in
        "full-multiagent")
            cat >> "$PROJECT_DIR/CLAUDE.md" << 'EOF'
## Full Multi-Agent Workflow

### Orchestration Pattern
```
[Claude] 계획 수립 → [Gemini] 분석/리서치 → [Claude] 코드 작성 → [Codex] 실행/테스트 → [Claude] 결과 종합
```

### Example: API 설계 + 구현 + 테스트
1. **[Claude]** 스킬 기반 API 스펙 설계
2. **[Gemini]** `ask-gemini "@src/ 기존 API 패턴 분석"` - 대용량 코드베이스 분석
3. **[Claude]** 분석 결과 기반 코드 구현
4. **[Codex]** `shell "npm test && npm run build"` - 테스트 및 빌드
5. **[Claude]** 최종 리포트 생성

### MCP Tools Usage
```bash
# Gemini: 대용량 분석
ask-gemini "전체 코드베이스 구조 분석해줘"
ask-gemini "@src/ @tests/ 테스트 커버리지 분석"

# Codex: 명령 실행
shell "docker-compose up -d"
shell "kubectl apply -f deployment.yaml"
```

EOF
            ;;
        "claude-gemini")
            cat >> "$PROJECT_DIR/CLAUDE.md" << 'EOF'
## Analysis-Focused Workflow

### Orchestration Pattern
```
[Claude] 계획 수립 → [Gemini] 대용량 분석 → [Claude] 코드 작성 + 실행
```

### Best Use Cases
- 대규모 코드베이스 리뷰 및 리팩토링
- 아키텍처 분석 및 문서화
- 기술 리서치 및 벤치마킹

### Example: 코드 리뷰
1. **[Gemini]** `ask-gemini "@src/ 전체 코드 품질 분석"`
2. **[Claude]** 분석 결과 기반 개선점 구현
3. **[Claude]** 직접 테스트 실행 (`Bash` tool)

EOF
            ;;
        "claude-codex")
            cat >> "$PROJECT_DIR/CLAUDE.md" << 'EOF'
## Execution-Focused Workflow

### Orchestration Pattern
```
[Claude] 계획 + 코드 작성 → [Codex] 실행/배포 → [Claude] 결과 분석
```

### Best Use Cases
- CI/CD 파이프라인 구축
- Docker/Kubernetes 배포
- 장시간 실행 작업 (빌드, 테스트)

### Example: 배포 자동화
1. **[Claude]** Dockerfile, K8s manifests 작성
2. **[Codex]** `shell "docker build && docker push"`
3. **[Codex]** `shell "kubectl apply -f k8s/"`
4. **[Claude]** 배포 상태 확인 및 리포트

EOF
            ;;
        *)
            cat >> "$PROJECT_DIR/CLAUDE.md" << 'EOF'
## Claude-Centric Workflow

현재 Claude Code만 사용 가능합니다. 더 강력한 워크플로우를 위해 MCP 서버를 추가하세요.

### 현재 가능한 작업
- 스킬 기반 코드 작성
- 파일 읽기/쓰기
- Bash 명령 실행

EOF
            ;;
    esac

    # Add enhancement guide if not full
    if [ "$WORKFLOW_TYPE" != "full-multiagent" ]; then
        cat >> "$PROJECT_DIR/CLAUDE.md" << 'EOF'
## Workflow 업그레이드 가이드

EOF
        if ! $HAS_GEMINI_MCP; then
            cat >> "$PROJECT_DIR/CLAUDE.md" << 'EOF'
### Gemini-CLI 추가 (분석/리서치 강화)
```bash
claude mcp add gemini-cli -s user -- npx -y gemini-mcp-tool
```
- 1M+ 토큰 컨텍스트로 대용량 분석 가능
- 코드 리뷰, 아키텍처 분석에 최적

EOF
        fi
        if ! $HAS_CODEX_MCP; then
            cat >> "$PROJECT_DIR/CLAUDE.md" << 'EOF'
### Codex-CLI 추가 (실행/배포 강화)
```bash
claude mcp add codex-cli -s user -- npx -y @anthropic-ai/claude-code-mcp-codex
```
- 샌드박스 환경에서 안전한 명령 실행
- 장시간 빌드/배포 작업에 최적

EOF
        fi
    fi

    # Add available skills section
    cat >> "$PROJECT_DIR/CLAUDE.md" << 'EOF'
## Available Skills

| Category | Description |
|----------|-------------|
| `backend/` | API 설계, DB 스키마, 인증 |
| `frontend/` | UI 컴포넌트, 상태 관리 |
| `code-quality/` | 코드 리뷰, 디버깅, 테스트 |
| `infrastructure/` | 배포, 모니터링, 보안 |
| `documentation/` | 기술 문서, API 문서 |
| `utilities/` | Git, 환경 설정 |

### Skill Query (Token-Optimized)
```bash
gemini-skill "API 설계해줘"           # toon mode (95% 절감)
gemini-skill "query" compact          # compact mode (88% 절감)
gemini-skill "query" full             # 상세 모드
```

---
**Version**: 3.0.0 | **Generated**: $(date +%Y-%m-%d)
EOF

    print_success "CLAUDE.md 생성 완료 ($workflow_label)"
}

# ============================================================
# 8. MCP Server Configuration
# ============================================================
add_gemini_mcp() {
    if $HAS_GEMINI_MCP; then
        print_info "gemini-cli 이미 등록됨"
        return 0
    fi

    print_info "gemini-cli MCP 서버 추가 중..."
    if claude mcp add gemini-cli -s user -- npx -y gemini-mcp-tool 2>/dev/null; then
        HAS_GEMINI_MCP=true
        print_success "gemini-cli 추가 완료"
        return 0
    else
        print_error "gemini-cli 추가 실패"
        print_info "수동 설치: claude mcp add gemini-cli -s user -- npx -y gemini-mcp-tool"
        return 1
    fi
}

add_codex_mcp() {
    if $HAS_CODEX_MCP; then
        print_info "codex-cli 이미 등록됨"
        return 0
    fi

    print_info "codex-cli MCP 서버 추가 중..."
    if claude mcp add codex-cli -s user -- npx -y @anthropic-ai/claude-code-mcp-codex 2>/dev/null; then
        HAS_CODEX_MCP=true
        print_success "codex-cli 추가 완료"
        return 0
    else
        print_error "codex-cli 추가 실패"
        print_info "수동 설치: claude mcp add codex-cli -s user -- npx -y @anthropic-ai/claude-code-mcp-codex"
        return 1
    fi
}

# ============================================================
# 9. Auto-Configure Workflow (Progressive)
# ============================================================
auto_configure_workflow() {
    echo ""
    print_header "Auto-Configure Workflow"
    echo ""

    local STEPS_TOTAL=7
    local STEP=0

    # Step 1: Token Optimization
    STEP=$((STEP + 1))
    print_info "[$STEP/$STEPS_TOTAL] 토큰 최적화..."
    generate_compact_skills || true
    echo ""

    # Step 2: Claude Skills Copy
    STEP=$((STEP + 1))
    print_info "[$STEP/$STEPS_TOTAL] Claude 스킬 복사..."
    copy_skills_to_claude "false"
    echo ""

    # Step 3: MCP Shell Config
    STEP=$((STEP + 1))
    print_info "[$STEP/$STEPS_TOTAL] MCP 쉘 설정 생성..."
    setup_mcp_shell_config
    print_success "mcp-shell-config.sh 생성됨"
    echo ""

    # Step 4: Shell RC (with prompt or auto or skip)
    STEP=$((STEP + 1))
    print_info "[$STEP/$STEPS_TOTAL] 쉘 RC 설정..."

    if $SKIP_SHELL_RC; then
        # Skip shell RC modification entirely (for AI agents)
        print_info "쉘 RC 수정 건너뜀 (--no-shell-rc 또는 --silent 모드)"
    elif $SKIP_SHELL_RC_PROMPT; then
        # Non-interactive: auto configure
        configure_shell_rc "auto"
    else
        echo ""
        echo "쉘 설정을 자동으로 추가할까요?"
        echo "  1) 예, 자동 설정 (권장)"
        echo "  2) 아니오, 수동 설정"
        read -p "선택 (1-2): " shell_choice

        if [ "$shell_choice" = "1" ]; then
            configure_shell_rc "auto"
        else
            print_info "수동 설정 필요:"
            echo "  source \"$AGENT_SKILLS_DIR/mcp-shell-config.sh\""
        fi
    fi
    echo ""

    # Step 5: MCP Servers (with prompt or skip)
    STEP=$((STEP + 1))
    print_info "[$STEP/$STEPS_TOTAL] MCP 서버 설정..."

    if $HAS_CLAUDE_CLI; then
        if $SKIP_MCP_PROMPTS; then
            # Non-interactive: skip MCP additions (keep existing)
            $HAS_GEMINI_MCP && print_success "  gemini-cli: 이미 설정됨" || print_info "  gemini-cli: 건너뜀 (수동 추가 가능)"
            $HAS_CODEX_MCP && print_success "  codex-cli: 이미 설정됨" || print_info "  codex-cli: 건너뜀 (수동 추가 가능)"
        else
            echo ""
            echo "MCP 서버를 추가하시겠습니까?"
            echo ""

            if ! $HAS_GEMINI_MCP; then
                read -p "  gemini-cli 추가? (분석/리서치 강화) [y/n]: " add_gemini
                [[ "$add_gemini" =~ ^[Yy]$ ]] && add_gemini_mcp
            else
                print_success "  gemini-cli: 이미 설정됨"
            fi

            if ! $HAS_CODEX_MCP; then
                read -p "  codex-cli 추가? (실행/배포 강화) [y/n]: " add_codex
                [[ "$add_codex" =~ ^[Yy]$ ]] && add_codex_mcp
            else
                print_success "  codex-cli: 이미 설정됨"
            fi
        fi
    else
        print_warning "Claude CLI 없음 - MCP 서버 설정 건너뜀"
    fi
    echo ""

    # Recalculate workflow type after changes
    determine_workflow_type

    # Step 6: Generate agent-routing.yaml
    STEP=$((STEP + 1))
    print_info "[$STEP/$STEPS_TOTAL] agent-routing.yaml 생성..."
    generate_agent_routing_config
    echo ""

    # Step 7: Generate CLAUDE.md
    STEP=$((STEP + 1))
    print_info "[$STEP/$STEPS_TOTAL] CLAUDE.md 생성..."
    generate_claude_md_dynamic
    echo ""

    # Final Summary
    print_summary
}

# ============================================================
# 10. Print Summary
# ============================================================
print_summary() {
    # Skip summary in silent mode
    $SILENT_MODE && return 0

    echo ""
    print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "설정 완료!"
    print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    echo -e "${BOLD}현재 Workflow:${NC} ${CYAN}$WORKFLOW_TYPE${NC}"
    echo ""

    # Stats
    local toon_count=$(find "$AGENT_SKILLS_DIR" -name "SKILL.toon" 2>/dev/null | wc -l | tr -d ' ')
    local skill_count=$(find "$AGENT_SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    echo "📊 통계:"
    echo "   - 스킬 파일: $skill_count SKILL.md"
    echo "   - 토큰 최적화: $toon_count SKILL.toon"
    echo ""

    echo "📚 다음 단계:"
    echo ""
    echo "  1. 쉘 재시작:"
    echo -e "     ${BLUE}source ~/.zshrc${NC}  # 또는 ~/.bashrc"
    echo ""
    echo "  2. MCP 상태 확인:"
    echo -e "     ${BLUE}claude mcp list${NC}"
    echo ""

    case "$WORKFLOW_TYPE" in
        "full-multiagent")
            echo "  3. Full Multi-Agent 테스트:"
            echo -e "     ${BLUE}ask-gemini \"코드베이스 분석해줘\"${NC}"
            echo -e "     ${BLUE}shell \"npm test\"${NC}"
            ;;
        "claude-gemini")
            echo "  3. 분석 워크플로우 테스트:"
            echo -e "     ${BLUE}ask-gemini \"코드 리뷰해줘\"${NC}"
            ;;
        "claude-codex")
            echo "  3. 실행 워크플로우 테스트:"
            echo -e "     ${BLUE}shell \"npm run build\"${NC}"
            ;;
        *)
            echo "  3. 스킬 테스트:"
            echo -e "     ${BLUE}gemini-skill \"API 설계\"${NC}"
            ;;
    esac
    echo ""
}

# ============================================================
# 11. Manual Setup Submenu
# ============================================================
manual_setup_menu() {
    echo ""
    print_header "Manual Setup"
    echo ""
    echo "  1) Claude Code 스킬만 설정"
    echo "  2) ChatGPT용 Knowledge Zip 생성"
    echo "  3) Gemini용 GEMINI.md 생성"
    echo "  4) MCP 쉘 설정만 생성"
    echo "  5) 돌아가기"
    echo ""
    read -p "선택 (1-5): " manual_choice

    case "$manual_choice" in
        1)
            echo ""
            print_header "Claude Code Setup"
            generate_compact_skills || true
            copy_skills_to_claude "true"
            echo ""
            print_success "Claude Code 스킬 설정 완료!"
            ;;
        2)
            echo ""
            print_header "ChatGPT Knowledge Zip"
            local ZIP_FILE="agent-skills-$(date +%Y%m%d).zip"
            local TEMP_DIR="$(mktemp -d)"
            trap "rm -rf $TEMP_DIR" EXIT

            for cat in "${SKILL_CATEGORIES[@]}"; do
                [ -d "$AGENT_SKILLS_DIR/$cat" ] && cp -r "$AGENT_SKILLS_DIR/$cat" "$TEMP_DIR/"
            done

            (cd "$TEMP_DIR" && zip -r "$AGENT_SKILLS_DIR/$ZIP_FILE" . > /dev/null 2>&1)
            print_success "생성됨: $ZIP_FILE"
            echo "ChatGPT Custom GPT → Knowledge 섹션에 업로드하세요."
            ;;
        3)
            echo ""
            print_header "Gemini Setup"
            cat > "$PROJECT_DIR/GEMINI.md" << 'EOF'
# Agent Skills for Gemini

이 프로젝트는 Agent Skills 시스템을 사용합니다.
`.agent-skills/` 폴더의 스킬들을 작업 매뉴얼로 참조하세요.

## 스킬 카테고리
- backend/: API 설계, DB 스키마
- frontend/: UI 컴포넌트, 반응형 디자인
- code-quality/: 코드 리뷰, 디버깅
- infrastructure/: 배포, 모니터링
- documentation/: 기술 문서
- utilities/: Git, 환경 설정

## 사용법
1. 관련 SKILL.md 또는 SKILL.toon 파일 참조
2. 지시사항에 따라 작업 수행
3. 출력 포맷 준수
EOF
            print_success "GEMINI.md 생성됨"
            ;;
        4)
            setup_mcp_shell_config
            print_success "mcp-shell-config.sh 생성됨"
            echo ""
            echo "쉘에 추가하려면:"
            echo "  source \"$AGENT_SKILLS_DIR/mcp-shell-config.sh\""
            ;;
        5)
            return 0
            ;;
    esac
}

# ============================================================
# 12. Utilities Submenu
# ============================================================
utilities_menu() {
    echo ""
    print_header "Utilities"
    echo ""
    echo "  1) 토큰 최적화 파일 생성"
    echo "  2) 토큰 통계 보기"
    echo "  3) 생성된 파일 정리 (clean)"
    echo "  4) 스킬 유효성 검사"
    echo "  5) MCP 환경 재감지"
    echo -e "  ${GREEN}6) 모델 설정 (Model Config)${NC}"
    echo -e "  ${CYAN}7) 시스템 진단 (Diagnostics)${NC}"
    echo -e "  ${YELLOW}8) MCP 서버 헬스 체크${NC}"
    echo "  9) 돌아가기"
    echo ""
    read -p "선택 (1-9): " util_choice

    case "$util_choice" in
        1)
            generate_compact_skills
            ;;
        2)
            if $HAS_PYTHON3 && [ -f "$AGENT_SKILLS_DIR/skill-query-handler.py" ]; then
                python3 "$AGENT_SKILLS_DIR/skill-query-handler.py" stats
            else
                local skill_count=$(find "$AGENT_SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
                local toon_count=$(find "$AGENT_SKILLS_DIR" -name "SKILL.toon" 2>/dev/null | wc -l | tr -d ' ')
                local compact_count=$(find "$AGENT_SKILLS_DIR" -name "SKILL.compact.md" 2>/dev/null | wc -l | tr -d ' ')
                echo ""
                echo "📊 스킬 통계:"
                echo "   SKILL.md: $skill_count"
                echo "   SKILL.toon: $toon_count"
                echo "   SKILL.compact.md: $compact_count"
            fi
            ;;
        3)
            if $HAS_PYTHON3 && [ -f "$AGENT_SKILLS_DIR/scripts/generate_compact_skills.py" ]; then
                python3 "$AGENT_SKILLS_DIR/scripts/generate_compact_skills.py" --clean
            else
                print_warning "Python3 또는 스크립트 없음"
            fi
            ;;
        4)
            if [ -f "$AGENT_SKILLS_DIR/validate_claude_skills.py" ]; then
                python3 "$AGENT_SKILLS_DIR/validate_claude_skills.py"
            else
                local skill_count=$(find "$AGENT_SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
                echo "발견된 스킬: $skill_count SKILL.md"
            fi
            ;;
        5)
            detect_mcp_environment
            ;;
        6)
            configure_models_interactive
            generate_model_config_file
            generate_agent_routing_config
            ;;
        7)
            run_diagnostics
            ;;
        8)
            if $HAS_CLAUDE_CLI; then
                verify_mcp_servers
            else
                print_warning "Claude CLI 필요"
            fi
            ;;
        9)
            return 0
            ;;
    esac
}

# ============================================================
# MAIN MENU
# ============================================================

# Parse command line arguments
parse_arguments "$@"

# Auto-detect environment on start
detect_mcp_environment

# Run diagnostics if requested
if $RUN_DIAGNOSE; then
    run_diagnostics
    exit 0
fi

# Non-interactive modes
if [ "$INSTALL_MODE" = "auto" ] || [ "$INSTALL_MODE" = "quick" ] || [ "$INSTALL_MODE" = "silent" ]; then
    print_info "비대화형 모드로 실행 중..."
    auto_configure_workflow
    generate_model_config_file
    $SILENT_MODE || print_success "설정 완료!"
    exit 0
fi

# Main menu (interactive mode)
while true; do
    echo ""
    echo -e "${CYAN}🚀 Agent Skills Setup v3.2${NC}"
    echo "═══════════════════════════════════════════════"
    echo ""
    echo -e "${BOLD}현재 환경:${NC}"
    print_status "Claude CLI" "$HAS_CLAUDE_CLI"
    print_status "gemini-cli MCP" "$HAS_GEMINI_MCP"
    print_status "codex-cli MCP" "$HAS_CODEX_MCP"
    echo -e "  ${BOLD}Workflow:${NC} ${CYAN}$WORKFLOW_TYPE${NC}"
    echo ""
    echo "───────────────────────────────────────────────"
    echo ""
    echo -e "  ${GREEN}1) 자동 설정 (Auto-configure)${NC} ${YELLOW}← 권장${NC}"
    echo "     → 감지된 환경에 맞춰 누락된 부분만 점진적 설정"
    echo ""
    echo "  2) 수동 설정 (Manual Setup)"
    echo "     → Claude/ChatGPT/Gemini 개별 설정"
    echo ""
    echo "  3) 유틸리티 (Utilities)"
    echo "     → 토큰 최적화, 검증, 정리"
    echo ""
    echo "  4) 종료 (Exit)"
    echo ""
    read -p "선택 (1-4): " main_choice

    case "$main_choice" in
        1)
            auto_configure_workflow
            ;;
        2)
            manual_setup_menu
            ;;
        3)
            utilities_menu
            ;;
        4)
            echo ""
            print_success "종료합니다."
            exit 0
            ;;
        *)
            print_warning "잘못된 선택"
            ;;
    esac
done
