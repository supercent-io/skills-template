# code-refactoring

> Simplify and refactor code while preserving behavior, improving clarity, and reducing complexity. Use when simplifying complex code, removing duplication, or applying design patterns.

## When to use this skill
- **코드 리뷰**: 복잡하거나 중복된 코드 발견
- **새 기능 추가 전**: 기존 코드 정리
- **버그 수정 후**: 근본 원인 제거
- **기술 부채 해소**: 정기적인 리팩토링

## Instructions
**S1: Extract Method** - 긴 함수를 작은 단위로 분리
**S2: Remove Duplication** - 공통 로직 추출
**S3: Replace Conditional** - if-else → 다형성
**S4: Parameter Object** - 많은 파라미터 → 객체 그룹화
**S5: SOLID 원칙** - 단일 책임, 의존성 주입

## Behavior Validation
1. **Understand**: 입력/출력/부수효과/불변조건 파악
2. **Validate**: 테스트 실행, 타입체크, 린트
3. **Document**: 변경 요약, 위험/후속 작업

## Constraints
**MUST**: 테스트 먼저, 작은 단계, 동작 보존
**MUST NOT**: 동시 여러 작업, 테스트 없이 리팩토링

## Best practices
1. Boy Scout Rule
2. Red-Green-Refactor
3. 점진적 개선
4. 행동 보존
5. 작은 커밋

## Validation (Multi-Agent)
- R1 (Orchestrator): 행동 보존 체크리스트
- R2 (Analyst): 복잡도/중복 분석
- R3 (Executor): 테스트/정적 분석 검증
