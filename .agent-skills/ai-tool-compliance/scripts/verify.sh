#!/bin/bash
# AI Tool Compliance - P0 룰 검증 (catalog.json 기반)
# Usage: bash scripts/verify.sh [BASE_DIR] [--output FILE] [--help]
#
# catalog.json은 install.sh 실행 시 p0-catalog.yaml로부터 자동 생성됨.
#
# Output (stdout): JSON with results array + summary
# Diagnostics (stderr): progress messages
# Exit: 0=all pass, 1=p1 warnings, 2=p0 fail found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATALOG_JSON="$SCRIPT_DIR/../rules/catalog.json"
BASE_DIR="."
OUTPUT_FILE="/tmp/compliance-verify.json"

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --output) OUTPUT_FILE="$2"; shift 2 ;;
    --target) BASE_DIR="$2"; shift 2 ;;
    --help|-h)
      cat << 'EOF'
Usage: bash scripts/verify.sh [BASE_DIR] [--output FILE] [--target DIR] [--help]

  BASE_DIR    Project root to scan (default: current directory)
  --output    Write JSON results to FILE (default: /tmp/compliance-verify.json)
  --target    Alias for BASE_DIR
  --help      Show this help

Output (stdout): JSON with rule results and summary
Diagnostics (stderr): progress messages

Exit codes:
  0  All rules PASS or MANUAL_REVIEW (no P0 fails)
  1  P1 warnings only
  2  One or more P0 FAIL found

Example:
  bash scripts/verify.sh .
  bash scripts/verify.sh /path/to/project --output /tmp/results.json
EOF
      exit 0
      ;;
    *) BASE_DIR="$1"; shift ;;
  esac
done

# Validate catalog exists
if [ ! -f "$CATALOG_JSON" ]; then
  echo "[verify] ERROR: catalog.json not found: $CATALOG_JSON" >&2
  echo "[verify] Run: bash scripts/install.sh  to compile p0-catalog.yaml → catalog.json" >&2
  exit 2
fi

echo "[verify] Starting P0 compliance scan: $BASE_DIR" >&2
echo "[verify] Catalog: $CATALOG_JSON" >&2

# Run verification via Python3 (stdlib only, no external deps)
python3 - "$BASE_DIR" "$CATALOG_JSON" "$OUTPUT_FILE" << 'PYTHON'
import json, subprocess, sys, os, datetime

base_dir = sys.argv[1]
catalog_path = sys.argv[2]
output_file = sys.argv[3]

with open(catalog_path) as f:
    catalog = json.load(f)

results = []

