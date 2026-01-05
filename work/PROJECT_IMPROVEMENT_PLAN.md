# Skills-Template Project Improvement Plan

## Overview
Multi-agent workflow를 활용한 skills-template 프로젝트 개선 계획

**작업 방식**: Claude Code (Planning/Coordination) + Gemini-CLI (AI Analysis) + Codex-CLI (Execution)

---

## Phase 1: 프로젝트 정리 (Cleanup)

### 1.1 중복 파일 제거
| 상태 | 작업 | 파일/폴더 |
|------|------|----------|
| [ ] | 삭제 | `.claude/skills/` (중복 - .agent-skills와 동일) |
| [ ] | 삭제 | `templates/` (루트 - .agent-skills/templates와 중복) |
| [ ] | 검토 | `agent_skills_implementation_summary.md` (분석 파일) |
| [ ] | 검토 | `agentskills-official-analysis.md` (분석 파일) |
| [ ] | 검토 | `comparison-analysis.md` (분석 파일) |
| [ ] | 검토 | `universal_agent_skills_architecture.md` (아키텍처 문서) |
| [ ] | 삭제 | `firebase-debug.log` (루트 + .agent-skills 모두) |
| [ ] | 검토 | `.agent-skills/prompt/` (prompt/와 중복 가능성) |

### 1.2 불필요 파일 제거
| 상태 | 파일 | 이유 |
|------|------|------|
| [ ] | `.DS_Store` | 시스템 파일 |
| [ ] | `firebase-debug.log` | 임시 로그 |

---

## Phase 2: setup.sh 멀티 플랫폼 지원

### 2.1 지원 플랫폼
```
┌──────────────────────────────────────────────────────────────┐
│                    setup.sh 통합 설정                         │
├──────────────────────────────────────────────────────────────┤
│  1. Claude Code                                               │
│     - ~/.claude/skills/ 에 스킬 복사                          │
│     - .claude/settings.json MCP 설정 추가                    │
│                                                               │
│  2. GPT Codex                                                 │
│     - ~/.codex/skills/ 에 스킬 복사                           │
│     - codex.json MCP 설정 추가                               │
│                                                               │
│  3. Gemini CLI                                                │
│     - ~/.gemini/skills/ 에 스킬 복사                          │
│     - gemini-cli 설정 추가                                   │
│                                                               │
│  4. MCP 통합                                                  │
│     - mcp_config.json 생성                                   │
│     - codex-cli, gemini-cli 서버 설정                        │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 설정 파일 생성
- [ ] Claude: `.claude/settings.json` 업데이트
- [ ] Codex: `codex.json` 생성
- [ ] Gemini: `gemini.json` 생성
- [ ] MCP 통합 설정: `mcp_config.json`

---

## Phase 3: 신규 스킬 추가 시스템

### 3.1 add_new_skill.sh 스크립트
```bash
# 사용법
./add_new_skill.sh <category> <skill-name> [--template basic|advanced]

# 예시
./add_new_skill.sh backend api-caching --template advanced
```

### 3.2 자동화 기능
- [ ] 폴더 구조 자동 생성
- [ ] SKILL.md 템플릿 적용
- [ ] skills.json 매니페스트 자동 업데이트
- [ ] TOON 포맷 자동 변환
- [ ] 유효성 검증

---

## Phase 4: TOON 포맷 구현

### 4.1 TOON (Token-Oriented Object Notation)
```
특징:
- JSON 대비 30-60% 토큰 절감
- YAML 들여쓰기 + CSV 표 형식 하이브리드
- 반복 키 제거로 효율성 향상
- LLM 친화적 구조
```

### 4.2 TOON 변환기 구현
- [ ] `scripts/toon_converter.py` 생성
- [ ] JSON → TOON 인코더
- [ ] TOON → JSON 디코더
- [ ] 토큰 절감 통계 출력
- [ ] CLI 인터페이스

### 4.3 TOON 스킬 포맷
```toon
# SKILL.toon 예시
skills[30]{name,category,description,tools}
api-design,backend,"RESTful API 설계",Read|Write|Edit
code-review,code-quality,"코드 리뷰 수행",Read|Grep|Glob
...
```

### 4.4 스킬 로더 업데이트
- [ ] SKILL.md 와 SKILL.toon 모두 지원
- [ ] 자동 포맷 감지
- [ ] 런타임 변환

---

## Phase 5: 매니페스트 시스템 개선

### 5.1 skills.json 구조 개선
```json
{
  "version": "2.0.0",
  "format": "toon",
  "platforms": ["claude", "gpt", "gemini"],
  "skills": [...],
  "mcp_integration": {
    "codex-cli": {...},
    "gemini-cli": {...}
  }
}
```

### 5.2 자동 갱신
- [ ] 스킬 추가/수정 시 자동 매니페스트 갱신
- [ ] Git hooks 연동
- [ ] CI/CD 통합

---

## 작업 진행 상황

### 현재 상태
| Phase | 상태 | 진행률 |
|-------|------|--------|
| Phase 1 | ✅ 완료 | 100% |
| Phase 2 | ✅ 완료 | 100% |
| Phase 3 | ✅ 완료 | 100% |
| Phase 4 | ✅ 완료 | 100% |
| Phase 5 | ✅ 완료 | 100% |

### 완료된 작업
1. ✅ 중복 파일 정리 (.claude/skills, templates, logs)
2. ✅ 분석 문서 docs/ 폴더로 이동
3. ✅ TOON 변환기 구현 (35.9% 토큰 절감)
4. ✅ add_new_skill.sh 스크립트 생성
5. ✅ skills.toon 매니페스트 생성

---

## 멀티 에이전트 역할

| Agent | 역할 | 담당 작업 |
|-------|------|----------|
| Claude Code | Coordinator | 계획 수립, 통합 조율 |
| Gemini-CLI | Analyst | TOON 포맷 분석, 최적화 제안 |
| Codex-CLI | Executor | 파일 생성/수정, 스크립트 실행 |

---

**최종 업데이트**: 2025-01-05
**버전**: 1.0.0
