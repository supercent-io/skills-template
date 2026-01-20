---
name: claude-code-workflow
description: Claude Code 실전 워크플로우와 생산성 기법. 명령어, 단축키, Git 통합, MCP 활용, 세션 관리 등 일상 개발 작업의 최적화 패턴 제공.
allowed-tools: [Read, Write, Bash, Grep, Glob]
tags: [claude-code, workflow, productivity, git, mcp, commands]
platforms: [Claude]
version: 1.0.0
source: Claude Code 완전 가이드 70가지 팁 (ykdojo + Ado Kukic)
---

# Claude Code 워크플로우 (Workflow & Productivity)

## When to use this skill

- 일상적인 Claude Code 작업 최적화
- Git/GitHub 워크플로우 통합
- MCP 서버 활용
- 세션 관리 및 복구
- 생산성 향상 기법 적용

---

## 1. 필수 슬래시 명령어

### Tier 1: 생존 필수

| 명령어 | 기능 | 사용 시점 |
|--------|------|----------|
| `/init` | CLAUDE.md 초안 자동 생성 | 새 프로젝트 시작 |
| `/usage` | 토큰 사용량/리셋 시간 표시 | 매 세션 시작 |
| `/clear` | 대화 내용 초기화 | 컨텍스트 오염 시, 새 작업 시작 |
| `/context` | 컨텍스트 윈도우 X-Ray | 성능 저하 시 |
| `/stats` | 활동 그래프, 사용 패턴 | 주간 회고 |

### Tier 2: 생산성 향상

| 명령어 | 기능 | 사용 시점 |
|--------|------|----------|
| `/clone` | 대화 전체 복제 | A/B 비교 실험, 백업 |
| `/half-clone` | 대화 절반만 복제 | 컨텍스트 절반 줄이기 |
| `/rename` | 세션 이름 변경 | 중요 작업 라벨링 |
| `/export` | 마크다운으로 내보내기 | 문서화, 팀 공유 |
| `/mcp` | MCP 서버 관리 | MCP 활성화/비활성화 |
| `/permissions` | 승인 명령어 관리 | 보안 감사 |
| `/sandbox` | 자동 승인 명령어 설정 | 반복 작업 자동화 |

### ! Prefix: 즉시 실행
```bash
# Claude 처리 없이 즉시 셸 명령 실행
!git status      # 즉시 실행
!npm test        # 토큰 절약
!docker ps       # 빠른 상태 확인
```

---

## 2. 키보드 단축키

### 필수 단축키

| 단축키 | 기능 | 중요도 |
|--------|------|--------|
| `Esc Esc` | 마지막 작업 즉시 취소 | ⭐⭐⭐ |
| `Ctrl+R` | 이전 프롬프트 히스토리 검색 | ⭐⭐⭐ |
| `Shift+Tab` ×2 | 계획 모드 토글 | ⭐⭐⭐ |
| `Tab` / `Enter` | 프롬프트 제안 수락 | ⭐⭐ |
| `Ctrl+B` | 백그라운드로 보내기 | ⭐⭐ |
| `Ctrl+S` | 프롬프트 임시 저장 (Stash) | ⭐⭐ |
| `Ctrl+G` | 외부 에디터로 편집 | ⭐ |
| `Alt+P` / `Option+P` | 모델 전환 | ⭐ |

### 에디터 편집 단축키

| 단축키 | 기능 |
|--------|------|
| `Ctrl+A` | 줄 시작으로 이동 |
| `Ctrl+E` | 줄 끝으로 이동 |
| `Ctrl+W` | 이전 단어 삭제 |
| `Ctrl+U` | 줄 시작까지 삭제 |
| `Ctrl+K` | 줄 끝까지 삭제 |

### 여러 줄 입력
```bash
# 방법 1: \ 입력 후 Enter
\

# 방법 2: Ctrl+G로 외부 에디터 사용
export EDITOR=vim  # 또는 code, nano
```

---

## 3. 세션 관리

### 세션 이어가기
```bash
# 마지막 대화 이어서 시작
claude --continue
# 또는
cc  # 별칭 사용

# 특정 세션 재개
claude --resume <session-name>
```

### 세션 이름 지정
```bash
# 대화 중에
/rename stripe-integration

# 나중에 복구
claude --resume stripe-integration
```

### 원격 세션 가져오기
```bash
# 웹에서 시작한 세션을 로컬로 이전
claude --teleport <session_id>
```

### 권장 별칭 설정
```bash
# ~/.zshrc 또는 ~/.bashrc
alias c='claude'
alias cc='claude --continue'
alias cr='claude --resume'
alias ch='claude --chrome'
```

---

## 4. Git 워크플로우

### 자동 커밋 메시지 생성
```
"변경 사항을 분석하고 적절한 커밋 메시지를 작성한 후 커밋해줘"
```

### Draft PR 자동 생성
```
"현재 브랜치의 변경 사항으로 draft PR을 만들어줘.
제목은 변경 내용을 요약하고, 본문에는 주요 변경 사항을 리스트로 작성해줘."
```

### Git Worktrees 활용
```bash
# 여러 브랜치 동시 작업
git worktree add ../myapp-feature-auth feature/auth
git worktree add ../myapp-hotfix hotfix/critical-bug

# 각 worktree에서 독립적 Claude 세션
탭 1: ~/myapp-feature-auth → 새 기능 개발
탭 2: ~/myapp-hotfix → 긴급 버그 수정
탭 3: ~/myapp (main) → 메인 브랜치 유지
```

