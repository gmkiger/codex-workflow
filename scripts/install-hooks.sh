#!/usr/bin/env bash
# Install tracked git hooks for this repository.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$PROJECT_ROOT"

if [[ ! -d .git ]]; then
    echo "ERROR: not inside a git repository" >&2
    exit 1
fi

if [[ ! -x .githooks/pre-commit ]]; then
    chmod +x .githooks/pre-commit
fi

git config core.hooksPath .githooks
echo "Installed tracked git hooks: core.hooksPath=.githooks"
