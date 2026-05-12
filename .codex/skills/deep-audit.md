---
name: deep-audit
description: Repository-wide consistency audit. Checks skill/agent/rule inventory, documentation drift, frontmatter parity, and claim-vs-reality issues. Trigger: "deep audit", "repository audit", "consistency check".
argument-hint: ""
---

# Deep Audit

Repository-wide consistency audit across `.codex/` infrastructure and documentation.

## Scope

### Agent 1: Inventory Audit (mechanical)
Run the integrity check script:
```bash
python3 scripts/check-skill-integrity.py
```
This checks:
- Frontmatter fields present and consistent (name, description, argument-hint)
- Skill body references agent/rule files that actually exist
- No broken `.codex/` → `.codex/` cross-links
- Rule files exist for all `.codex/rules/` references in skills

Report: any missing files, broken links, or frontmatter inconsistencies.

### Agent 2: Hooks + Scripts Audit
Check all executable code under `.codex/hooks/` and `scripts/`:
- Docstring matches actual behavior
- `set -euo pipefail` or equivalent robustness
- `$(git rev-parse --show-toplevel)` used (not hardcoded paths)
- Fail-open patterns where appropriate
- No dead config-map entries

### Agent 3: Documentation Drift
- Surface sync: `./scripts/check-surface-sync.sh`
- AGENTS.md skill reference table matches actual `.codex/skills/` files (count + names)
- AGENTS.md agent table matches actual `.codex/agents/` files
- CLAUDE.md lecture table matches actual `Slides/` and `Quarto/` files

### Agent 4: Claim-vs-Reality
Read AGENTS.md and check each behavioral claim:
- Every mentioned skill file actually exists at stated path
- Every mentioned agent file exists at stated path
- Quality gate thresholds match `quality_score.py` implementation
- Multi-agent protocol descriptions match actual skill file instructions

## Report

Save `quality_reports/deep_audit_[date].md`:
- Summary table: Agent 1–4 × PASS/FAIL/N-ISSUES
- Critical issues (must fix before committing)
- Medium issues (should fix soon)
- Low issues (polish)

## Known False Alarms (do not re-flag)

- `session.json` in `.codex/state/` may be missing on a fresh clone — expected
- `.git/hooks/pre-commit` running quality_score.py — this is intentional, not a hook bug
- `.claude/` references in CLAUDE.md — these are for Claude Code and intentionally differ from `.codex/`
