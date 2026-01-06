#!/usr/bin/env python3
"""
Skill Query Handler for MCP Integration (gemini-cli, codex-cli)

This script matches user queries to appropriate skills and executes them
using gemini-cli or codex-cli MCP tools.

Usage:
    python skill-query-handler.py query "Design a REST API for users"
    python skill-query-handler.py query "Review this code" --tool gemini
    python skill-query-handler.py list
    python skill-query-handler.py match "database schema"
"""

import os
import sys
import json
import subprocess
import argparse
from pathlib import Path
from typing import Optional, List, Dict, Tuple

# Skill keywords mapping for automatic matching
SKILL_KEYWORDS = {
    "backend/api-design": [
        "api", "rest", "restful", "endpoint", "openapi", "swagger",
        "api design", "api 설계", "엔드포인트", "rest api"
    ],
    "backend/database-schema-design": [
        "database", "schema", "db", "table", "sql", "postgresql", "mysql",
        "데이터베이스", "스키마", "테이블", "db 설계"
    ],
    "backend/authentication-setup": [
        "auth", "authentication", "login", "jwt", "oauth", "session",
        "인증", "로그인", "세션"
    ],
    "backend/backend-testing": [
        "backend test", "unit test", "integration test", "pytest",
        "백엔드 테스트", "단위 테스트"
    ],
    "frontend/react-components": [
        "react", "component", "컴포넌트", "리액트"
    ],
    "frontend/ui-component-patterns": [
        "ui", "component pattern", "design pattern", "ui 패턴"
    ],
    "frontend/state-management": [
        "state", "redux", "zustand", "context", "상태 관리", "상태"
    ],
    "frontend/responsive-design": [
        "responsive", "mobile", "반응형", "모바일"
    ],
    "frontend/web-accessibility": [
        "accessibility", "a11y", "wcag", "접근성"
    ],
    "code-quality/code-review": [
        "review", "code review", "리뷰", "코드 리뷰", "코드리뷰"
    ],
    "code-quality/code-refactoring": [
        "refactor", "리팩토링", "리팩터링", "개선"
    ],
    "code-quality/debugging": [
        "debug", "error", "bug", "exception", "traceback",
        "디버그", "디버깅", "에러", "버그", "오류"
    ],
    "code-quality/testing-strategies": [
        "test strategy", "testing", "tdd", "테스트 전략", "테스팅"
    ],
    "code-quality/performance-optimization": [
        "performance", "optimize", "slow", "memory", "성능", "최적화", "느림"
    ],
    "infrastructure/docker-containerization": [
        "docker", "container", "dockerfile", "도커", "컨테이너"
    ],
    "infrastructure/deployment-automation": [
        "deploy", "ci/cd", "pipeline", "배포", "파이프라인"
    ],
    "infrastructure/monitoring-observability": [
        "monitor", "log", "metric", "alert", "모니터링", "로그"
    ],
    "infrastructure/security-best-practices": [
        "security", "vulnerability", "xss", "sql injection", "csrf",
        "보안", "취약점", "인젝션"
    ],
    "documentation/technical-writing": [
        "document", "documentation", "technical doc", "문서", "기술 문서"
    ],
    "documentation/api-documentation": [
        "api doc", "api documentation", "api 문서"
    ],
    "documentation/changelog-maintenance": [
        "changelog", "release note", "변경 로그", "릴리즈 노트"
    ],
    "project-management/task-estimation": [
        "estimate", "estimation", "story point", "추정", "스토리 포인트"
    ],
    "project-management/task-planning": [
        "plan", "planning", "task", "계획", "태스크"
    ],
    "project-management/sprint-retrospective": [
        "retrospective", "retro", "sprint", "회고"
    ],
    "search-analysis/log-analysis": [
        "log analysis", "log", "로그 분석"
    ],
    "search-analysis/data-analysis": [
        "data analysis", "analyze data", "데이터 분석"
    ],
    "search-analysis/pattern-detection": [
        "pattern", "detect", "패턴"
    ],
    "utilities/git-workflow": [
        "git", "commit", "branch", "merge", "깃", "커밋", "브랜치"
    ],
    "utilities/skill-standardization": [
        "skill", "standardize", "convert skill", "스킬 변환"
    ],
}


