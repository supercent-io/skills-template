# image-generation-mcp

> Generate high-quality images via MCP (Gemini models) using structured prompts, ratios, and validation.

## When to use this skill
- Marketing assets (hero, banner, social)
- UI/UX placeholders
- Presentation visuals
- Brand-consistent imagery

## Instructions
**S1: Configure MCP**
- Verify gemini-cli installed
- Set model, API key, output dir

**S2: Define Prompt**
- Subject, Style, Lighting, Mood
- Composition, Aspect Ratio
- Brand Colors (HEX)

**S3: Choose Model**
- `gemini-3-pro-image`: High quality
- `gemini-2.5-flash-image`: Fast iteration
- `gemini-2.5-pro-image`: Balanced

**S4: Generate & Review**
- Generate 2-4 variants
- Single-variable iteration
- Review: brand fit, clarity, ratio

**S5: Deliverables**
- Final image + prompt metadata
- Model, ratio, usage notes

## Best practices
1. Specify ratio early
2. Use style anchors
3. Iterate single variables
4. Track all prompts

## Validation (Multi-Agent)
- R1 (Orchestrator): Prompt completeness
- R2 (Analyst): Style/brand alignment
- R3 (Executor): File naming, delivery
