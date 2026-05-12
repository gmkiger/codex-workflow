---
name: qa-quarto
description: Adversarial Quarto-vs-Beamer parity QA. Critic compares Quarto HTML to Beamer PDF; fixer applies fixes; loops until APPROVED (max 5 rounds). Trigger: "qa the quarto", "check parity", "does html match pdf", "quarto matches beamer".
argument-hint: "[LectureN]"
---

# Adversarial Quarto vs Beamer QA

Iterative critic/fixer loop comparing Quarto HTML against Beamer PDF benchmark.

**Philosophy:** The Beamer PDF is the gold standard. The Quarto translation must be at least as good in every dimension.

## Hard Gates (Non-Negotiable)

| Gate | Condition |
|------|-----------|
| Overflow | NO content cut off |
| Plot Quality | Interactive charts >= static plots |
| Content Parity | No missing slides, equations, or text |
| Visual Regression | Quarto >= Beamer in all dimensions |
| Notation Fidelity | All math verbatim from Beamer (INV-2) |

## Workflow

```
Phase 0: Pre-flight
Phase 1: Critic audit → save report
Phase 2: Fix cycle (if not APPROVED)
Phase 3: Re-audit → loop (max 5 rounds)
```

## Phase 0: Pre-flight

1. Locate Beamer (`.tex`/`.pdf`) and Quarto (`.qmd`/`.html`) files for `$ARGUMENTS`
2. Re-render if QMD is newer than HTML
3. Verify TikZ SVGs are current

## Phase 1: Initial Audit

Adopt the **quarto-critic** role by reading `.codex/agents/quarto-critic.md`. Compare Beamer vs Quarto comprehensively. Save: `quality_reports/$ARGUMENTS_qa_critic_round1.md`.

If verdict is APPROVED → skip to final report.

## Phase 2: Fix Cycle

Adopt the **quarto-fixer** role by reading `.codex/agents/quarto-fixer.md`. Apply fixes (Critical → Major → Minor). Re-render and verify compile.

## Phase 3: Re-Audit

Return to quarto-critic role. Re-audit. If still not APPROVED and rounds < 5, loop back to Phase 2.

## After Max 5 Rounds

Report remaining issues to user. Do NOT loop further.

## Final Report

Save `quality_reports/$ARGUMENTS_qa_final.md` with:
- Hard gate status (PASS/FAIL per gate)
- Rounds completed
- Remaining issues (if any)
