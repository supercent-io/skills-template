---
name: superwork
description: Opus 모델의 extended thinking을 활용한 고급 분석, 종합, 의사결정 서브에이전트. 복잡한 추론, 아키텍처 결정, 우선순위 판단에 사용.
aliases: [spw, super-work, opus-work]
allowed-tools: [Task, Read, Write, Grep, Glob, Bash]
tags: [superwork, spw, opus, extended-thinking, analysis, synthesis, decision-making, multi-agent, orchestrator]
platforms: [Claude, Gemini, ChatGPT, Codex, Cursor]
version: 1.0.0
---

# SuperWork (spw) - Opus Extended Thinking Agent

> Opus 모델의 깊은 추론 능력을 활용하여 복잡한 분석, 종합, 의사결정을 수행하는 서브에이전트

## When to use this skill

- **복잡한 분석 종합**: 여러 소스의 분석 결과를 종합해야 할 때
- **아키텍처 결정**: 시스템 설계나 기술 선택이 필요할 때
- **우선순위 결정**: 다수의 작업 중 순서를 정해야 할 때
- **디버깅 전략**: 복잡한 버그의 근본 원인을 분석할 때
- **리팩토링 계획**: 대규모 코드 개선 전략이 필요할 때

---

## 1. SuperWork 개요

### 핵심 개념

**SuperWork**는 Multi-Agent 시스템에서 "두뇌" 역할을 합니다:

```
[Worker x N] 데이터 수집/분석
      ↓
[SuperWork] 종합 → 판단 → 결정
      ↓
[Worker x N] 결정에 따라 실행
```

### 역할 분담

| 에이전트 | 모델 | 역할 | 특징 |
|---------|------|------|------|
| **SuperWork** | Opus | 분석, 종합, 의사결정 | Extended thinking, 깊은 추론 |
| **Worker** | Sonnet | 코드 검색, 구현, 테스트 | 빠른 실행, 병렬 처리 |
| **Executor** | Codex | 빌드, 배포, 명령 실행 | 시스템 명령 전문 |
| **Analyst** | Gemini | 대용량 분석 (1M+ 토큰) | 긴 컨텍스트 처리 |

---

## 2. 사용 방법

### 기본 호출

```bash
# Claude Code에서 SuperWork 호출
claude task --model opus "분석 결과를 종합하고 우선순위 결정. SuperWork."

# 또는 spw 별칭 사용
claude task --model opus "spw: 아키텍처 결정 필요"
```

### Task Tool 사용

```javascript
// Task tool로 SuperWork 호출
{
  "subagent_type": "general-purpose",
  "model": "opus",
  "prompt": "SuperWork: 다음 분석 결과를 종합하고 IMPLEMENTATION_PLAN.md 작성...",
  "description": "SuperWork synthesis"
}
```

### 프롬프트 패턴

```markdown
# SuperWork 프롬프트 템플릿

## Context
[분석 결과, 현재 상황, 제약 조건]

## Task
SuperWork: [수행할 작업 설명]

## Expected Output
- 종합 분석 결과
- 우선순위 목록
- 결정 사항 및 근거
- 다음 단계 액션 아이템
```

---

## 3. 워크플로우 패턴

### 패턴 1: 분석 종합 (Analysis Synthesis)

```
1. [Sonnet x N] 코드베이스 분석
   - 파일별 분석 결과 생성
   - analysis/*.md 파일로 저장

2. [SuperWork] 종합 분석
   - 모든 분석 결과 읽기
   - 패턴 및 문제점 식별
   - 우선순위 결정
   - IMPLEMENTATION_PLAN.md 작성

3. [Sonnet] 계획에 따라 실행
```

### 패턴 2: 디버깅 전략 (Debug Strategy)

```
1. [Codex] 테스트 실행 → 실패 로그 수집

2. [SuperWork] 원인 분석
   - 스택 트레이스 분석
   - 관련 코드 검토
   - 가설 수립 및 검증 순서 결정

3. [Sonnet] 가설 검증 및 수정
```

### 패턴 3: 아키텍처 결정 (Architecture Decision)

```
1. [Gemini] 요구사항 및 제약조건 분석

2. [SuperWork] 아키텍처 결정
   - 대안 비교 분석
   - 트레이드오프 평가
   - 최종 결정 및 ADR 작성

3. [Sonnet] 결정에 따라 구현
```

---

## 4. IMPLEMENTATION_PLAN.md 관리

### 파일 구조

```markdown
# Implementation Plan

## Priority 1: Critical (즉시 처리)
- [ ] 인증 토큰 갱신 버그 수정
- [ ] API 레이트 리미팅 추가

## Priority 2: High (이번 스프린트)
- [ ] 사용자 프로필 캐싱 구현
- [ ] 페이지네이션 추가

## Priority 3: Medium (다음 스프린트)
- [ ] DB 커넥션 풀링 리팩토링
- [ ] 에러 로깅 개선

## Completed
- [x] 프로젝트 구조 설정
- [x] CI/CD 파이프라인 구성
```

### SuperWork의 계획 업데이트 규칙

