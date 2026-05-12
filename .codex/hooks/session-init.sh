#!/usr/bin/env bash
# .codex/hooks/session-init.sh — Session context restoration
#
# Replaces Claude Code's post-compact-restore.py and SessionStart hook.
# Run at the start of every Codex session (called automatically by scripts/codex.sh).
# Can also be run manually: bash .codex/hooks/session-init.sh
#
# Prints:
#   1. Active plan (most recent non-COMPLETED plan in quality_reports/plans/)
#   2. Current task (first unchecked item in the plan)
#   3. Most recent session log name

set -uo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

CYAN="\033[0;36m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NC="\033[0m"

PLANS_DIR="$PROJECT_ROOT/quality_reports/plans"
LOGS_DIR="$PROJECT_ROOT/quality_reports/session_logs"

echo ""
echo -e "${CYAN}[Session Init — Codex CLI]${NC}"
echo ""

# --- Active Plan ---
if [[ -d "$PLANS_DIR" ]]; then
    ACTIVE_PLAN=""
    ACTIVE_STATUS=""
    NEXT_TASK=""

    # Find most recent plan that isn't COMPLETED
    while IFS= read -r plan_file; do
        content="$(cat "$plan_file")"
        # Skip completed plans
        if echo "$content" | grep -qi "COMPLETED"; then
            continue
        fi
        ACTIVE_PLAN="$plan_file"
        # Determine status
        if echo "$content" | grep -qi "APPROVED"; then
            ACTIVE_STATUS="APPROVED"
        elif echo "$content" | grep -qi "DRAFT"; then
            ACTIVE_STATUS="DRAFT"
        else
            ACTIVE_STATUS="IN PROGRESS"
        fi
        # Find first unchecked task
        NEXT_TASK="$(echo "$content" | grep -F -e '- [ ]' | head -1 | sed 's/- \[ \] *//' | cut -c1-80 || true)"
        break
    done < <(find "$PLANS_DIR" -name "*.md" 2>/dev/null | sort -r)

    if [[ -n "$ACTIVE_PLAN" ]]; then
        echo -e "${GREEN}Active Plan:${NC} $(basename "$ACTIVE_PLAN") [${ACTIVE_STATUS}]"
        if [[ -n "$NEXT_TASK" ]]; then
            echo -e "${GREEN}Next task:${NC}   $NEXT_TASK"
        fi
    else
        echo -e "No active plan found in $PLANS_DIR"
    fi
else
    echo "  (no quality_reports/plans/ directory found)"
fi

echo ""

# --- Session Log ---
if [[ -d "$LOGS_DIR" ]]; then
    LATEST_LOG="$(find "$LOGS_DIR" -name "*.md" -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1 || true)"
    if [[ -n "$LATEST_LOG" ]]; then
        echo -e "${GREEN}Session Log:${NC} $(basename "$LATEST_LOG")"
    else
        echo -e "${YELLOW}No session log found.${NC} Consider creating quality_reports/session_logs/$(date +%Y-%m-%d)_description.md"
    fi
else
    echo -e "${YELLOW}No session_logs/ directory found.${NC}"
fi

echo ""

# --- Recovery guidance ---
echo -e "${YELLOW}Recovery actions:${NC}"
echo "  1. Read the active plan file to understand current objectives"
echo "  2. Run: git status && git log --oneline -5"
echo "  3. Continue from where you left off"
echo ""
