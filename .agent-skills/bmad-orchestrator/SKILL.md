---
name: bmad-orchestrator
description: Orchestrates BMAD workflows for structured AI-driven development. Routes work across Analysis, Planning, Solutioning, and Implementation phases.
allowed-tools: Read Write Bash Grep Glob
metadata:
  tags: bmad, orchestrator, workflow, planning, implementation
  platforms: Claude, Gemini, Codex, OpenCode
  keyword: bmad
  version: 1.0.0
  source: user-installed skill
---


# bmad-orchestrator - BMAD Workflow Orchestration

## When to use this skill

- Initializing BMAD in a new project
- Checking and resuming BMAD workflow status
- Routing work across Analysis, Planning, Solutioning, and Implementation
- Managing structured handoff between phases

---

## Installation

```bash
npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator
```

## Codex 사용 참고

`bmad-orchestrator`의 기본 실행 경로는 Claude Code입니다.  
Codex에서 직접 동일한 흐름으로 사용하려면 `omx`/`ohmg` 등 상위 오케스트레이션 경로를 통해 BMAD 단계를 운영하는 것을 권장합니다.

---

## BMAD Execution Commands

## 플랫폼별 적용 상태 (현재 지원 기준)

| 플랫폼 | 현재 지원 방식 | 적용 조건 |
|---|---|---|
| Gemini CLI | 네이티브(권장) | `bmad` 키워드 등록 후 `/workflow-init` 실행 |
| Claude Code | 네이티브(권장) | 스킬 설치 + `기억해` 패턴 |
| OpenCode | 오케스트레이션 연동 | `omx`/`ohmg`/`omx` 류 브릿지 사용 |
| Codex | 오케스트레이션 연동 | `omx`/`ohmg`류 브릿지 사용 |

`현재 스킬만`으로 가능한지:  
- Gemini CLI/Claude Code: **가능**  
- OpenCode/Codex: **가능(오케스트레이션 경유)**

Use these in your AI session:

```text
/workflow-init
/workflow-status
```

Typical flow:

1. Run `/workflow-init` to bootstrap BMAD config.
2. Move through phases in order: Analysis -> Planning -> Solutioning -> Implementation.
3. Run `/workflow-status` any time to inspect current phase and progress.

---

## Quick Reference

| Action | Command |
|--------|---------|
| Initialize BMAD | `/workflow-init` |
| Check BMAD status | `/workflow-status` |


---

## plannotator Integration (Phase Review Gate)

Each BMAD phase produces a key document (PRD, Tech Spec, Architecture). Before transitioning to the next phase, review that document with **plannotator** and auto-save it to Obsidian.

### Why use plannotator with BMAD?

- **Quality gate**: Approve or request changes before locking in a phase deliverable
- **Obsidian archive**: Every approved phase document auto-saves with YAML frontmatter and `[[BMAD Plans]]` backlink
- **Team visibility**: Share a plannotator link so stakeholders can annotate the PRD/Architecture before implementation begins

### Phase Review Pattern

After completing any phase document, submit it for review:

```bash
# After /prd → docs/prd-myapp-2026-02-22.md is created
bash scripts/phase-gate-review.sh docs/prd-myapp-2026-02-22.md "PRD Review: myapp"

# After /architecture → docs/architecture-myapp-2026-02-22.md is created
bash scripts/phase-gate-review.sh docs/architecture-myapp-2026-02-22.md "Architecture Review: myapp"
```

Or submit the plan directly from within your AI session:

```text
# In Claude Code after /prd completes:
planno — review the PRD before we proceed to Phase 3
```

The agent will call `submit_plan` with the document content, opening the plannotator UI for review.

### Phase Gate Flow

```
/prd completes → docs/prd-myapp.md created
       ↓
 bash scripts/phase-gate-review.sh docs/prd-myapp.md
       ↓
 plannotator UI opens in browser
       ↓
  [Approve]              [Request Changes]
       ↓                        ↓
 Obsidian saved          Agent revises doc
 bmm-workflow-status     Re-submit for review
 updated automatically
       ↓
 /architecture (Phase 3)
```

