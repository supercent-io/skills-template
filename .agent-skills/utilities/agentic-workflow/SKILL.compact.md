---
name: agentic-workflow
description: AI 에이전트 실전 워크플로우와 생산성 기법
tags: [agentic-workflow, productivity, git, mcp, multi-agent]
platforms: [Claude, Gemini, ChatGPT, Codex]
---

# AI 에이전트 워크플로우

## 필수 명령어 (Claude Code)
| 명령어 | 기능 |
|--------|------|
| `/init` | 프로젝트 설명 파일 생성 |
| `/clear` | 컨텍스트 초기화 |
| `/context` | 사용량 X-Ray |
| `/clone` | 대화 복제 |
| `/mcp` | MCP 서버 관리 |
| `!cmd` | 즉시 실행 |

## 단축키
| 키 | 기능 |
|----|------|
| `Esc Esc` | 작업 취소 |
| `Ctrl+R` | 히스토리 검색 |
| `Shift+Tab` x2 | 계획 모드 |
| `Ctrl+B` | 백그라운드 실행 |

## CLI 별칭
```bash
alias c='claude'
alias cc='claude --continue'
alias cr='claude --resume'
alias g='gemini'
alias cx='codex'
```

## Git 워크플로우
- 자동 커밋: "변경 사항 분석하고 커밋해줘"
- Draft PR: "draft PR 만들어줘"
- Worktrees: 여러 브랜치 동시 작업

## Multi-Agent 패턴
```
[Claude] 계획 → [Gemini] 분석 → [Claude] 코드 → [Codex] 실행 → [Claude] 종합
```

## MCP 서버
| MCP | 기능 |
|-----|------|
| Playwright | 웹 브라우저 제어 |
| Supabase | DB 직접 쿼리 |
| Gemini-CLI | 대용량 분석 |
| Codex-CLI | 명령 실행 |

## 문제 해결
- 컨텍스트 과다 → `/clear`
- 작업 취소 → `Esc Esc`
- 성능 저하 → `/context` 확인