### PR 리뷰 워크플로우
```
1. "gh pr checkout 123을 실행하고 이 PR의 변경 사항을 요약해줘"
2. "src/auth/middleware.ts 파일의 변경점을 분석해줘. 보안 이슈나 성능 문제가 있는지 확인해줘"
3. "이 로직을 더 효율적으로 바꿀 방법이 있을까?"
4. "네가 제안한 개선 사항을 적용하고 테스트를 실행해줘"
```

---

## 5. MCP 서버 활용

### 주요 MCP 서버

| MCP 서버 | 기능 | 설치 명령 |
|----------|------|----------|
| Playwright | 웹 브라우저 제어 | `claude mcp add playwright npx @playwright/mcp@latest` |
| Supabase | 데이터베이스 쿼리 | `claude mcp add supabase npx @supabase/mcp@latest` |
| Firecrawl | 웹 크롤링 | `claude mcp add firecrawl npx @firecrawl/mcp@latest` |
| Gemini-CLI | 대용량 분석 | `claude mcp add gemini-cli npx -y gemini-mcp-tool` |
| Codex-CLI | 명령 실행 | `claude mcp add codex-cli npx -y @openai/codex-mcp` |

### MCP 활용 예시
```bash
# Supabase: 직접 DB 쿼리
> "Supabase 데이터베이스의 users 테이블에서 지난 7일간 가입한 사용자 수를 조회해줘"

# Playwright: E2E 테스트
> "Playwright를 사용하여 로그인 폼을 테스트해줘. 잘못된 비밀번호 입력 시 에러 메시지가 표시되는지 확인해"

# Gemini: 대용량 분석
> ask-gemini "@src/ 전체 코드베이스 구조 분석해줘"
```

### MCP 최적화
```bash
# 사용하지 않는 MCP 비활성화
/mcp

# 권장 수치
# - MCP 서버: 10개 미만
# - 활성 도구: 80개 미만
```

---

## 6. 실전 워크플로우 패턴

### TDD 워크플로우
```
"TDD 방식으로 작업해줘. 먼저 실패하는 테스트를 작성하고,
그 테스트를 통과시키는 코드를 작성해줘."

# Claude가:
# 1. 실패하는 테스트 작성
# 2. git commit -m "Add failing test for user auth"
# 3. 테스트를 통과시키는 최소한의 코드 작성
# 4. 테스트 실행 → 통과 확인
# 5. git commit -m "Implement user auth to pass test"
```

### 작성-테스트 사이클
```
"사용자 인증 미들웨어를 작성하고, 테스트 코드도 함께 작성해줘.
테스트를 실행하여 모두 통과하는지 확인해줘."
```

### CI/CD 통합 (Headless 모드)
```bash
# CLI에서 직접 실행
claude -p "이 코드를 분석하고 버그를 찾아줘" < input.txt

# 파이프라인 통합
git diff | claude -p "Explain these changes"

# GitHub Actions
- name: Code Review
  run: |
    claude -p "PR의 변경사항을 리뷰해줘" \
      --output review.md
```

### 백그라운드 작업
```bash
# 장시간 명령어 백그라운드 실행
# Ctrl+B 누르면 백그라운드로 이동

# 서브에이전트 백그라운드 실행
> "security-auditor 에이전트를 백그라운드에서 실행하여
전체 코드베이스를 스캔해줘. 완료되면 알려줘."
```

---

## 7. 컨테이너 워크플로우

### Docker 컨테이너 설정
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    curl git tmux vim nodejs npm python3 python3-pip
RUN curl -fsSL https://claude.ai/install.sh | sh
WORKDIR /workspace
CMD ["/bin/bash"]
```

### 안전한 YOLO 모드
```bash
# 컨테이너 빌드 및 실행
docker build -t claude-sandbox .
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  claude-sandbox

# 컨테이너 안에서만 YOLO 모드 사용
claude --dangerously-skip-permissions
```

### 워커 Claude 오케스트레이션
```
메인 Claude → tmux → 컨테이너 내 워커 Claude
# 위험한 실험은 컨테이너에서, 안전한 작업은 로컬에서
```

---

## 8. 문제 해결

### 컨텍스트 과다 시
```bash
/context  # 사용량 확인
/clear    # 컨텍스트 초기화

# 또는 HANDOFF.md 생성 후 새 세션
```

### 작업 취소
```
Esc Esc  # 마지막 작업 즉시 취소
```

### 승인된 명령어 감사
```bash
# cc-safe 도구로 위험한 명령어 검사
npx cc-safe .

# 감지 대상: sudo, rm -rf, chmod 777, curl | sh 등
```

---

## Quick Reference Card

```
=== 필수 명령어 ===
/clear      컨텍스트 초기화
/context    사용량 확인
/usage      토큰 확인
/init       CLAUDE.md 생성
!command    즉시 실행

=== 단축키 ===
Esc Esc     작업 취소
Ctrl+R      히스토리 검색
Shift+Tab×2 계획 모드
Ctrl+B      백그라운드

=== CLI 플래그 ===
--continue  대화 이어가기
--resume    세션 복구
-p "prompt" Headless 모드

=== 문제 해결 ===
컨텍스트 과다 → /clear
작업 취소 → Esc Esc
성능 저하 → /context 확인
```