class SkillQueryHandler:
    def __init__(self, skills_dir: Optional[str] = None):
        if skills_dir:
            self.skills_dir = Path(skills_dir)
        else:
            self.skills_dir = Path(__file__).parent

    def find_skill(self, skill_path: str) -> Optional[Path]:
        """Find a skill by path."""
        full_path = self.skills_dir / skill_path / "SKILL.md"
        if full_path.exists():
            return full_path
        return None

    def load_skill(self, skill_path: str) -> Optional[str]:
        """Load skill content."""
        skill_file = self.find_skill(skill_path)
        if skill_file:
            return skill_file.read_text(encoding='utf-8')
        return None

    def match_query_to_skills(self, query: str) -> List[Tuple[str, int]]:
        """Match a query to skills based on keywords. Returns list of (skill_path, score)."""
        query_lower = query.lower()
        matches = []

        for skill_path, keywords in SKILL_KEYWORDS.items():
            score = 0
            for keyword in keywords:
                if keyword.lower() in query_lower:
                    # Longer keywords get higher scores
                    score += len(keyword.split())

            if score > 0:
                matches.append((skill_path, score))

        # Sort by score descending
        matches.sort(key=lambda x: x[1], reverse=True)
        return matches

    def get_best_skill(self, query: str) -> Optional[str]:
        """Get the best matching skill for a query."""
        matches = self.match_query_to_skills(query)
        if matches:
            return matches[0][0]
        return None

    def list_all_skills(self) -> List[Dict]:
        """List all available skills."""
        skills = []
        for skill_path in SKILL_KEYWORDS.keys():
            skill_file = self.find_skill(skill_path)
            if skill_file:
                # Extract description from frontmatter
                content = skill_file.read_text(encoding='utf-8')
                description = self._extract_description(content)
                skills.append({
                    "path": skill_path,
                    "description": description,
                    "keywords": SKILL_KEYWORDS[skill_path][:3]
                })
        return skills

    def _extract_description(self, content: str) -> str:
        """Extract description from SKILL.md frontmatter."""
        lines = content.split('\n')
        in_frontmatter = False
        for line in lines:
            if line.strip() == '---':
                in_frontmatter = not in_frontmatter
                continue
            if in_frontmatter and line.startswith('description:'):
                return line.replace('description:', '').strip()
        return ""

    def execute_with_gemini(self, skill_path: str, query: str) -> str:
        """Execute query with gemini-cli using the skill context."""
        skill_content = self.load_skill(skill_path)
        if not skill_content:
            return f"Error: Skill not found: {skill_path}"

        skill_file = self.find_skill(skill_path)
        prompt = f"@{skill_file}\n\n{query}"

        return prompt

    def generate_prompt(self, query: str, tool: str = "gemini") -> str:
        """Generate a prompt for the given query with matched skill."""
        best_skill = self.get_best_skill(query)

        if not best_skill:
            return f"No matching skill found for: {query}"

        skill_file = self.find_skill(best_skill)

        if tool == "gemini":
            return f"@{skill_file}\n\n{query}"
        elif tool == "codex":
            skill_content = self.load_skill(best_skill)
            return f"{skill_content}\n\n---\n\n{query}"
        else:
            return f"Unknown tool: {tool}"


def main():
    parser = argparse.ArgumentParser(
        description="Skill Query Handler for MCP Integration",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python skill-query-handler.py query "Design a REST API for user management"
  python skill-query-handler.py query "이 코드를 리뷰해줘" --tool gemini
  python skill-query-handler.py list
  python skill-query-handler.py match "database schema design"
  python skill-query-handler.py prompt "디버깅 도와줘" --skill code-quality/debugging
        """
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # query command
    query_parser = subparsers.add_parser("query", help="Generate prompt for a query")
    query_parser.add_argument("text", help="User query text")
    query_parser.add_argument("--tool", choices=["gemini", "codex"], default="gemini",
                             help="MCP tool to use (default: gemini)")
    query_parser.add_argument("--skill", help="Force specific skill path")

    # list command
    list_parser = subparsers.add_parser("list", help="List all available skills")
    list_parser.add_argument("--json", action="store_true", help="Output as JSON")

    # match command
    match_parser = subparsers.add_parser("match", help="Find matching skills for a query")
    match_parser.add_argument("text", help="Query text to match")

    # prompt command
    prompt_parser = subparsers.add_parser("prompt", help="Generate prompt with specific skill")
    prompt_parser.add_argument("text", help="User query text")
    prompt_parser.add_argument("--skill", required=True, help="Skill path to use")
    prompt_parser.add_argument("--tool", choices=["gemini", "codex"], default="gemini")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    handler = SkillQueryHandler()

    if args.command == "query":
        if args.skill:
            skill_path = args.skill
        else:
            skill_path = handler.get_best_skill(args.text)

        if not skill_path:
            print(f"No matching skill found for: {args.text}", file=sys.stderr)
            print("\nAvailable skills:")
            for skill in handler.list_all_skills():
                print(f"  - {skill['path']}: {skill['description'][:50]}...")
            sys.exit(1)

        prompt = handler.generate_prompt(args.text, args.tool)
        print(prompt)

    elif args.command == "list":
        skills = handler.list_all_skills()
        if args.json:
            print(json.dumps(skills, indent=2, ensure_ascii=False))
        else:
            print("Available Skills:")
            print("=" * 60)
            for skill in skills:
                print(f"\n{skill['path']}")
                print(f"  Description: {skill['description'][:60]}...")
                print(f"  Keywords: {', '.join(skill['keywords'])}")

    elif args.command == "match":
        matches = handler.match_query_to_skills(args.text)
        if matches:
            print(f"Matching skills for: '{args.text}'")
            print("-" * 40)
            for skill_path, score in matches[:5]:
                print(f"  [{score}] {skill_path}")
        else:
            print(f"No matching skills found for: {args.text}")

    elif args.command == "prompt":
        skill_file = handler.find_skill(args.skill)
        if not skill_file:
            print(f"Skill not found: {args.skill}", file=sys.stderr)
            sys.exit(1)

        if args.tool == "gemini":
            print(f"@{skill_file}\n\n{args.text}")
        else:
            skill_content = handler.load_skill(args.skill)
            print(f"{skill_content}\n\n---\n\n{args.text}")


if __name__ == "__main__":
    main()