### Obsidian Save Format

Approved phase documents are saved to your Obsidian vault with:

```yaml
---
created: 2026-02-22T22:45:30.000Z
source: plannotator
tags: [bmad, phase-2, prd, myapp]
---

[[BMAD Plans]]

# PRD: myapp
...
```

### Quick Reference

| Phase | Document | Gate Command |
|-------|----------|--------------|
| Phase 1 → 2 | Product Brief | `bash scripts/phase-gate-review.sh docs/product-brief-*.md` |
| Phase 2 → 3 | PRD / Tech Spec | `bash scripts/phase-gate-review.sh docs/prd-*.md` |
| Phase 3 → 4 | Architecture | `bash scripts/phase-gate-review.sh docs/architecture-*.md` |
| Phase 4 done | Sprint Plan | `bash scripts/phase-gate-review.sh docs/sprint-status.yaml` |

---

## TOON Format Integration (Skill Injection)

TOON(Token-Oriented Object Notation)은 JSON/YAML 대비 40-50% 토큰 절감을 달성하는 LLM 최적화 스킬 포맷입니다. 플랫폼 훅/설정을 통해 JSON·YAML 스킬 파일을 TOON 포맷으로 변환하여 모든 프롬프트에 자동 주입합니다.

### TOON 포맷 기본 구조

```
N:skill-name
D:one-line description
G:tag1 tag2 tag3
U[3]:
  Use case 1
  Use case 2
  Use case 3
S[3]{n,action,details}:
  1,Step one,details
  2,Step two,details
  3,Step three,details
R[3]:
  Rule 1
  Rule 2
  Rule 3
E[1]{desc,in,out}:
  "example","input","output"
```

**필드 축약어**: `N` = name, `D` = description, `G` = tags, `U` = use_cases, `S` = steps, `R` = rules, `E` = examples

### Two-Tier Injection Architecture

| Tier | 내용 | 토큰 비용 | 트리거 |
|------|------|----------|-------|
| **Tier 1** — Catalog Index | 전체 스킬 목록 (이름+설명+태그) | ~875–3,500 tokens | 항상 주입 (키워드 매칭 시) |
| **Tier 2** — Full SKILL.toon | 개별 스킬 전체 내용 (U/S/R/E 포함) | ~292 tokens/skill, max 3 | 프롬프트에서 스킬 이름/태그 감지 시 |

> **전체 71개 SKILL.toon 동시 주입은 ~20,700 tokens으로 금지.** Tier 1 단독 운용 또는 Tier 1+2 최대 3개 온디맨드 로딩을 원칙으로 합니다.

---

### Claude Code 설정

**파일**: `~/.claude/hooks/toon-inject.mjs` (Node.js hook)

Claude Code의 `UserPromptSubmit` 훅으로 동작합니다. **Python 대신 Node.js를 사용하는 이유**: `~/.claude/skills/` 하위 디렉토리는 `~/.agents/skills/`로의 심링크이며, Python `Path.rglob()`은 심링크를 따르지 않아 0개를 반환합니다. Node.js `readdirSync`는 심링크를 투명하게 따릅니다.

**3단계 키워드 매칭**:

| 단계 | 패턴 | 동작 |
|------|------|------|
| 1 | `/skill`, `use skill`, `skill catalog`, `available skills`, `list skills` | 전체 카탈로그 주입 |
| 2 | 스킬 이름 또는 G: 태그가 프롬프트에 포함 | 매칭 스킬만 주입 |
| 3 | `autopilot`, `ralph`, `team`, `agent` 등 워크플로우 키워드 | 전체 카탈로그 주입 |
| — | 해당 없음 | 무음, exit 0 (프롬프트 통과) |

