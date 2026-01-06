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

# MCP functions (default: toon mode for minimal tokens - 95% reduction)
# Usage: gemini-skill "query" [mode]
# Modes: toon (default), compact (75% reduction), full (max detail)
gemini-skill() {
    local query="$1"
    local mode="${2:-toon}"  # Default to toon mode
    local prompt=$(python3 "$AGENT_SKILLS_PATH/skill-query-handler.py" query "$query" --tool gemini --mode "$mode" 2>/dev/null)
    if [ -n "$prompt" ]; then
        echo "$prompt"
    else
        echo "No matching skill found for: $query"
    fi
}

codex-skill() {
    local query="$1"
    local mode="${2:-toon}"  # Default to toon mode
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
