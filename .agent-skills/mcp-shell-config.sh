# Agent Skills MCP Integration
# Add this to your ~/.bashrc or ~/.zshrc

# Set Agent Skills path
export AGENT_SKILLS_PATH="/Users/supercent/Documents/Github/skills-template/.agent-skills"

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