1. **작업 완료 시**: `[ ]` → `[x]`, Completed로 이동
2. **새 작업 발견 시**: 적절한 우선순위에 추가
3. **블로커 발견 시**: Priority 1으로 승격
4. **의존성 발견 시**: 순서 조정

---

## 5. 실전 예시

### 예시 1: 대규모 리팩토링 계획

```bash
# Step 1: 코드 분석 (Sonnet 병렬)
claude task "src/* 전체 파일의 코드 스멜 분석"

# Step 2: SuperWork 종합
claude task --model opus "
SuperWork: 분석 결과를 종합하세요.

## Input
- analysis/*.md 파일들

## Task
1. 주요 문제점 식별
2. 리팩토링 우선순위 결정
3. IMPLEMENTATION_PLAN.md 작성

## Constraints
- 기존 테스트 통과 유지
- 점진적 변경 (빅뱅 금지)
"

# Step 3: 계획에 따라 실행
claude task "IMPLEMENTATION_PLAN.md의 Priority 1 작업 수행"
```

### 예시 2: 버그 근본 원인 분석

```bash
# Step 1: 에러 정보 수집
codex-cli shell "npm test 2>&1 | tee test-output.log"

# Step 2: SuperWork 분석
claude task --model opus "
spw: 테스트 실패 원인을 분석하세요.

## Input
- test-output.log
- 관련 소스 코드

## Task
1. 스택 트레이스 분석
2. 근본 원인 가설 3개 수립
3. 검증 순서 및 방법 제시

## Output
- ROOT_CAUSE_ANALYSIS.md 작성
"
```

### 예시 3: 기술 선택 결정

```bash
claude task --model opus "
SuperWork: 상태 관리 라이브러리를 선택하세요.

## Context
- React 18 프로젝트
- 중규모 (50+ 컴포넌트)
- 실시간 데이터 필요

## Candidates
1. Redux Toolkit
2. Zustand
3. Jotai
4. React Query + Context

## Task
1. 각 옵션 장단점 분석
2. 프로젝트 요구사항과 매칭
3. 최종 추천 및 근거

## Output
- ADR (Architecture Decision Record) 작성
"
```

---

## 6. Best Practices

### DO (권장)

1. **명확한 컨텍스트 제공**: 분석에 필요한 모든 정보 포함
2. **구조화된 출력 요청**: 결과 형식 명시 (MD, JSON 등)
3. **제약 조건 명시**: 시간, 비용, 기술적 제약 포함
4. **결정 근거 요청**: 왜 그런 결정인지 기록

### DON'T (금지)

1. **단순 작업에 사용**: 코드 검색, 파일 읽기는 Sonnet으로
2. **컨텍스트 과부하**: 필요한 정보만 제공
3. **모호한 요청**: 구체적인 태스크 명시
4. **결과 미저장**: 항상 파일로 결과 저장

---

## 7. 트리거 키워드

다음 키워드로 SuperWork를 호출할 수 있습니다:

```
SuperWork:     # 전체 이름
spw:           # 짧은 별칭
super-work:    # 하이픈 버전
opus-work:     # 모델 기반 이름

# 예시
"spw: 분석 결과 종합해줘"
"SuperWork: 아키텍처 결정 필요"
```

---

## 8. 다른 에이전트와의 연계

### Multi-Agent 오케스트레이션

```yaml
workflow:
  name: "Feature Implementation"
  steps:
    - agent: Gemini
      task: "요구사항 분석"
      output: requirements.md

    - agent: Sonnet (x10)
      task: "관련 코드 분석"
      output: analysis/*.md

    - agent: SuperWork  # Opus
      task: "종합 및 계획 수립"
      input: [requirements.md, analysis/*.md]
      output: IMPLEMENTATION_PLAN.md

    - agent: Sonnet
      task: "Priority 1 구현"
      input: IMPLEMENTATION_PLAN.md

    - agent: Codex
      task: "테스트 및 빌드"
```

### OpenContext 연계

```bash
# 작업 시작 전: 컨텍스트 로드
oc_search query="이전 아키텍처 결정"

# SuperWork 실행
claude task --model opus "spw: ADR 작성"

# 작업 완료 후: 결정사항 저장
oc_create_doc folder="project/decisions" title="ADR-001-state-management.md"
```

---

## Quick Reference

### 호출 방법
```bash
claude task --model opus "SuperWork: [태스크]"
claude task --model opus "spw: [태스크]"
```

### 주요 용도
- 분석 종합
- 아키텍처 결정
- 우선순위 결정
- 디버깅 전략
- 계획 수립

### 출력 파일
- `IMPLEMENTATION_PLAN.md` - 작업 계획
- `ADR-*.md` - 아키텍처 결정 기록
- `ROOT_CAUSE_ANALYSIS.md` - 원인 분석

### 태그
`#superwork` `#spw` `#opus` `#extended-thinking` `#analysis` `#synthesis` `#decision-making`

---

## References

- [agent-workflow](../agent-workflow/SKILL.md) - 전체 멀티에이전트 워크플로우
- [subagent-creation](../subagent-creation/SKILL.md) - 서브에이전트 생성
- [Ralph Wiggum Technique](https://github.com/ghuntley/how-to-ralph-wiggum)
