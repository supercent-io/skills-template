---
name: fabric
description: AI prompt orchestration CLI using reusable Patterns. Use for YouTube summarization, document analysis, content extraction, and any AI task via stdin/stdout piping across 15+ providers.
license: CC-BY-4.0
compatibility: All platforms. Requires fabric CLI installed (Go-based binary). Works with OpenAI, Anthropic, Google, Azure, Bedrock, Groq, Ollama, and 15+ other AI providers.
metadata:
  version: 1.0.0
  author: supercent-io
  keyword: fabric
  platforms: All platforms
  tags: fabric, patterns, ai-prompts, youtube, summarize, extract-wisdom, piping, cli, multi-provider, openai, claude, gemini
allowed-tools: Read Write Bash Grep Glob
---

# Fabric

Fabric is an open-source AI prompt orchestration framework by Daniel Miessler. It provides a library of reusable AI prompts called **Patterns** — each designed for a specific real-world task — wired into a simple Unix pipeline with stdin/stdout.

## When to use this skill

- Summarize or extract insights from YouTube videos, articles, or documents
- Apply any of 200+ pre-built AI patterns to content via Unix piping
- Route different patterns to different AI providers (OpenAI, Claude, Gemini, etc.)
- Create custom patterns for repeatable AI workflows
- Run Fabric as a REST API server for integration with other tools
- Process command output, files, or clipboard content through AI patterns

## Instructions

### Step 1: Install Fabric

```bash
# macOS/Linux (one-liner)
curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/scripts/installer/install.sh | bash

# macOS via Homebrew
brew install fabric-ai

# Windows
winget install danielmiessler.Fabric

# After install — configure API keys and default model
fabric --setup
```

### Step 2: Learn the core pipeline workflow

Fabric works as a Unix pipe. Feed content through stdin and specify a pattern:

```bash
# Summarize a file
cat article.txt | fabric -p summarize

# Stream output in real time
cat document.txt | fabric -p extract_wisdom --stream

# Pipe any command output through a pattern
git log --oneline -20 | fabric -p summarize

# Process clipboard (macOS)
pbpaste | fabric -p summarize
```

### Step 3: Discover patterns

```bash
# List all available patterns
fabric -l

# Update patterns from the repository
fabric -u

# Search patterns by keyword
fabric -l | grep summary
fabric -l | grep code
```

Key patterns:

| Pattern | Purpose |
|---------|---------|
| `summarize` | Summarize any content |
| `extract_wisdom` | Extract insights, quotes, habits from text |
| `analyze_paper` | Break down academic papers |
| `explain_code` | Explain code in plain language |
| `write_essay` | Write essays from a topic or notes |
| `clean_text` | Remove noise from raw text |
| `analyze_claims` | Fact-check and analyze claims |
| `create_summary` | Create a structured summary |
| `rate_content` | Rate and score content quality |
| `label_and_rate` | Categorize and score content |

### Step 4: Process YouTube videos

```bash
# Summarize a YouTube video
fabric -y "https://youtube.com/watch?v=VIDEO_ID" -p summarize

# Extract key insights from a video
fabric -y "https://youtube.com/watch?v=VIDEO_ID" -p extract_wisdom

# Get transcript only (no pattern applied)
fabric -y "https://youtube.com/watch?v=VIDEO_ID" --transcript

# Transcript with timestamps
fabric -y "https://youtube.com/watch?v=VIDEO_ID" --transcript-with-timestamps
```

### Step 5: Create custom patterns

Each pattern is a directory with a `system.md` file inside `~/.config/fabric/patterns/`:

```bash
mkdir -p ~/.config/fabric/patterns/my-pattern
cat > ~/.config/fabric/patterns/my-pattern/system.md << 'EOF'
# IDENTITY AND PURPOSE

You are an expert at [task]. Your job is to [specific goal].

# STEPS

1. [Step 1]
2. [Step 2]

# OUTPUT FORMAT

- [Format instruction 1]
- [Format instruction 2]
EOF
```

Use it immediately:

```bash
echo "input text" | fabric -p my-pattern
cat file.txt | fabric -p my-pattern --stream
```

### Step 6: Multi-provider routing and advanced usage

```bash
# Run as REST API server (port 8080 by default)
fabric --serve

# Use web search capability
fabric -p analyze_claims --search "claim to verify"

# Per-pattern model routing in ~/.config/fabric/.env
FABRIC_MODEL_PATTERN_SUMMARIZE=anthropic|claude-opus-4-5
FABRIC_MODEL_PATTERN_EXTRACT_WISDOM=openai|gpt-4o
FABRIC_MODEL_PATTERN_EXPLAIN_CODE=google|gemini-2.0-flash

# Create shell aliases for frequently used patterns
alias summarize="fabric -p summarize"
alias wisdom="fabric -p extract_wisdom"
alias explain="fabric -p explain_code"

# Chain patterns
cat paper.txt | fabric -p summarize | fabric -p extract_wisdom

# Save output
cat document.txt | fabric -p extract_wisdom > insights.md
```

## Best practices

- Run `fabric -u` before first use and regularly to get the latest community patterns.
- Use `--stream` for long content to see results progressively instead of waiting.
- Create shell aliases (`alias wisdom="fabric -p extract_wisdom"`) for your most-used patterns.
- Use per-pattern model routing to optimize cost vs. quality for each task type.
- Keep custom patterns in `~/.config/fabric/patterns/` — they persist across updates.
- For YouTube, transcript extraction works best with videos that have captions enabled.
- Chain patterns with Unix pipes for multi-step processing workflows.

## References

- [Fabric GitHub](https://github.com/danielmiessler/Fabric)
- [Pattern Library](https://github.com/danielmiessler/Fabric/tree/main/patterns)
- [Installation Guide](https://github.com/danielmiessler/Fabric#installation)
