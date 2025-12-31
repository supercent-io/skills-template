#!/usr/bin/env python3
"""
Agent Skills Loader

A utility for loading and managing Agent Skills across different AI platforms.
Supports Claude, ChatGPT, Gemini, and other AI agents.
"""

import os
import sys
import yaml
import argparse
from pathlib import Path
from typing import Dict, List, Optional


class SkillLoader:
    """Load and manage Agent Skills."""
    
    def __init__(self, skills_dir: str = '.agent-skills'):
        """
        Initialize the skill loader.
        
        Args:
            skills_dir: Path to the agent skills directory
        """
        self.skills_dir = Path(skills_dir)
        self.skills: Dict[str, Dict] = {}
        
        if not self.skills_dir.exists():
            raise FileNotFoundError(f"Skills directory not found: {skills_dir}")
        
        self.load_all_skills()
    
    def load_all_skills(self) -> None:
        """Discover and load all skills from the skills directory."""
        for skill_md in self.skills_dir.rglob('SKILL.md'):
            try:
                skill = self.parse_skill(skill_md)
                if skill:
                    self.skills[skill['name']] = skill
            except Exception as e:
                print(f"Warning: Failed to parse {skill_md}: {e}", file=sys.stderr)
    
    def parse_skill(self, skill_path: Path) -> Optional[Dict]:
        """
        Parse a SKILL.md file.
        
        Args:
            skill_path: Path to SKILL.md file
            
        Returns:
            Dictionary containing skill metadata and content
        """
        try:
            with open(skill_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"Error reading {skill_path}: {e}", file=sys.stderr)
            return None
        
        # Extract YAML frontmatter
        if not content.startswith('---'):
            print(f"Warning: {skill_path} missing frontmatter", file=sys.stderr)
            return None
        
        parts = content.split('---', 2)
        if len(parts) < 3:
            print(f"Warning: {skill_path} invalid frontmatter format", file=sys.stderr)
            return None
        
        try:
            frontmatter = yaml.safe_load(parts[1])
        except yaml.YAMLError as e:
            print(f"Error parsing YAML in {skill_path}: {e}", file=sys.stderr)
            return None
        
        if not frontmatter or 'name' not in frontmatter or 'description' not in frontmatter:
            print(f"Warning: {skill_path} missing required fields (name, description)", 
                  file=sys.stderr)
            return None
        
        body = parts[2].strip()
        
        return {
            'name': frontmatter.get('name'),
            'description': frontmatter.get('description'),
            'allowed_tools': frontmatter.get('allowed-tools', []),
            'path': skill_path.parent,
            'body': body,
            'full_content': content
        }
    
    def get_skill(self, name: str) -> Optional[Dict]:
        """
        Get a specific skill by name.
        
        Args:
            name: Skill name
            
        Returns:
            Skill dictionary or None if not found
        """
        return self.skills.get(name)
    
    def list_skills(self) -> List[str]:
        """
        List all available skill names.
        
        Returns:
            List of skill names
        """
        return sorted(self.skills.keys())
    
    def search_skills(self, query: str) -> List[Dict]:
        """
        Search for skills matching a query.
        
        Args:
            query: Search query
            
        Returns:
            List of matching skills
        """
        results = []
        query_lower = query.lower()
        
        for skill in self.skills.values():
            if (query_lower in skill['name'].lower() or 
                query_lower in skill['description'].lower()):
                results.append(skill)
        
        return results
    
    def format_for_prompt(self, skill_names: Optional[List[str]] = None, 
                         format_type: str = 'markdown') -> str:
        """
        Format skills for AI prompt.
        
        Args:
            skill_names: List of skill names to include (None for all)
            format_type: Output format ('markdown', 'xml', 'json')
            
        Returns:
            Formatted string for AI prompt
        """
        if skill_names is None:
            skill_names = self.list_skills()
        
        if format_type == 'xml':
            return self._format_xml(skill_names)
        elif format_type == 'json':
            return self._format_json(skill_names)
        else:
            return self._format_markdown(skill_names)
    
    def _format_markdown(self, skill_names: List[str]) -> str:
        """Format skills as Markdown."""
        output = "# Available Skills\n\n"
        
        for name in skill_names:
            skill = self.skills.get(name)
            if not skill:
                continue
            
            output += f"## {skill['name']}\n\n"
            output += f"**Description**: {skill['description']}\n\n"
            
            if skill['allowed_tools']:
                output += f"**Allowed Tools**: {', '.join(skill['allowed_tools'])}\n\n"
            
            output += f"**Location**: `{skill['path']}`\n\n"
            output += "### Instructions\n\n"
            output += skill['body'] + "\n\n"
            output += "---\n\n"
        
        return output
    
    def _format_xml(self, skill_names: List[str]) -> str:
        """Format skills as XML (Claude-optimized)."""
        output = "<available_skills>\n"
        
        for name in skill_names:
            skill = self.skills.get(name)
            if not skill:
                continue
            
            output += "  <skill>\n"
            output += f"    <name>{skill['name']}</name>\n"
            output += f"    <description>{skill['description']}</description>\n"
            output += f"    <location>{skill['path']}/SKILL.md</location>\n"
            
            if skill['allowed_tools']:
                output += "    <allowed_tools>\n"
                for tool in skill['allowed_tools']:
                    output += f"      <tool>{tool}</tool>\n"
                output += "    </allowed_tools>\n"
            
            output += "  </skill>\n"
        
        output += "</available_skills>"
        return output
    
    def _format_json(self, skill_names: List[str]) -> str:
        """Format skills as JSON."""
        import json
        
        skills_data = []
        for name in skill_names:
            skill = self.skills.get(name)
            if not skill:
                continue
            
            skills_data.append({
                'name': skill['name'],
                'description': skill['description'],
                'allowed_tools': skill['allowed_tools'],
                'location': str(skill['path'])
            })
        
        return json.dumps({'skills': skills_data}, indent=2)
    
    def get_skill_content(self, name: str) -> Optional[str]:
        """
        Get the full content of a skill.
        
        Args:
            name: Skill name
            
        Returns:
            Full SKILL.md content or None
        """
        skill = self.get_skill(name)
        return skill['full_content'] if skill else None


