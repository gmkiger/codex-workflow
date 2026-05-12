#!/usr/bin/env bash
# .codex/hooks/verify-files.sh — Post-edit verification reminder
#
# Replaces Claude Code's verify-reminder.py PostToolUse hook.
# Called after editing academic files to remind about compilation/rendering.
#
# Usage: bash .codex/hooks/verify-files.sh <file-path>
# The Codex model should call this (via Bash) after editing .tex, .qmd, or .R files.

set -uo pipefail

FILE="$1"

if [[ -z "$FILE" ]]; then
    echo "Usage: $0 <file-path>" >&2
    exit 1
fi

FILENAME="$(basename "$FILE")"
EXT="${FILENAME##*.}"
EXT="$(echo "$EXT" | tr '[:upper:]' '[:lower:]')"

CYAN="\033[0;36m"
GREEN="\033[0;32m"
NC="\033[0m"

case "$EXT" in
    tex)
        echo -e "${CYAN}Verification reminder:${NC} $FILENAME"
        echo -e "   → ${GREEN}compile with: cd Slides && TEXINPUTS=../Preambles:\$TEXINPUTS xelatex -interaction=nonstopmode ${FILENAME%.tex}.tex${NC}"
        echo -e "   → Check for: Overfull \\\\hbox warnings, undefined citations"
        ;;
    qmd)
        echo -e "${CYAN}Verification reminder:${NC} $FILENAME"
        echo -e "   → ${GREEN}render with: ./scripts/sync_to_docs.sh $(echo "$FILENAME" | sed 's/\.qmd$//')${NC}"
        echo -e "   → Check: all TikZ use .svg (not .pdf), math matches Beamer"
        ;;
    r)
        echo -e "${CYAN}Verification reminder:${NC} $FILENAME"
        echo -e "   → ${GREEN}run to verify: Rscript $FILE${NC}"
        echo -e "   → Check: output files created, no errors, figures generated"
        ;;
    *)
        # Not an academic file that needs special verification
        exit 0
        ;;
esac

echo ""
