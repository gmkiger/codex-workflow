#!/usr/bin/env bash
# scripts/run-workflow.sh — Skill dispatcher for GPT Codex CLI
#
# Usage:
#   ./scripts/run-workflow.sh <skill-name> [args...]
#   ./scripts/run-workflow.sh --fork claim-verifier "claims text" "questions text" "sources"
#
# Without --fork: launches codex with the skill's .md file as additional
#   instructions prepended to the session. The skill file tells the model
#   exactly what to do; the user's args become the task input.
#
# With --fork: spawns a fresh codex subprocess using ONLY the agent's
#   instructions + the provided text. No prior session context is passed.
#   This implements the CoVe independence trick for claim-verifier.
#
# Requirements: codex CLI in PATH

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SKILLS_DIR="$PROJECT_ROOT/.codex/skills"
AGENTS_DIR="$PROJECT_ROOT/.codex/agents"

FORK_MODE=false
SKILL_NAME=""
ARGS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --fork)
            FORK_MODE=true
            shift
            ;;
        -*)
            # Pass unknown flags through to codex
            ARGS+=("$1")
            shift
            ;;
        *)
            if [[ -z "$SKILL_NAME" ]]; then
                SKILL_NAME="$1"
            else
                ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

if [[ -z "$SKILL_NAME" ]]; then
    echo "Usage: $0 [--fork] <skill-name> [args...]" >&2
    echo "" >&2
    echo "Available skills:" >&2
    ls "$SKILLS_DIR"/*.md 2>/dev/null | xargs -I{} basename {} .md | sort | sed 's/^/  /' >&2
    echo "" >&2
    echo "Available agents (for --fork):" >&2
    ls "$AGENTS_DIR"/*.md 2>/dev/null | xargs -I{} basename {} .md | sort | sed 's/^/  /' >&2
    exit 1
fi

# --fork mode: CoVe subprocess for claim-verifier
# Fresh context — only agent instructions + provided claims/questions/sources
if [[ "$FORK_MODE" == "true" ]]; then
    AGENT_FILE="$AGENTS_DIR/${SKILL_NAME}.md"
    if [[ ! -f "$AGENT_FILE" ]]; then
        echo "ERROR: Agent file not found: $AGENT_FILE" >&2
        exit 1
    fi

    if ! command -v codex >/dev/null 2>&1; then
        echo "ERROR: 'codex' not found in PATH." >&2
        exit 1
    fi

    # Build the task prompt from remaining args
    TASK_PROMPT=""
    for arg in "${ARGS[@]}"; do
        TASK_PROMPT+="$arg"$'\n\n'
    done

    # Spawn fresh subprocess with only the agent instructions
    # No AGENTS.md is passed — the subprocess sees only the agent file
    exec codex \
        --model gpt-4.1 \
        --approval-mode full-auto \
        --instructions "$(cat "$AGENT_FILE")" \
        --quiet \
        -- "$TASK_PROMPT"
fi

# Normal mode: inject skill instructions into a new session
SKILL_FILE="$SKILLS_DIR/${SKILL_NAME}.md"
if [[ ! -f "$SKILL_FILE" ]]; then
    # Also check without .md extension
    SKILL_FILE="$SKILLS_DIR/${SKILL_NAME}"
    if [[ ! -f "$SKILL_FILE" ]]; then
        echo "ERROR: Skill file not found: $SKILLS_DIR/${SKILL_NAME}.md" >&2
        echo "Available skills:" >&2
        ls "$SKILLS_DIR"/*.md 2>/dev/null | xargs -I{} basename {} .md | sort | sed 's/^/  /' >&2
        exit 1
    fi
fi

if ! command -v codex >/dev/null 2>&1; then
    echo "ERROR: 'codex' not found in PATH." >&2
    echo "Install: npm install -g @openai/codex" >&2
    exit 1
fi

# Run session init before launching
if [[ -f "$PROJECT_ROOT/.codex/hooks/session-init.sh" ]]; then
    bash "$PROJECT_ROOT/.codex/hooks/session-init.sh"
fi

# Build task prompt: skill name + user args
TASK_INPUT="Workflow: ${SKILL_NAME}"
if [[ ${#ARGS[@]} -gt 0 ]]; then
    TASK_INPUT+=" ${ARGS[*]}"
fi

# Launch codex: AGENTS.md is auto-loaded from project root by codex;
# the skill instructions are appended as additional context via --instructions.
# The model will see: AGENTS.md + skill file + user task.
exec codex \
    --model gpt-4.1 \
    --approval-mode full-auto \
    --instructions "$(cat "$SKILL_FILE")" \
    -- "$TASK_INPUT"
