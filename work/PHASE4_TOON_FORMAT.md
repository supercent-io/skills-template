# Phase 4: TOON 포맷 구현

## Gemini-CLI 분석 결과

### TOON 포맷 구조
```
N:<skill_name> C:<category> D:<description> T:<tool1,tool2,...>
```

**키 정의**:
- `N`: Name (스킬명)
- `C`: Category (카테고리)
- `D`: Description (설명)
- `T`: Tools (허용 도구)

### 토큰 절감 효과
- JSON: ~100 characters per skill
- TOON: ~57 characters per skill
- **절감률: 약 43%**

### 예시 비교

**JSON (Before)**:
```json
{
  "name": "api-design",
  "category": "backend",
  "description": "Design RESTful APIs",
  "allowed_tools": ["Read", "Write"]
}
```

**TOON (After)**:
```
N:api-design C:backend D:Design RESTful APIs T:Read,Write
```

---

## TOON 변환기 구현 계획

### 1. toon_converter.py 구조
```python
class TOONConverter:
    def encode(self, data: dict) -> str:
        """JSON → TOON 변환"""
        pass

    def decode(self, toon_str: str) -> dict:
        """TOON → JSON 변환"""
        pass

    def convert_skill(self, skill_md: str) -> str:
        """SKILL.md → SKILL.toon 변환"""
        pass

    def get_token_stats(self, original: str, converted: str) -> dict:
        """토큰 절감 통계"""
        pass
```

### 2. CLI 인터페이스
```bash
# JSON → TOON
python toon_converter.py encode skills.json -o skills.toon

# TOON → JSON
python toon_converter.py decode skills.toon -o skills.json

# 스킬 파일 변환
python toon_converter.py convert-skill backend/api-design/SKILL.md

# 전체 스킬 일괄 변환
python toon_converter.py convert-all --format toon
```

### 3. SKILL.toon 포맷
```toon
# Skill Manifest (TOON Format)
# Generated: 2025-01-05
# Skills: 30

skills[30]{name,category,description,tools}
api-design,backend,"Design RESTful APIs",Read|Write
code-review,code-quality,"Conduct code reviews",Read|Grep|Glob
database-schema-design,backend,"Design database schemas",Read|Write
authentication-setup,backend,"Setup auth systems",Read|Write|Bash
...
```

---

## 구현 순서

1. [ ] `scripts/toon_converter.py` 생성
2. [ ] JSON ↔ TOON 변환 함수 구현
3. [ ] SKILL.md 파싱 및 변환
4. [ ] CLI 인터페이스 추가
5. [ ] 토큰 절감 통계 기능
6. [ ] skill_loader.py에 TOON 지원 추가
7. [ ] 전체 스킬 TOON 변환

---

**상태**: 대기 중
**담당**: Claude Code (구현) + Codex-CLI (테스트)
