---
name: seven-pass-review
description: Seven-lens adversarial review. Runs 7 sequential specialist reviewers (abstract, intro, methods, results, robustness, prose, citations), then synthesizes a revision checklist. Trigger: "seven pass review", "maximum coverage review". High token cost — use for submission-ready/R&R papers.
argument-hint: "[manuscript path]"
---

# Seven-Pass Adversarial Review

Seven sequential specialist reviewers, each on one lens, then synthesized into a revision plan.

> Costs ~7× more than `/review-paper` (default). Use for submission-ready or R&R stage papers. For early drafts, use `/review-paper`. For journal simulation, use `/review-paper --peer <journal>`.

## Phase 0: Pre-flight

1. Resolve manuscript path.
2. If `.pdf` → extract text first: `pdftotext -layout manuscript.pdf manuscript.txt`
3. Create output dir: `quality_reports/seven_pass_[stem]/`

## Phase 1: Seven Sequential Lenses

For each lens, adopt the specified role, read the manuscript with fresh focus on ONLY that lens, produce output, save, return to orchestrating role.

| # | Lens | Focus | Role |
|---|------|-------|------|
| 1 | Abstract audit | Question stated? Method named? Result quantified? Contribution clear? Matches body? | general |
| 2 | Intro structure | Hook → context → contribution → roadmap? Lit review placement? Contribution-numbered? | general |
| 3 | Methods / identification | Assumptions stated? Identification credible? Violations addressed? DiD/RDD/IV explicit? | domain-reviewer |
| 4 | Results + tables | Tables standalone? Magnitude interpreted? Units consistent? | general |
| 5 | Robustness | Anticipates referee objections? Robustness motivated or theatrical? Placebo tests? | general |
| 6 | Prose quality | Sentences ≤30 words? Active voice? Hedging proportionate? Paragraph topic sentences? | proofreader |
| 7 | Citations | `/validate-bib --semantic`; top-10 cited: does in-text claim match cited paper's direction? | general |

Save each lens output: `quality_reports/seven_pass_[stem]/lens_[N]_[lens-name].md`

**Lens 3 (Methods):** Adopt **domain-reviewer** role (`.codex/agents/domain-reviewer.md`). Apply its 5-lens framework specifically to the methods section.

**Lens 6 (Prose):** Adopt **proofreader** role (`.codex/agents/proofreader.md`). Focus on sentence-level prose quality, not typos.

## Phase 2: Synthesis

After all 7 lenses, produce `quality_reports/seven_pass_[stem]/_SYNTHESIS.md`:

```markdown
# Seven-Pass Review: [Manuscript]
**Date:** YYYY-MM-DD

## Executive verdict
[SUBMIT / REVISE-MINOR / REVISE-MAJOR / REJECT-AND-RESTART]

## Cross-lens CRITICAL issues
| # | Lens(es) | Issue | Recommendation |

## MAJOR issues
| # | Lens(es) | Issue |

## MINOR polish
[bulleted]

## Per-lens scorecard
| Lens | Critical | Major | Minor | Score/10 |

## Revision plan (recommended order)
1. [Highest-leverage fix]
...

## Contradictions between lenses
[Surface any lens disagreements]
```

## Exit Behavior

Exits 0 (informational). Any CRITICAL in synthesis should block submission until resolved.

## Cross-references

- `.codex/skills/review-paper.md` — single-pass and adversarial modes (cheaper, faster)
- `.codex/skills/validate-bib.md` — invoked by Lens 7
- `.codex/skills/audit-reproducibility.md` — numeric-claims complement