**`~/.claude/settings.json` 설정**:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "\"/path/to/node\" \"/Users/supercent/.claude/hooks/toon-inject.mjs\"",
        "timeout": 10
      }
    ]
  }
}
```

> `matcher`는 `PermissionRequest` 훅에만 작동합니다. `UserPromptSubmit`에는 불필요하며 스크립트 내부에서 키워드 게이트를 처리합니다.

**출력 형식**:

```
=== TOON SKILLS (2) ===
N:omc  D:oh-my-claudecode — Teams-first multi-agent orchestration...
N:ralph  D:Specification-first AI development powered by Ouroboros...
=== END SKILLS ===
```

**환경 변수 오버라이드**:

| 변수 | 설명 |
|------|------|
| `TOON_SKILLS_DIR` | 스킬 디렉토리 경로 변경 |
| `TOON_ALL=1` | 모든 프롬프트에 항상 주입 (디버그) |
| `TOON_MAX_SKILLS=N` | 주입 스킬 수 상한 (기본: 20) |
| `TOON_VERBOSE=1` | stderr에 디버그 로그 출력 |

**성능**: Node.js 시작 + 58개 SKILL.toon 읽기 포함 26-37ms. 오류 시 항상 graceful degradation (stdout 0 + exit 0).

---

### Codex CLI 설정

**파일들**:
- `~/.codex/skills-toon-catalog.toon` — 62개 스킬 정적 카탈로그 (51KB)
- `~/.codex/hooks/toon-skill-inject.py` — notify 훅 (키워드 감지 → 사이드카 파일 작성)
- `~/.codex/hooks/notify-dispatch.py` — 멀티 훅 디스패처
- `~/.codex/toon-dev-instructions-addition.txt` — `developer_instructions` 추가 텍스트

**제약 및 해결책**:

| 제약 | 해결책 |
|------|-------|
| `developer_instructions`는 플랫 문자열 (테이블 형식 금지) | 정적 카탈로그 파일 경로만 참조 |
| `notify` 명령 단일 진입점만 허용 | `notify-dispatch.py`가 jeo-notify + toon-skill-inject + omx 체인 |
| 프롬프트 전 훅(pre-prompt hook) 없음 | **2-턴 패턴**: 턴 N에서 훅이 `/tmp/toon-active-skill.toon` 작성 → 턴 N+1에서 `developer_instructions` 지시에 따라 읽어 실행 |

**`~/.codex/config.toml` 변경 사항**:

```toml
# notify 교체 (단일 디스패처로):
notify = ["python3", "~/.codex/hooks/notify-dispatch.py"]

# developer_instructions 문자열 내부에 추가 (기존 내용 뒤에 append):
developer_instructions = """
...기존 내용...

## TOON Skill System

A skill catalog lives at: ~/.codex/skills-toon-catalog.toon
Regenerate it anytime with: python3 ~/.codex/hooks/setup-toon-catalog.py

### How to activate a skill
1. Detect a trigger keyword in the user message (matches N: or G: tag in catalog).
2. Read the matching TOON block from the catalog file shown above.
3. Execute exactly as the TOON block instructs: follow S[] steps, respect R[] rules.
4. Never summarize or paraphrase the skill — execute it.

### At each turn start:
Check if /tmp/toon-active-skill.toon exists.
If it does, read it and execute the skill block before anything else.
"""
```

> **중요**: `developer_instructions = """..."""` 형식을 반드시 유지하세요. `[developer_instructions]` 테이블 형식으로 작성하면 Codex가 `invalid type: map, expected a string` 오류로 시작 실패합니다.

**카탈로그 재생성**:

```bash
python3 ~/.codex/hooks/setup-toon-catalog.py
```

`~/.claude/skills/*/SKILL.toon`과 `~/.codex/skills/*/SKILL.toon`을 모두 스캔합니다. 스킬 이름 충돌 시 Codex 로컬 버전이 우선합니다.

---

### Gemini CLI 설정

**파일들**:
- `~/.gemini/hooks/toon-skill-inject.sh` — AfterAgent 훅 (카탈로그 갱신)
- `~/.gemini/toon-catalog.md` — 자동 생성 카탈로그 (60개 스킬, 1286줄)

**핵심 제약**: Gemini CLI v0.30.0에는 `BeforeAgent` 훅이 없습니다. 대신 `includeDirectories`를 사용하여 세션 시작 시 `toon-catalog.md`를 자동 로드합니다. `stop_hook_active`는 항상 false인 버그가 있으므로 `.omc/state/ralph-state.json`을 직접 확인하세요.

**`~/.gemini/settings.json` 변경 사항**:

```json
{
  "hooks": {
    "AfterAgent": [
      {
        "name": "toon-skill-inject",
        "type": "command",
        "command": "bash ~/.gemini/hooks/toon-skill-inject.sh",
        "description": "매 에이전트 턴 후 TOON 스킬 카탈로그 갱신"
      },
      {
        "name": "plannotator-review",
        "type": "command",
        "command": "bash ~/.gemini/hooks/jeo-plannotator.sh",
        "description": "plan.md 감지 시 plannotator 실행"
      }
    ]
  },
  "context": {
    "includeDirectories": ["/Users/supercent/.gemini"]
  }
}
```

> `includeDirectories`에 `~/.gemini/`를 지정하면 `toon-catalog.md`와 `GEMINI.md`가 세션 시작 시 자동으로 컨텍스트에 로드됩니다. 이것이 Gemini에서의 사전 주입(pre-injection) 메커니즘입니다.

**`GEMINI.md`에 추가할 섹션** (수동 추가):

```markdown
## TOON Skill Catalog

