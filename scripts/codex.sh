#!/usr/bin/env bash
# scripts/codex.sh — Preferred session launcher for GPT Codex CLI
#
# Runs session initialization (active plan + session log context), then
# launches codex with the project's standard flags. Pass any additional
# codex flags as arguments, e.g.:
#   ./scripts/codex.sh --model o3
#   ./scripts/codex.sh --approval-mode auto-edit
#
# Requirements: codex CLI in PATH (npm install -g @openai/codex or equivalent)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export PROJECT_ROOT

# Run session initialization to print active plan + last session log
if [[ -f "$PROJECT_ROOT/.codex/hooks/session-init.sh" ]]; then
    bash "$PROJECT_ROOT/.codex/hooks/session-init.sh"
fi

# Validate codex is available
if ! command -v codex >/dev/null 2>&1; then
    echo "ERROR: 'codex' not found in PATH." >&2
    echo "Install: npm install -g @openai/codex" >&2
    exit 1
fi

# Launch codex with project defaults
# --model: gpt-4.1 is the recommended model for this workflow
# --approval-mode full-auto: equivalent to Claude Code bypassPermissions
exec codex \
    --model gpt-4.1 \
    --approval-mode full-auto \
    "$@"
