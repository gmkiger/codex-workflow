#!/usr/bin/env bash
# =============================================================================
# validate-setup.sh — Verify dependencies for the Codex academic workflow
#
# Run this after forking the repo to confirm your environment is ready.
# Exits 0 if required tools are found; non-zero otherwise.
# =============================================================================

set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

pass=0
warn=0
fail=0

echo ""
echo -e "${BOLD}Validating Codex Academic Workflow setup...${RESET}"
echo ""

check_required() {
    local name="$1"
    local cmd="$2"
    local install_url="$3"
    local version_line
    if command -v "$cmd" >/dev/null 2>&1; then
        version_line="$("$cmd" --version 2>&1 | grep -v '^WARNING:' | head -n1)"
        echo -e "  ${GREEN}✓${RESET} $name found: $version_line"
        pass=$((pass + 1))
    else
        echo -e "  ${RED}✗${RESET} $name NOT FOUND — install: ${install_url}"
        fail=$((fail + 1))
    fi
}

check_optional() {
    local name="$1"
    local cmd="$2"
    local install_url="$3"
    local version_line
    if command -v "$cmd" >/dev/null 2>&1; then
        version_line="$("$cmd" --version 2>&1 | grep -v '^WARNING:' | head -n1)"
        echo -e "  ${GREEN}✓${RESET} $name found: $version_line"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} $name not found (optional) — install: ${install_url}"
        warn=$((warn + 1))
    fi
}

echo -e "${BOLD}Required tools:${RESET}"
check_required "Codex CLI" "codex" "https://github.com/openai/codex"
check_required "git" "git" "https://git-scm.com/downloads"
check_required "Python 3" "python3" "https://python.org"
echo ""

echo -e "${BOLD}Recommended academic tools:${RESET}"
check_optional "XeLaTeX" "xelatex" "https://tug.org/texlive/ (or MacTeX: https://tug.org/mactex/)"
check_optional "Quarto" "quarto" "https://quarto.org/docs/get-started/"
check_optional "R" "R" "https://www.r-project.org/"
check_optional "GitHub CLI" "gh" "https://cli.github.com/"
echo ""

echo -e "${BOLD}Git configuration:${RESET}"
if command -v git >/dev/null 2>&1; then
    git_name=$(git config user.name 2>/dev/null || true)
    git_email=$(git config user.email 2>/dev/null || true)
    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        echo -e "  ${GREEN}✓${RESET} git user: $git_name <$git_email>"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} git user.name / user.email not set"
        echo -e "    Run: git config --global user.name \"Your Name\""
        echo -e "    Run: git config --global user.email \"you@example.com\""
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} skipped — install git first"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Codex helper scripts:${RESET}"
for helper in scripts/codex.sh scripts/run-workflow.sh .codex/hooks/session-init.sh .codex/hooks/session-state.sh .codex/hooks/verify-files.sh; do
    if [ -x "$helper" ]; then
        echo -e "  ${GREEN}✓${RESET} $helper is executable"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} $helper missing or not executable"
        echo -e "    Fix: chmod +x $helper"
        warn=$((warn + 1))
    fi
done
echo ""

echo -e "${BOLD}Tracked git hook:${RESET}"
if [ -x ".githooks/pre-commit" ]; then
    configured_path=$(git config --get core.hooksPath 2>/dev/null || true)
    if [ "$configured_path" = ".githooks" ]; then
        echo -e "  ${GREEN}✓${RESET} core.hooksPath is configured for .githooks"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} pre-commit hook exists but is not installed"
        echo -e "    Fix: ./scripts/install-hooks.sh"
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} .githooks/pre-commit missing or not executable"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Palette sync (LaTeX ↔ SCSS):${RESET}"
palette_script="$(dirname "$0")/check-palette-sync.sh"
if [ -x "$palette_script" ]; then
    if "$palette_script" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${RESET} Preambles/header.tex ↔ Quarto/theme-template.scss agree on the core palette"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} Palette drift — run ./scripts/check-palette-sync.sh for details"
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} scripts/check-palette-sync.sh missing or not executable — skipping"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Summary:${RESET} ${GREEN}${pass} passed${RESET}, ${YELLOW}${warn} warnings${RESET}, ${RED}${fail} failed${RESET}"
echo ""

has_codex="false"; command -v codex >/dev/null 2>&1 && has_codex="true"
has_xelatex="false"; command -v xelatex >/dev/null 2>&1 && has_xelatex="true"
has_quarto="false"; command -v quarto >/dev/null 2>&1 && has_quarto="true"
has_r="false"; command -v R >/dev/null 2>&1 && has_r="true"
hooks_installed="false"; [ "$(git config --get core.hooksPath 2>/dev/null || true)" = ".githooks" ] && hooks_installed="true"

if [ "$fail" -gt 0 ]; then
    echo -e "${RED}Some required tools are missing.${RESET}"
    echo ""
    echo -e "${BOLD}What you CAN do right now:${RESET}"
    if [ "$has_codex" = "true" ]; then
        echo "  - Start Codex:                         ./scripts/codex.sh"
    else
        echo "  - Install Codex CLI first:             https://github.com/openai/codex"
    fi
    echo "  - Edit Markdown / LaTeX / R files directly in the repo"
    echo ""
    echo -e "${BOLD}Next:${RESET} install the missing required tool(s), then re-run this script."
    exit 1
fi

echo -e "${GREEN}Core setup looks good.${RESET} Next steps:"
if [ "$hooks_installed" != "true" ]; then
    echo "  1. Install tracked git hooks:          ./scripts/install-hooks.sh"
else
    echo "  1. Tracked git hooks:                  installed"
fi
echo "  2. Open Codex in this directory:       ./scripts/codex.sh"
if [ "$has_xelatex" = "true" ]; then
    echo "  3. Compile the sample deck:            run the compile-latex skill on HelloWorld"
fi
if [ "$has_quarto" = "true" ]; then
    echo "  4. Deploy the Quarto sample:           run the deploy skill on HelloWorld"
fi
if [ "$has_r" = "true" ]; then
    echo "  5. Run the R scaffold:                 Rscript scripts/R/00_run_all.R"
fi
echo ""
exit 0