def main():
    """Command-line interface for skill loader."""
    parser = argparse.ArgumentParser(
        description='Agent Skills Loader - Manage and use Agent Skills'
    )
    parser.add_argument(
        '--dir',
        default='.agent-skills',
        help='Path to skills directory (default: .agent-skills)'
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Command')
    
    # List command
    subparsers.add_parser('list', help='List all available skills')
    
    # Search command
    search_parser = subparsers.add_parser('search', help='Search for skills')
    search_parser.add_argument('query', help='Search query')
    
    # Show command
    show_parser = subparsers.add_parser('show', help='Show a specific skill')
    show_parser.add_argument('name', help='Skill name')
    
    # Prompt command
    prompt_parser = subparsers.add_parser('prompt', help='Generate AI prompt')
    prompt_parser.add_argument(
        '--skills',
        nargs='+',
        help='Skill names to include (default: all)'
    )
    prompt_parser.add_argument(
        '--format',
        choices=['markdown', 'xml', 'json'],
        default='markdown',
        help='Output format (default: markdown)'
    )
    prompt_parser.add_argument(
        '--output',
        help='Output file (default: stdout)'
    )
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    try:
        loader = SkillLoader(args.dir)
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    
    if args.command == 'list':
        print("Available Skills:")
        print("=" * 50)
        for name in loader.list_skills():
            skill = loader.get_skill(name)
            print(f"\n{name}")
            print(f"  {skill['description']}")
    
    elif args.command == 'search':
        results = loader.search_skills(args.query)
        if not results:
            print(f"No skills found matching '{args.query}'")
            return
        
        print(f"Skills matching '{args.query}':")
        print("=" * 50)
        for skill in results:
            print(f"\n{skill['name']}")
            print(f"  {skill['description']}")
    
    elif args.command == 'show':
        content = loader.get_skill_content(args.name)
        if not content:
            print(f"Error: Skill '{args.name}' not found", file=sys.stderr)
            sys.exit(1)
        print(content)
    
    elif args.command == 'prompt':
        output = loader.format_for_prompt(args.skills, args.format)
        
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(output)
            print(f"Prompt written to {args.output}")
        else:
            print(output)


if __name__ == '__main__':
    main()

