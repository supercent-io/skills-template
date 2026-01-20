---
name: agentic-principles
description: AI 에이전트 협업 개발의 핵심 원칙
tags: [agentic-development, principles, multi-agent]
platforms: [Claude, Gemini, ChatGPT, Codex]
---

# AI 에이전트 협업 핵심 원칙

## 6대 원칙

### 1. 분해정복 (Divide and Conquer)
- 큰 문제 → 작은 명확한 단계로 분할
- 각 단계는 독립적으로 검증 가능해야 함
- 예: "로그인 만들어줘" X → "1.UI 2.API 3.인증 4.테스트" O

### 2. 컨텍스트 관리
- 단일 목적 대화 (탭 분리)
- 대화가 길어지면 HANDOFF.md 생성
- 컨텍스트 초기화로 성능 유지

### 3. 추상화 수준 선택
| 모드 | 사용 시점 |
|------|----------|
| Vibe Coding | 프로토타입, 아이디어 검증 |
| Deep Dive | 버그 수정, 보안, 성능 최적화 |

### 4. 자동화의 자동화
- 3회 반복 → 자동화 방법 찾기
- 프로젝트 설명 → 커스텀 명령어 → Skills → Hooks 순으로 발전

### 5. 계획 모드 vs 실행 모드
- 계획 모드 90% 기본 사용
- 실행 모드는 안전한 환경에서만 (컨테이너 등)

### 6. 검증과 회고
- 테스트 코드 필수 작성
- Draft PR로 리뷰
- "모든 주장 검증하고 표로 정리해줘"

## Multi-Agent 역할

| Agent | Role | Best For |
|-------|------|----------|
| Claude | Orchestrator | 계획, 코드 생성 |
| Gemini | Analyst | 대용량 분석, 리서치 |
| Codex | Executor | 명령 실행, 빌드 |

## Quick Reference
```
분해정복   → 작게 나눠서 명확히
컨텍스트  → 신선하게, 단일 목적
추상화    → 상황에 맞게 깊이 조절
자동화    → 3회 반복 시 자동화
계획/실행 → 계획 90%, 실행 10%
검증/회고 → 테스트, PR, 자기검증
```