A skill catalog is available at: ~/.gemini/toon-catalog.md
When a user references a skill by name or keyword:
1. Identify the skill name from the catalog's N: field
2. Announce: "Using skill: <name>"
3. Load and follow the full SKILL.md at ~/.claude/skills/<name>/SKILL.md
4. Execute exactly — never summarize the skill instructions
```

**카탈로그 수동 갱신**:

```bash
bash ~/.gemini/hooks/toon-skill-inject.sh
```

약 0.1초 소요. `~/.claude/skills/*/SKILL.toon`을 스캔하고 SKILL.md YAML 프론트매터로 폴백합니다.

---

### 플랫폼별 TOON 통합 상태

| 플랫폼 | 주입 메커니즘 | 카탈로그 소스 | 온디맨드 로딩 |
|--------|-------------|-------------|-------------|
| **Claude Code** | `UserPromptSubmit` 훅 (`toon-inject.mjs`) | 런타임 동적 생성 | Tier 2 자동 (키워드 매칭) |
| **Codex CLI** | `notify` 훅 + `developer_instructions` | 정적 파일 (`skills-toon-catalog.toon`) | 2-턴 패턴 (사이드카 파일) |
| **Gemini CLI** | `includeDirectories` + `AfterAgent` 훅 | 정적 파일 (`toon-catalog.md`) | `GEMINI.md` 지시로 수동 로딩 |

### 주요 설계 원칙

1. **심링크 인식**: `~/.claude/skills/`는 심링크 구조. Python `rglob()`은 실패하므로 Node.js 또는 실제 경로(`~/.agents/skills/`)를 사용합니다.
2. **안전한 폴백**: 훅 오류 시 항상 원본 프롬프트를 그대로 통과시킵니다 (`exit 0`). 절대 프롬프트를 차단하지 않습니다.
3. **토큰 상한**: 온디맨드 스킬은 최대 3개로 제한합니다. 전체 71개 주입은 금지합니다.
4. **정적 카탈로그 재생성**: SKILL.toon 파일 변경 후 각 플랫폼 카탈로그를 수동 재생성합니다.

### Quick Reference

| 작업 | 명령 |
|------|------|
| Claude Code 훅 확인 | `cat ~/.claude/hooks/toon-inject.mjs` |
| Codex 카탈로그 재생성 | `python3 ~/.codex/hooks/setup-toon-catalog.py` |
| Gemini 카탈로그 재생성 | `bash ~/.gemini/hooks/toon-skill-inject.sh` |
| Claude Code 훅 디버그 | `TOON_VERBOSE=1 node ~/.claude/hooks/toon-inject.mjs` |
| 전체 스킬 목록 확인 | `cat ~/.claude/skills/*/SKILL.toon \| grep "^N:"` |