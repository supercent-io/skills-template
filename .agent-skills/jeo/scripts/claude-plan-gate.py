#!/usr/bin/env python3
"""JEO Claude plan gate wrapper.

Wraps the Claude Code ExitPlanMode hook so JEO can skip redundant plannotator
launches when the current plan content has already been reviewed.

On approval (plannotator exit code 0), ralphmode is automatically activated:
- jeo-state.json: ralphmode_active=true, plan_gate_status="approved"
- project .claude/settings.json: permissionMode="acceptEdits"
This allows the EXECUTE phase (/omc:team) to run with minimal approval prompts.
Ralphmode is deactivated at CLEANUP (worktree-cleanup.sh resets permissionMode).
"""

from __future__ import annotations

import datetime
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any


SKIP_STATUSES = {"approved", "manual_approved", "feedback_required", "infrastructure_blocked"}
RALPHMODE_PERMISSION = "acceptEdits"


def git_root() -> Path:
    try:
        return Path(
            subprocess.check_output(
                ["git", "rev-parse", "--show-toplevel"],
                stderr=subprocess.DEVNULL,
                text=True,
            ).strip()
        )
    except Exception:
        return Path.cwd()


def state_path(root: Path) -> Path:
    return root / ".omc" / "state" / "jeo-state.json"


def load_state(root: Path) -> dict[str, Any]:
    path = state_path(root)
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def save_state(root: Path, state: dict[str, Any]) -> None:
    path = state_path(root)
    if not path.parent.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(state, ensure_ascii=False, indent=2), encoding="utf-8")


def find_plan_text(root: Path, payload: str) -> str:
    for candidate in (
        root / ".omc" / "plans" / "jeo-plan.md",
        root / "plan.md",
        root / "docs" / "plan.md",
    ):
        if candidate.exists():
            try:
                return candidate.read_text(encoding="utf-8")
            except Exception:
                continue

    try:
        data = json.loads(payload)
    except Exception:
        return ""

    tool_input = data.get("tool_input", {})
    if isinstance(tool_input, dict):
        plan = tool_input.get("plan")
        if isinstance(plan, str):
            return plan
    return ""


def plan_hash(plan_text: str) -> str:
    if not plan_text:
        return ""
    return hashlib.sha256(plan_text.encode("utf-8")).hexdigest()


def should_skip(state: dict[str, Any], current_hash: str) -> bool:
    if state.get("phase") != "plan":
        return False

    gate_status = state.get("plan_gate_status")
    last_hash = state.get("last_reviewed_plan_hash")
    return bool(current_hash and gate_status in SKIP_STATUSES and last_hash == current_hash)


def reset_for_revised_plan(root: Path, state: dict[str, Any], current_hash: str) -> None:
    last_hash = state.get("last_reviewed_plan_hash")
    if not current_hash or current_hash == last_hash:
        return

    if state.get("plan_gate_status") in SKIP_STATUSES:
        state["plan_gate_status"] = "pending"
        state["plan_approved"] = False
        state["plan_current_hash"] = current_hash
        state["updated_at"] = datetime.datetime.utcnow().isoformat() + "Z"
        try:
            save_state(root, state)
        except Exception as exc:
            print(f"[JEO] ⚠️  Failed to reset plan state: {exc}", file=sys.stderr)


def run_plannotator(payload: str, plan_text: str = "") -> int:
    """Run plannotator with the hook payload, injecting plan_text if tool_input.plan is missing.

    plannotator expects {"tool_input": {"plan": "...", "permission_mode": "..."}} on stdin.
    If the ExitPlanMode hook payload does not include tool_input.plan (e.g. Claude Code does
    not embed it), we inject the plan text found by find_plan_text() so plannotator can
    render the plan UI correctly.  Without this injection the browser page has no content
    and clicking "Approve" causes a page error.
    """
    try:
        data = json.loads(payload)
    except Exception:
        data = {}

    if plan_text:
        tool_input = data.get("tool_input")
        if not isinstance(tool_input, dict):
            data["tool_input"] = {"plan": plan_text, "permission_mode": "acceptEdits"}
        else:
            if not tool_input.get("plan"):
                tool_input["plan"] = plan_text
            if not tool_input.get("permission_mode"):
                tool_input["permission_mode"] = "acceptEdits"

    enriched_payload = json.dumps(data)
    proc = subprocess.run(["plannotator"], input=enriched_payload, text=True)
    return proc.returncode


