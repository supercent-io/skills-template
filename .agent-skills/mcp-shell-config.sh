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

# MCP-specific aliases
alias gemini-skill='gemini chat "$(load_skill_with_context'
alias codex-skill='codex-cli shell "$(load_skill_with_context'
