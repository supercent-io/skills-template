---
name: claude-code-principles
description: Claude Code 에이전틱 개발의 핵심 원칙
tags: [claude-code, agentic-development, principles]
---

# Claude Code 핵심 원칙

## 6대 원칙

### 1. 분해정복 (Divide and Conquer)
- 큰 문제 → 작은 명확한 단계로 분할
- 각 단계는 독립적으로 검증 가능해야 함
- 예: "로그인 만들어줘" ❌ → "1.UI 2.API 3.인증 4.테스트" ✅

### 2. 컨텍스트 관리
- 단일 목적 대화 (탭 분리)
- 50k 토큰 초과 시 HANDOFF.md 생성
- `/context`로 상태 확인, `/clear`로 초기화
- MCP <10개, 도구 <80개 유지

### 3. 추상화 수준 선택
| 모드 | 사용 시점 |
|------|----------|
| Vibe Coding | 프로토타입, 아이디어 검증 |
| Deep Dive | 버그 수정, 보안, 성능 최적화 |

### 4. 자동화의 자동화
- 3회 반복 → 자동화 방법 찾기
- CLAUDE.md → Slash Commands → Skills → Hooks 순으로 발전

### 5. 계획 모드 vs YOLO 모드
- 계획 모드 90% 기본 사용 (Shift+Tab ×2)
- YOLO 모드 컨테이너 내에서만 사용

### 6. 검증과 회고
- 테스트 코드 필수 작성
- Draft PR로 리뷰
- "모든 주장 검증하고 표로 정리해줘"

## Quick Reference
```
/clear     → 컨텍스트 초기화
/context   → 사용량 확인
Esc Esc    → 작업 취소
Ctrl+R     → 히스토리 검색
Shift+Tab×2 → 계획 모드
```
