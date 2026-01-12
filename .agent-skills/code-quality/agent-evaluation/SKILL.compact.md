---
name: agent-evaluation
description: Design and implement comprehensive evaluation systems for AI agents. Use when building evals for coding agents, conversational agents, research agents, or computer-use agents. Covers grader types, benchmarks, 8-step roadmap, and production integration.
allowed-tools: [Read, Write, Shell, Grep, Glob]
tags: [agent-evaluation, evals, AI-agents, benchmarks, graders, testing, quality-assurance]
platforms: [Claude, ChatGPT, Gemini]
---

# Agent Evaluation

> Based on Anthropic's "Demystifying evals for AI agents"

## When to Use
- Designing eval systems for AI agents
- Building benchmarks (coding/conversational/research/computer-use)
- Creating graders (code/model/human)
- Production monitoring & CI/CD integration

## Core Concepts

### Eval Types
| Type | Turns | Grading |
|------|-------|---------|
| Single-turn | 1 | Simple |
| Multi-turn | N | Per-turn |
| Agentic | N | Outcome |

### 7 Key Terms
- **Task**: Test case (prompt + expected)
- **Trial**: One agent run
- **Grader**: Scoring function
- **Transcript**: Full action record
- **Outcome**: Final state
- **Harness**: Eval infrastructure
- **Suite**: Task collection

## Grader Types

### Code-based (Recommended for Coding)
- Fast, objective, reproducible
- Best for: structured outputs, test passage

### Model-based (LLM-as-Judge)
- Flexible, handles nuance
- Requires calibration
- Best for: conversational, open-ended

### Human
- Highest accuracy, expensive
- Best for: final validation, ambiguous cases

## Agent-Specific Strategies

### Coding Agents
- Benchmarks: SWE-bench, Terminal-Bench
- Metrics: test passage, lint, build, diff size

### Conversational Agents
- Benchmarks: τ2-Bench
- Metrics: resolution, empathy, turns, escalation

### Research Agents
- Dimensions: grounding, coverage, source quality

### Computer Use Agents
- Benchmarks: WebArena, OSWorld
- Verify: UI state, DB state, file state

## 8-Step Roadmap

1. **Step 0**: Start early (20-50 tasks)
2. **Step 1**: Convert manual tests
3. **Step 2**: Add clarity + reference solutions
4. **Step 3**: Balance positive/negative cases
5. **Step 4**: Isolate environments
6. **Step 5**: Focus on outcomes, not paths
7. **Step 6**: Always read transcripts
8. **Step 7**: Monitor saturation
9. **Step 8**: Long-term maintenance

## Production Integration

### CI/CD
```yaml
- Run evals on push/PR
- Upload results as artifacts
- Gate deployments on pass rate
```

### Monitoring
- Sample production requests (10%)
- Alert on low quality scores
- A/B test agent versions

## Best Practices

### Do's ✅
- Start with 20-50 representative tasks
- Use code-based graders when possible
- Focus on outcomes, not paths
- Read transcripts for debugging

### Don'ts ❌
- Over-rely on uncalibrated model graders
- Ignore failed evals
- Grade on intermediate steps
- Let eval suites become stale

## Troubleshooting

| Problem | Solution |
|---------|----------|
| 100% scores | Add harder tasks, check saturation |
| Inconsistent grader | Add rubric examples, ensemble |
| Slow CI | Use toon mode, parallelize |
| Prod failures | Add production cases to suite |

## References
- [Anthropic: Demystifying evals](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)
- [SWE-bench](https://www.swebench.com/)
- [WebArena](https://webarena.dev/)