def activate_ralphmode(root: Path, state: dict[str, Any], current_hash: str = "") -> None:
    """Activate ralphmode after plan approval.

    - Sets ralphmode_active=true in jeo-state.json
    - Records last_reviewed_plan_hash so should_skip() can skip re-reviews of the same plan
    - Writes permissionMode=acceptEdits to project .claude/settings.json
      so the EXECUTE phase (/omc:team) runs with minimal approval prompts.
    """
    now = datetime.datetime.utcnow().isoformat() + "Z"
    state["plan_approved"] = True
    state["plan_gate_status"] = "approved"
    state["ralphmode_active"] = True
    state["ralphmode_activated_at"] = now
    state["updated_at"] = now
    if current_hash:
        state["last_reviewed_plan_hash"] = current_hash
        state["last_reviewed_plan_at"] = now
        state["plan_review_method"] = "plannotator"
    try:
        save_state(root, state)
    except Exception as exc:
        print(f"[JEO] ⚠️  Failed to save jeo-state.json: {exc}", file=sys.stderr)

    # Write project-local .claude/settings.json with acceptEdits
    project_settings_path = root / ".claude" / "settings.json"
    try:
        project_settings_path.parent.mkdir(parents=True, exist_ok=True)
        ps: dict[str, Any] = {}
        if project_settings_path.exists():
            try:
                ps = json.loads(project_settings_path.read_text(encoding="utf-8"))
            except Exception:
                ps = {}
        previous = ps.get("permissionMode", "default")
        ps["permissionMode"] = RALPHMODE_PERMISSION
        ps["_ralphmode_previous_permission"] = previous
        project_settings_path.write_text(json.dumps(ps, ensure_ascii=False, indent=2), encoding="utf-8")
        print(
            f"[JEO] ✅ Plan approved → ralphmode activated"
            f" (permissionMode: {previous!r} → {RALPHMODE_PERMISSION!r})."
            f" EXECUTE phase ready.",
            file=sys.stderr,
        )
    except Exception as exc:
        print(f"[JEO] ⚠️  ralphmode profile write failed: {exc}", file=sys.stderr)


def deactivate_ralphmode(root: Path) -> None:
    """Revert permissionMode to the previous value saved before ralphmode activation.

    Called by worktree-cleanup.sh (or manually) at CLEANUP phase.
    """
    project_settings_path = root / ".claude" / "settings.json"
    if not project_settings_path.exists():
        return
    try:
        ps = json.loads(project_settings_path.read_text(encoding="utf-8"))
        if ps.get("permissionMode") != RALPHMODE_PERMISSION:
            return  # Already reverted or never set
        previous = ps.pop("_ralphmode_previous_permission", "default")
        if previous == "default":
            ps.pop("permissionMode", None)
        else:
            ps["permissionMode"] = previous
        project_settings_path.write_text(json.dumps(ps, ensure_ascii=False, indent=2), encoding="utf-8")

        # Update jeo-state.json
        state = load_state(root)
        if state:
            state["ralphmode_active"] = False
            state["updated_at"] = datetime.datetime.utcnow().isoformat() + "Z"
            save_state(root, state)

        print(f"[JEO] ralphmode deactivated (permissionMode restored to {previous!r}).", file=sys.stderr)
    except Exception as exc:
        print(f"[JEO] ⚠️  ralphmode deactivation failed: {exc}", file=sys.stderr)


def main() -> int:
    # Support --deactivate flag for use in CLEANUP (worktree-cleanup.sh)
    if "--deactivate" in sys.argv:
        deactivate_ralphmode(git_root())
        return 0

    payload = sys.stdin.read()
    root = git_root()
    state = load_state(root)
    plan_text = find_plan_text(root, payload)
    current_hash = plan_hash(plan_text)

    if should_skip(state, current_hash):
        status = state.get("plan_gate_status", "unknown")
        print(
            f"[JEO][PLAN] Claude hook skipped: plan gate already recorded for current hash ({status}).",
            file=sys.stderr,
        )
        return 0

    reset_for_revised_plan(root, state, current_hash)
    rc = run_plannotator(payload, plan_text)

    if rc == 0:
        # Plan approved — activate ralphmode for the EXECUTE phase
        activate_ralphmode(root, load_state(root), current_hash)

    return rc


if __name__ == "__main__":
    raise SystemExit(main())
