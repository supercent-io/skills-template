---
name: agent-configuration
description: AI 에이전트 설정 정책 및 보안 가이드
tags: [agent-configuration, security, hooks, skills, multi-agent]
platforms: [Claude, Gemini, ChatGPT, Codex]
---

# AI 에이전트 설정 정책

## 프로젝트 설명 파일 작성

### 필수 섹션
```markdown
# Project: [프로젝트명]

## Tech Stack
- Frontend: React + TypeScript

## Coding Standards
- Use TypeScript strict mode

## DO NOT
- Never use `any` type

## Common Commands
- `npm run dev`: Start dev server
```

### 원칙: 간결하게, 반복 시에만 추가

## Hooks 보안 설정 (Claude Code)

```json
{
  "hooks": {
    "PreToolUse": [
      { "pattern": "rm -rf /", "action": "block" },
      { "pattern": "curl * | sh", "action": "block" },
      { "pattern": "sudo rm", "action": "warn" }
    ]
  }
}
```

## Skills vs 기타 설정

| 기능 | 로딩 | 사용자 |
|------|------|--------|
| 프로젝트 설명 파일 | 항상 | 프로젝트 |
| Skills | 필요 시 | AI 자동 |
| Slash Commands | 호출 시 | 개발자 |

## 보안 정책

### 금지
- 호스트에서 무제한 권한 모드
- rm -rf / 자동 승인
- .env 커밋
- API 키 하드코딩

### 안전한 자동 승인
```bash
/sandbox "npm test"
/sandbox "git status"
```

### 정기 감사
```bash
npx cc-safe .
```

## 팀 설정 구조
```
.claude/
├── team-settings.json
├── hooks/
└── skills/

.agent-skills/
├── backend/
├── frontend/
└── ...
```
