#!/usr/bin/env bash
# scripts/codex.sh — Preferred session launcher for GPT Codex CLI
#
# Runs session initialization (active plan + session log context), then
# launches codex with the project's standard flags. Pass any additional
# codex flags as arguments, e.g.:
#   CODEX_MODEL=gpt-5.2 ./scripts/codex.sh
#   CODEX_APPROVAL_POLICY=never ./scripts/codex.sh
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

# Launch codex with project defaults.
#
# Codex CLI 0.130.0 uses `--ask-for-approval` and `--sandbox`; older
# `--approval-mode` examples from Claude/Codex migrations are intentionally
# avoided here. Environment variables let users pin a model/policy without
# editing this script.
CODEX_MODEL="${CODEX_MODEL:-}"
CODEX_APPROVAL_POLICY="${CODEX_APPROVAL_POLICY:-on-request}"
CODEX_SANDBOX="${CODEX_SANDBOX:-workspace-write}"

case "$CODEX_SANDBOX" in
    read-only|workspace-write|danger-full-access)
        ;;
    *)
        echo "WARNING: invalid CODEX_SANDBOX='$CODEX_SANDBOX'; using workspace-write" >&2
        CODEX_SANDBOX="workspace-write"
        ;;
esac

cmd=(codex)
if [[ -n "$CODEX_MODEL" ]]; then
    cmd+=(--model "$CODEX_MODEL")
fi
cmd+=(--ask-for-approval "$CODEX_APPROVAL_POLICY")
cmd+=(--sandbox "$CODEX_SANDBOX")

exec "${cmd[@]}" "$@"
