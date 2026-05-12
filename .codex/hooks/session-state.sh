#!/usr/bin/env bash
# .codex/hooks/session-state.sh — State capture before long operations
#
# Replaces Claude Code's pre-compact.py hook.
# Call manually before starting a long multi-step task or before stopping:
#   bash .codex/hooks/session-state.sh
#
# Writes a JSON snapshot of the current session state to:
#   .codex/state/session.json
# This snapshot is read by session-init.sh on next session start.

set -uo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.codex/state/session.json"

mkdir -p "$(dirname "$STATE_FILE")"

PLANS_DIR="$PROJECT_ROOT/quality_reports/plans"
LOGS_DIR="$PROJECT_ROOT/quality_reports/session_logs"

PLAN_PATH=""
PLAN_STATUS=""
NEXT_TASK=""
LOG_PATH=""
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Find active plan
if [[ -d "$PLANS_DIR" ]]; then
    while IFS= read -r -d '' plan_file; do
        content="$(cat "$plan_file")"
        if echo "$content" | grep -qi "COMPLETED"; then
            continue
        fi
        PLAN_PATH="$plan_file"
        if echo "$content" | grep -qi "APPROVED"; then
            PLAN_STATUS="approved"
        elif echo "$content" | grep -qi "DRAFT"; then
            PLAN_STATUS="draft"
        else
            PLAN_STATUS="in_progress"
        fi
        NEXT_TASK="$(echo "$content" | grep -m1 '- \[ \]' | sed 's/- \[ \] *//' | cut -c1-120 || true)"
        break
    done < <(find "$PLANS_DIR" -name "*.md" -print0 2>/dev/null | sort -z -r)
fi

# Find latest session log
if [[ -d "$LOGS_DIR" ]]; then
    LOG_PATH="$(find "$LOGS_DIR" -name "*.md" -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1 || true)"
fi

# Write JSON snapshot using Python for reliable quoting
python3 - <<PYEOF
import json, sys

state = {
    "timestamp": "$TIMESTAMP",
    "plan_path": "$PLAN_PATH" or None,
    "plan_status": "$PLAN_STATUS" or None,
    "next_task": """$NEXT_TASK""" or None,
    "log_path": "$LOG_PATH" or None,
}

# Clean up empty strings
state = {k: (v if v else None) for k, v in state.items()}

with open("$STATE_FILE", "w") as f:
    json.dump(state, f, indent=2)

print(f"State saved to $STATE_FILE")
if state.get("plan_path"):
    print(f"  Plan: {state['plan_path']} [{state.get('plan_status', '?')}]")
if state.get("next_task"):
    print(f"  Next: {state['next_task'][:80]}")
PYEOF
