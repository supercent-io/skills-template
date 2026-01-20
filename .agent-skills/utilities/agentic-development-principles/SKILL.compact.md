---
name: agentic-development-principles
description: AI 에이전트 협업의 범용 원칙
tags: [agentic-development, principles, ai-collaboration, universal]
platforms: [Claude, ChatGPT, Gemini]
---

# 에이전틱 개발 원칙

> "AI는 부조종사, 주인공은 당신입니다"

## 6대 원칙

### 1. 분해정복 (Divide and Conquer)
- 큰 문제 → 작은 명확한 단계로 분할
- 각 단계는 독립적으로 검증 가능해야 함
- 예: "로그인 만들어줘" ❌ → "1.UI 2.API 3.인증 4.테스트" ✅

### 2. 컨텍스트 관리 (Context is like Milk)
- 단일 목적 대화 유지
- 대화가 길어지면 HANDOFF.md 생성
- 여러 주제 혼합 시 성능 39% 저하

### 3. 추상화 수준 선택
| 모드 | 사용 시점 |
|------|----------|
| Vibe Coding | 프로토타입, 아이디어 검증 |
| Deep Dive | 버그 수정, 보안, 성능 최적화 |

### 4. 자동화의 자동화
- 3회 반복 → 자동화 방법 찾기
- 자동화 과정 자체도 자동화

### 5. 계획/실행 균형
- 계획 모드 70-90% 기본 사용
- 실행 모드는 안전한 환경에서만

### 6. 검증과 회고
- 테스트 코드 필수 작성
- 코드 리뷰로 확인
- "모든 주장 검증하고 표로 정리해줘"

## 황금률
```
AI에게 지시할 때:
1. 명확하게 (Specific)
2. 단계별로 (Step-by-step)
3. 검증 가능하게 (Verifiable)
```

## DO / DON'T
| DO | DON'T |
|----|-------|
| 단일 목적 대화 | 여러 주제 혼합 |
| 주기적 컨텍스트 정리 | 가득 찬 채로 계속 |
| 출력 항상 검증 | 검증 없이 사용 |
| 반복 작업 자동화 | 같은 작업 반복 |