for rule in catalog.get("rules", []):
    rule_id = rule["id"]
    severity = rule.get("severity", "P0")
    domain = rule.get("domain", "unknown")
    tier = rule.get("tier", 3)
    check_type = rule.get("check_type", "static_analysis")
    grep_patterns = rule.get("grep_patterns", [])
    must_not = rule.get("must_not_contain", [])
    must_have = rule.get("must_contain", [])
    score_impact = rule.get("score_impact", 0)

    print(f"[verify] Checking {rule_id} (tier={tier}, check_type={check_type})", file=sys.stderr)

    def run_grep(pat, extra_args=None):
        """Run grep, return list of matching lines (file:line:content)"""
        cmd = ["grep", "-rn", "--include=*.ts", "--include=*.js",
               "--include=*.tsx", "--include=*.jsx", "--include=*.py",
               "--exclude-dir=node_modules", "--exclude-dir=.git",
               "--exclude-dir=dist", "--exclude-dir=build",
               "-E", pat, base_dir]
        if extra_args:
            cmd[1:1] = extra_args
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode == 0 and r.stdout.strip():
            lines = r.stdout.strip().split("\n")
            return [l for l in lines if l.strip()]
        return []

    # Tier 3 / code_review / log_check:
    # grep presence check: absent=FAIL, present=MANUAL_REVIEW
    if tier == 3 or check_type in ("code_review", "api_test", "log_check"):
        # Use must_have or grep_patterns to detect related code
        detect_patterns = must_have or grep_patterns
        evidence = []
        for pat in detect_patterns[:3]:  # limit to first 3 patterns
            hits = run_grep(pat)
            evidence.extend(hits[:3])

        if evidence:
            status = "MANUAL_REVIEW"
            note = "Related code found — manual verification required"
        else:
            status = "FAIL"
            note = "No related code patterns found — rule likely not implemented"

        results.append({
            "rule_id": rule_id,
            "domain": domain,
            "severity": severity,
            "tier": tier,
            "check_type": check_type,
            "status": status,
            "score_impact": score_impact,
            "note": note,
            "evidence": evidence[:5]
        })
        continue

    # Tier 1/2: static_analysis — check must_not_contain and must_contain
    violations = []

    # must_not_contain: forbidden patterns → FAIL if found
    for pat in must_not:
        hits = run_grep(pat)
        if hits:
            violations.extend(hits[:5])

    if violations:
        status = "FAIL"
        results.append({
            "rule_id": rule_id,
            "domain": domain,
            "severity": severity,
            "tier": tier,
            "check_type": check_type,
            "status": status,
            "score_impact": score_impact,
            "violations": violations[:10]
        })
        continue

    # must_contain: required patterns → FAIL if none found
    if must_have:
        # First check if relevant code exists via grep_patterns
        relevant_code = []
        for pat in grep_patterns[:2]:
            hits = run_grep(pat)
            relevant_code.extend(hits[:3])

        if not relevant_code and grep_patterns:
            # Feature not used → N/A
            results.append({
                "rule_id": rule_id,
                "domain": domain,
                "severity": severity,
                "tier": tier,
                "check_type": check_type,
                "status": "NA",
                "score_impact": score_impact,
                "note": "Feature not detected in codebase"
            })
            continue

        # Check must_contain patterns
        missing = []
        found_evidence = []
        for pat in must_have:
            hits = run_grep(pat)
            if hits:
                found_evidence.extend(hits[:2])
            else:
                missing.append(pat)

        if missing:
            status = "FAIL"
            results.append({
                "rule_id": rule_id,
                "domain": domain,
                "severity": severity,
                "tier": tier,
                "check_type": check_type,
                "status": status,
                "score_impact": score_impact,
                "missing_patterns": missing,
                "violations": [f"Pattern not found: {p}" for p in missing]
            })
        else:
            results.append({
                "rule_id": rule_id,
                "domain": domain,
                "severity": severity,
                "tier": tier,
                "check_type": check_type,
                "status": "PASS",
                "score_impact": score_impact,
                "evidence": found_evidence[:5]
            })
        continue

    # Only must_not_contain checked and none found
    results.append({
        "rule_id": rule_id,
        "domain": domain,
        "severity": severity,
        "tier": tier,
        "check_type": check_type,
        "status": "PASS",
        "score_impact": score_impact,
        "evidence": []
    })

# Summary
p0_fails = [r for r in results if r["severity"] == "P0" and r["status"] == "FAIL"]
p1_fails = [r for r in results if r["severity"] == "P1" and r["status"] == "FAIL"]
manual_review = [r for r in results if r["status"] == "MANUAL_REVIEW"]
na_rules = [r for r in results if r["status"] == "NA"]

output = {
    "timestamp": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    "base_dir": base_dir,
    "results": results,
    "summary": {
        "p0_fail_count": len(p0_fails),
        "p1_fail_count": len(p1_fails),
        "manual_review_count": len(manual_review),
        "na_count": len(na_rules),
        "total_rules": len(results)
    }
}

with open(output_file, "w") as f:
    json.dump(output, f, indent=2, ensure_ascii=False)

print(json.dumps(output, indent=2, ensure_ascii=False))

print(f"\n[verify] Done: {len(results)} rules checked", file=sys.stderr)
print(f"  P0 FAIL: {len(p0_fails)} | MANUAL_REVIEW: {len(manual_review)} | N/A: {len(na_rules)}", file=sys.stderr)

sys.exit(2 if p0_fails else (1 if p1_fails else 0))
PYTHON
