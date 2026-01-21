# agent-workflow

> Design principles for multi-agent workflows with validation gates using the Ralph Wiggum technique. Use when orchestrating multiple AI agents for complex autonomous tasks.

## When to use this skill
- **대규모 코드베이스 분석**: 500+ 파일
- **복잡한 구현 작업**: 아키텍처, 디버깅, 리팩토링
- **자율 개발 루프**: 장시간 자율 실행
- **멀티 모델 협업**: Opus, Sonnet, Gemini, Codex
- **스킬 스택 오케스트레이션**: 여러 스킬 시퀀싱

## Core Concepts
**Ralph Wiggum**: Bash loop + 파일시스템 상태 관리
**Ultrathink**: Opus extended thinking for analysis
**Validation Gates**: 각 단계별 품질 검증

## Agent Roles
| Agent | Role |
|-------|------|
| Opus | Orchestrator: 분석, 종합, 우선순위 |
| Sonnet | Worker: 코드 검색, 파일 읽기, 구현 |
| Gemini | Analyst: 대용량 분석 (1M+ 토큰) |
| Codex | Executor: 빌드, 테스트, 배포 |

## Validation Gates
- **Gate A**: Messaging & Positioning Review
- **Gate B**: Design System Consistency
- **Gate C**: Asset QA (images/video)
- **Gate D**: Code Quality & Tests
- **Gate E**: Deck Narrative & Polish

## Skill Stack Sequence
1. Marketing strategy → Gate A
2. Frontend design → Gate B
3. Image generation → Gate C
4. Video production → Gate C
5. Code refactoring → Gate D
6. Presentation deck → Gate E

## Best practices
1. **항상 max-iterations 설정**: 비용 제어
2. **IMPLEMENTATION_PLAN.md 사용**: 진행 추적
3. **Git 체크포인트**: 롤백 가능
4. **Handoff 문서화**: 컨텍스트 전달

## Constraints
**MUST**: 비용 제어, 상태 저장, 역할 분리
**MUST NOT**: 무제한 루프, 단일 에이전트 독점
