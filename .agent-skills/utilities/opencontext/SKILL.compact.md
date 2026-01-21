---
name: opencontext
description: OpenContext를 활용한 AI 에이전트 영구 메모리 및 컨텍스트 관리
tags: [opencontext, context-management, memory, multi-agent]
platforms: [Claude, Gemini, ChatGPT, Codex, Cursor]
---

# OpenContext 컨텍스트 관리

## 핵심 개념
- AI 에이전트에게 영구 메모리 부여
- 세션/레포/날짜 간 컨텍스트 유지
- 반복 설명 제거

## 설치
```bash
npm install -g @aicontextlab/cli
cd your-project && oc init
```

## Slash Commands
| Command | 용도 |
|---------|------|
| `/opencontext-context` | 작업 전 배경 로드 (권장) |
| `/opencontext-search` | 기존 문서 검색 |
| `/opencontext-create` | 새 문서 작성 |
| `/opencontext-iterate` | 결론 저장 |

## CLI 명령어
```bash
oc folder ls --all           # 폴더 목록
oc doc ls <folder>           # 문서 목록
oc search "query" --mode keyword  # 검색
oc doc create folder doc.md  # 문서 생성
oc context manifest folder   # 매니페스트
```

## MCP Tools
```
oc_list_folders   폴더 목록
oc_list_docs      문서 목록
oc_search         검색
oc_manifest       매니페스트
oc_create_doc     문서 생성
oc_get_link       링크 생성
```

## 일일 워크플로우
```
작업 전: /opencontext-context (1분)
작업 중: /opencontext-search
작업 후: /opencontext-iterate (2분)
```

## Multi-Agent 패턴
```
[Claude] 계획 + /opencontext-context
    ↓
[Gemini] 분석 + oc_search
    ↓
[Claude] 코드 작성
    ↓
[Codex] 실행/테스트
    ↓
[Claude] 결과 + /opencontext-iterate
```

## 경로
```
~/.opencontext/contexts      컨텍스트
~/.opencontext/opencontext.db  DB
```
