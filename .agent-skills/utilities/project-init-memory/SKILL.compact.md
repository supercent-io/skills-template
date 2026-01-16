---
name: project-init-memory
description: Auto-remember and apply skillset configuration on project init
tags: [project-init, memory, skillset, configuration, automation]
platforms: [Claude, ChatGPT, Gemini]
---

# Project Init Memory

## When to Use
- First project run in .skills-template
- Session restoration needed
- Team onboarding with consistent setup
- Multi-project context switching

## Core Concept

Store project config in `.claude/project-memory.json`:
```json
{
  "version": "1.0.0",
  "skillset": {
    "source": ".skills-template/.agent-skills",
    "token_mode": "toon",
    "active_skills": []
  },
  "environment": {
    "workflow_type": "full-multiagent",
    "mcp_servers": ["gemini-cli", "codex-cli"]
  },
  "project_context": {
    "name": "", "type": "", "language": ""
  },
  "session_history": []
}
```

## Workflow

### Initialize (No Memory Exists)
```bash
[ ! -f .claude/project-memory.json ] && {
  mkdir -p .claude
  [ -d .skills-template/.agent-skills ] && \
    cd .skills-template/.agent-skills && ./setup.sh --silent
  # Create memory file
}
```

### Restore (Memory Exists)
```bash
[ -f .claude/project-memory.json ] && {
  SKILLSET=$(jq -r '.skillset.source' .claude/project-memory.json)
  source "$SKILLSET/mcp-shell-config.sh"
}
```

### Update (On Changes)
```bash
# Update lastUpdated timestamp
# Append to session_history
# Preserve user customizations
```

## Rules

| MUST | MUST NOT |
|------|----------|
| Check before overwrite | Store secrets in memory |
| Use toon mode default | Delete user history |
| Version memory file | Modify outside .claude/ |
| ISO 8601 timestamps | Overwrite without backup |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Memory not loading | `mkdir -p .claude && rm -f .claude/project-memory.json` |
| Wrong skillset | Update `.skillset.source` in memory JSON |
| Token mode ignored | Force `jq '.skillset.token_mode = "toon"'` |

## Related Skills
- environment-setup
- skill-standardization
- mcp-codex-integration
